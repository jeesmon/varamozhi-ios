//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

import UIKit
import AudioToolbox

let metrics: [String:Float] = [
    "topBanner": 30
]

func metric(_ name: String) -> CGFloat {
    
    //+20141231
    if UserDefaults.standard.bool(forKey: kDisablePopupKeys) {
        return 0
    }else{
        //+20150325
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
            return CGFloat(metrics[name]!)
        } else {
            return CGFloat(metrics[name]!) * 1.3
        }
        
    }
    
    

}

// TODO: move this somewhere else and localize
//let kAutoCapitalization = "kAutoCapitalization"
let kPeriodShortcut = "kPeriodShortcut"
let kKeyboardClicks = "kKeyboardClicks"
let kDisablePopupKeys = "kDisablePopupKeys"
//let kKeyPadMalayalam = "kKeyPadMalayalam"

class KeyboardViewController: UIInputViewController {
    
    let backspaceDelay: TimeInterval = 0.5
    let backspaceRepeat: TimeInterval = 0.07
    
    var keyboard: Keyboard!
    var forwardingView: ForwardingView!
    var layout: KeyboardLayout?
    var heightConstraint: NSLayoutConstraint?
    
    var bannerView: ExtraView? //+20150325
    var settingsView: ExtraView?
    
    //+20141209
    var varamozhi: MyBridge = MyBridge()
    var typedKeys:String = ""
    var lastchar: String = ""
    
    var currentMode: Int {
        didSet {
            //+20150102if oldValue != currentMode {
                setMode(currentMode)
            //}
        }
    }
    
    var backspaceActive: Bool {
        get {
            return (backspaceDelayTimer != nil) || (backspaceRepeatTimer != nil)
        }
    }
    var backspaceDelayTimer: Timer?
    var backspaceRepeatTimer: Timer?
    
    enum AutoPeriodState {
        case noSpace
        case firstSpace
    }
    
    var autoPeriodState: AutoPeriodState = .noSpace
    var lastCharCountInBeforeContext: Int = 0
    
    enum ShiftState {
        case disabled
        case enabled
        case locked
        
        func uppercase() -> Bool {
            switch self {
            case .disabled:
                return false
            case .enabled:
                return true
            case .locked:
                return true
            }
        }
    }
    var shiftState: ShiftState {
        didSet {
            switch shiftState {
            case .disabled:
                self.updateKeyCaps(true)
            case .enabled:
                self.updateKeyCaps(false)
            case .locked:
                self.updateKeyCaps(false)
            }
        }
    }
    
    var shiftWasMultitapped: Bool = false
    
    var keyboardHeight: CGFloat {
        get {
            if let constraint = self.heightConstraint {
                return constraint.constant
            }
            else {
                return 0
            }
        }
        set {
            self.setHeight(newValue)
        }
    }
    
    // TODO: why does the app crash if this isn't here?
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        UserDefaults.standard.register(defaults: [
            //kAutoCapitalization: false, //+20141218
            //kKeyPadMalayalam: false,
            kPeriodShortcut: true,
            kKeyboardClicks: true,
            kDisablePopupKeys: false
        ])
        UserDefaults.standard.set(true, forKey: kDisablePopupKeys)
        UserDefaults.standard.set(true, forKey: kPeriodShortcut)
        UserDefaults.standard.set(false, forKey: kKeyboardClicks)
        
        
        self.keyboard = defaultKeyboard()
        
        self.shiftState = .disabled
        self.currentMode = 0
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.forwardingView = ForwardingView(frame: CGRect.zero)
        self.view.addSubview(self.forwardingView)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardViewController.defaultsChanged(_:)), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        backspaceDelayTimer?.invalidate()
        backspaceRepeatTimer?.invalidate()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func defaultsChanged(_ notification: Notification) {
        _ = notification.object as! UserDefaults
        self.updateKeyCaps(!self.shiftState.uppercase())
    }
    
    // without this here kludge, the height constraint for the keyboard does not work for some reason
    var kludge: UIView?
    func setupKludge() {
        if self.kludge == nil {
            let kludge = UIView()
            self.view.addSubview(kludge)
            kludge.translatesAutoresizingMaskIntoConstraints = false
            kludge.isHidden = true
            
            let a = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
            let b = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
            let c = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            let d = NSLayoutConstraint(item: kludge, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            self.view.addConstraints([a, b, c, d])
            
            self.kludge = kludge
        }
    }
    
    /*
    BUG NOTE

    For some strange reason, a layout pass of the entire keyboard is triggered 
    whenever a popup shows up, if one of the following is done:

    a) The forwarding view uses an autoresizing mask.
    b) The forwarding view has constraints set anywhere other than init.

    On the other hand, setting (non-autoresizing) constraints or just setting the
    frame in layoutSubviews works perfectly fine.

    I don't really know what to make of this. Am I doing Autolayout wrong, is it
    a bug, or is it expected behavior? Perhaps this has to do with the fact that
    the view's frame is only ever explicitly modified when set directly in layoutSubviews,
    and not implicitly modified by various Autolayout constraints
    (even though it should really not be changing).
    */
    
    var constraintsAdded: Bool = false
    func setupLayout() {
        if !constraintsAdded {
            self.layout = type(of: self).layoutClass.init(model: self.keyboard, superview: self.forwardingView, layoutConstants: type(of: self).layoutConstants, globalColors: type(of: self).globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode())
            
            self.layout?.initialize()
            self.setupKeys()
            self.setMode(0)
            
            self.setupKludge()
            
            self.updateKeyCaps(!self.shiftState.uppercase())
            self.setCapsIfNeeded()
            
            self.updateAppearances(self.darkMode())
            self.addInputTraitsObservers()
            
            self.constraintsAdded = true
        }
    }
    
    // only available after frame becomes non-zero
    func darkMode() -> Bool {
        let darkMode = { () -> Bool in
            let proxy = self.textDocumentProxy
            return proxy.keyboardAppearance == UIKeyboardAppearance.dark
        }()
        
        return darkMode
    }
    
    func solidColorMode() -> Bool {
        //return true //TODO: temporary, until vibrancy performance is fixed +roll ?
        
        return UIAccessibilityIsReduceTransparencyEnabled()
        //return UIAccessibilityIsReduceTransparencyEnabled()
    }
    
    var lastLayoutBounds: CGRect?
    override func viewDidLayoutSubviews() {
        if view.bounds == CGRect.zero {
            return
        }
        
        self.setupLayout()
        let orientationSavvyBounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.heightForOrientation(false))
        
        if (lastLayoutBounds != nil && lastLayoutBounds == orientationSavvyBounds) {
            // do nothing
        }
        else {
            self.forwardingView.frame = orientationSavvyBounds
            self.layout?.layoutTemp()
            self.lastLayoutBounds = orientationSavvyBounds
        }
        
        self.bannerView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: metric("topBanner"))//+20150325
        let newOrigin = CGPoint(x: 0, y: self.view.bounds.height - self.forwardingView.bounds.height )
        self.forwardingView.frame.origin = newOrigin
    }
    
    override func loadView() {
        super.loadView()
        
        //+20150325
        if let aBanner = self.createBanner() {
            aBanner.isHidden = true
            self.view.insertSubview(aBanner, belowSubview: self.forwardingView)
            self.bannerView = aBanner
        }
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.bannerView?.isHidden = false //+20150325
        self.keyboardHeight = self.heightForOrientation(false)
        
    }
    /*+20150421
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIDeviceOrientation, duration: NSTimeInterval) {
        self.keyboardHeight = self.heightForOrientation(toInterfaceOrientation, withTopBanner: true)
    }
    **/
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator){
            
        super.viewWillTransition(to: size, with: coordinator)
        
        self.forwardingView.resetTrackedViews()
        //self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        self.keyboardHeight = self.heightForOrientation(false)//+20151123
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.forwardingView.resetTrackedViews()
        //self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        self.keyboardHeight = self.heightForOrientation(false)//+20151123
    }
    
    //+20141217
    // Workaround:
    fileprivate struct SubStruct { static var staticVariable: Bool = false }
    
    class var workaroundClassVariable: Bool
    {
        get { return SubStruct.staticVariable }
        set { SubStruct.staticVariable = newValue }
    }
    class func isLanscapeKB() -> Bool {
        
        return workaroundClassVariable
    }
    func heightForOrientation(_ orientation: UIInterfaceOrientation, withTopBanner: Bool) -> CGFloat {

        let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        
        //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeScale)
        let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        KeyboardViewController.workaroundClassVariable = orientation.isLandscape
        
        return CGFloat(orientation.isPortrait ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
    }
    
    func heightForOrientation(_ withTopBanner: Bool) -> CGFloat {
        let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        
        //+20151123
        let screenSize = UIScreen.main.bounds.size
        let screenH = screenSize.height
        let screenW = screenSize.width
        let isLandscape =  !(self.view.frame.size.width == screenW * ((screenW < screenH) ? 1 : 0) + screenH * ((screenW > screenH) ? 1 : 0))
        KeyboardViewController.workaroundClassVariable = isLandscape
        
        
        //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeScale)
        //let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(orientation.isPortrait && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalPortraitHeight = (isPad ? CGFloat(264) : CGFloat(!isLandscape && actualScreenWidth >= 400 ? 226 : 216))
        let canonicalLandscapeHeight = (isPad ? CGFloat(352) : CGFloat(162))
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        //KeyboardViewController.workaroundClassVariable = orientation.isLandscape
        
        
        return CGFloat(!isLandscape ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
        //return CGFloat(orientation.isPortrait ? canonicalPortraitHeight  + topBannerHeight  : canonicalLandscapeHeight  + topBannerHeight )
        
    }
    /*
    BUG NOTE

    None of the UIContentContainer methods are called for this controller.
    */
    
    //override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //}
    
    func setupKeys() {
        if self.layout == nil {
            return
        }
        
        for page in keyboard.pages {
            for rowKeys in page.rows { // TODO: quick hack
                for key in rowKeys {
                    let keyView = self.layout!.viewForKey(key)! // TODO: check
                    
                    keyView.removeTarget(nil, action: nil, for: UIControlEvents.allEvents)//+201412
                    
                    switch key.type {
                    case Key.KeyType.keyboardChange:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.advanceTapped(_:)), for: .touchUpInside)
                    case Key.KeyType.backspace:
                        let cancelEvents: UIControlEvents = [UIControlEvents.touchUpInside, UIControlEvents.touchUpInside, UIControlEvents.touchDragExit, UIControlEvents.touchUpOutside, UIControlEvents.touchCancel, UIControlEvents.touchDragOutside]
                        
                        keyView.addTarget(self, action: #selector(KeyboardViewController.backspaceDown(_:)), for: .touchDown)
                        keyView.addTarget(self, action: #selector(KeyboardViewController.backspaceUp(_:)), for: cancelEvents)
                    case Key.KeyType.shift:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.shiftDown(_:)), for: .touchUpInside)
                        keyView.addTarget(self, action: #selector(KeyboardViewController.shiftDoubleTapped(_:)), for: .touchDownRepeat)
                    case Key.KeyType.modeChange:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.modeChangeTapped(_:)), for: .touchUpInside)
                    case Key.KeyType.settings:
                        keyView.addTarget(self, action: Selector("toggleSettings"), for: .touchUpInside)
                    case Key.KeyType.dismiss:
                        keyView.addTarget(self, action: #selector(KeyboardViewController.dismissKB(_:)), for: .touchUpInside)//+20141212
                    default:
                        break
                    }
                    
                    if key.hasOutput {
                        keyView.addTarget(self, action: #selector(KeyboardViewController.keyPressedHelper(_:)), for: .touchUpInside)
                    }
                    
                    if key.isCharacter {
                        //+20150101
                        //+20151123  && !NSUserDefaults.standardUserDefaults().boolForKey(kDisablePopupKeys
                        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {

                            keyView.addTarget(self, action: #selector(KeyboardViewController.showPopup(_:)), for: [.touchDown, .touchDragInside, .touchDragEnter])
                            keyView.addTarget(keyView, action: Selector("hidePopup"), for: .touchDragExit)
                            keyView.addTarget(self, action: #selector(KeyboardViewController.hidePopupDelay(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragOutside])
                        }
                    }
                    
                    if key.type != Key.KeyType.shift && key.type != Key.KeyType.modeChange {
                        keyView.addTarget(self, action: #selector(KeyboardViewController.highlightKey(_:)), for: [.touchDown, .touchDragInside, .touchDragEnter])
                        keyView.addTarget(self, action: #selector(KeyboardViewController.unHighlightKey(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragOutside, .touchDragExit])
                    }
                    keyView.addTarget(self, action: #selector(KeyboardViewController.playKeySound), for: .touchDown)
                }
            }
        }
    }
    
    /////////////////
    // POPUP DELAY //
    /////////////////
    
    var keyWithDelayedPopup: KeyboardKey?
    var popupDelayTimer: Timer?
    
    @objc func showPopup(_ sender: KeyboardKey) {
        if sender == self.keyWithDelayedPopup {
            self.popupDelayTimer?.invalidate()
        }
        sender.showPopup()
    }
    
    @objc func hidePopupDelay(_ sender: KeyboardKey) {
        self.popupDelayTimer?.invalidate()
        
        if sender != self.keyWithDelayedPopup {
            self.keyWithDelayedPopup?.hidePopup()
            self.keyWithDelayedPopup = sender
        }
        
        if sender.popup != nil {
            self.popupDelayTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(KeyboardViewController.hidePopupCallback), userInfo: nil, repeats: false)
        }
    }
    
    @objc func hidePopupCallback() {
        self.keyWithDelayedPopup?.hidePopup()
        self.keyWithDelayedPopup = nil
        self.popupDelayTimer = nil
    }
    
    /////////////////////
    // POPUP DELAY END //
    /////////////////////
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    // TODO: this is currently not working as intended; only called when selection changed -- iOS bug
    override func textDidChange(_ textInput: UITextInput?) {
        //typedKeys = ""//+20141210
        let previousContext:String? = self.textDocumentProxy.documentContextBeforeInput
        if  typedKeys.characters.count > 0  {
            
            if previousContext != nil{
                
                let contextStr:String = previousContext!
                
                let f1:NSString = varamozhi.getConvertedText(typedKeys) as! NSString
                let range = contextStr.range(of: f1 as String)
                if range?.upperBound != contextStr.endIndex {
                    typedKeys = ""
                }
            }else{
                typedKeys = ""
            }
        
            
        }
        
        self.contextChanged()
    }
    override func textWillChange(_ textInput: UITextInput?) {
        
        
    }
    func contextChanged() {
        self.setCapsIfNeeded()
        self.autoPeriodState = .noSpace
    }
    
    func setHeight(_ height: CGFloat) {
        if self.heightConstraint == nil {
            self.heightConstraint = NSLayoutConstraint(
                item:self.view,
                attribute:NSLayoutAttribute.height,
                relatedBy:NSLayoutRelation.equal,
                toItem:nil,
                attribute:NSLayoutAttribute.notAnAttribute,
                multiplier:0,
                constant:height)
            self.heightConstraint!.priority = UILayoutPriority(rawValue: 1000)
            
            self.view.addConstraint(self.heightConstraint!) // TODO: what if view already has constraint added?
        }
        else {
            self.heightConstraint?.constant = height
        }
    }
    
    func updateAppearances(_ appearanceIsDark: Bool) {
        self.layout?.solidColorMode = self.solidColorMode()
        self.layout?.darkMode = appearanceIsDark
        self.layout?.updateKeyAppearanceTemp()
        
        self.bannerView?.darkMode = appearanceIsDark //+20150325
        //self.settingsView?.darkMode = appearanceIsDark
    }
    
    @objc func highlightKey(_ sender: KeyboardKey) {
        sender.isHighlighted = true
    }
    
    @objc func unHighlightKey(_ sender: KeyboardKey) {
        sender.isHighlighted = false
    }
    
    @objc func keyPressedHelper(_ sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        if let model = self.layout?.keyForView(sender) {
            self.keyPressed(model)
            
            /*
            //m+20150325
            let previousContext:String? = (self.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
            
            if let banner = self.bannerView as? PredictiveBanner {
                
                if previousContext == nil || previousContext!.isEmpty {
                    
                    banner.clearBanner()
                    
                }else{
                    
                    
                    
                    if lastchar == " " {
                        banner.clearBanner()
                    }else{
                        
                        let range = previousContext!.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch)
                        
                        if range != nil {
                            let lastword = previousContext!.substringFromIndex(range!.endIndex)
                            
                            let ct = lastword.utf16.count
                            print("ct = \(ct)")
                            if ct == 1 {
                                banner.updateAlternateKeyList(lastword, Mode:0)
                            }else if ct > 1 {
                                banner.updateAlternateKeyList(lastword, Mode:1)
                            }
                            
                            
                            
                        }else{
                            let ct = previousContext!.utf16.count
                            print("ct2 = \(ct)")
                            if ct == 1 {
                                
                                banner.updateAlternateKeyList(previousContext, Mode:0)
                            }else if ct > 1 {
                                banner.updateAlternateKeyList(previousContext, Mode:1)
                            }
                            
                        }

                        
                        
                        
                    }
                    
                    
                }
                
            }
            */
            // auto exit from special char subkeyboard
            if model.type == Key.KeyType.space || model.type == Key.KeyType.return {
                self.setMode(0)
            }
            else if model.lowercaseOutput == "'" {
                self.setMode(0)
            }
            else if model.type == Key.KeyType.character {
                self.setMode(0)
            }
            
            // auto period on double space
            // TODO: timeout
           
            self.handleAutoPeriod(model)
            // TODO: reset context
        }
        
        if self.shiftState == ShiftState.enabled {
            self.shiftState = ShiftState.disabled
        }
        
        self.setCapsIfNeeded()
    }
    
    func handleAutoPeriod(_ key: Key) {
        if !UserDefaults.standard.bool(forKey: kPeriodShortcut) {
            return
        }
        
        if self.autoPeriodState == .firstSpace {
            if key.type != Key.KeyType.space {
                self.autoPeriodState = .noSpace
                return
            }
            
            let charactersAreInCorrectState = { () -> Bool in
                let previousContext = self.textDocumentProxy.documentContextBeforeInput
                if previousContext == nil || (previousContext!).characters.count < 3 {
                    return false
                }
                
                var index = previousContext!.endIndex
                //+20171120
                index = previousContext!.index(before: index)
                if previousContext![index] != " " {
                    return false
                }
                
                index = previousContext!.index(before: index)
                if previousContext![index] != " " {
                    return false
                }
                
                index = previousContext!.index(before: index)
                let char = previousContext![index]
                if self.characterIsWhitespace(char) || self.characterIsPunctuation(char) || char == "," {
                    return false
                }
                
                return true
            }()
            
            if charactersAreInCorrectState {
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.insertText(".")
                self.textDocumentProxy.insertText(" ")
            }
            
            self.autoPeriodState = .noSpace
        }
        else {
            if key.type == Key.KeyType.space {
                self.autoPeriodState = .firstSpace
            }
        }
    }
    
    func cancelBackspaceTimers() {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    @objc func backspaceDown(_ sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        
        lastchar = "" //+20150129
        //+20141229self.playKeySound()
        
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
            textDocumentProxy.deleteBackward()
            /*
            //+20150326
            let previousContext:String? = (self.textDocumentProxy as? UITextDocumentProxy)?.documentContextBeforeInput
            
            if let banner = self.bannerView as? PredictiveBanner {
                
                if previousContext == nil || previousContext!.isEmpty {
                    
                    banner.clearBanner()
                    
                }else{
                    
                    let range = previousContext!.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch)
                    
                    if range != nil {
                        let lastword = previousContext!.substringFromIndex(range!.endIndex)
                        let ct = lastword.utf16.count
                        if ct == 1 {
                            banner.updateAlternateKeyList(lastword, Mode:0)
                        }else if ct > 1{
                            banner.updateAlternateKeyList(lastword, Mode:1)
                        }
                        
                        
                    }else{
                        
                        let ct = previousContext!.utf16.count
                        if ct == 1 {
                            
                            banner.updateAlternateKeyList(previousContext, Mode:0)
                        }else if ct > 1 {
                            banner.updateAlternateKeyList(previousContext, Mode:1)
                        }
                    }
                }
            }*/

        //}
        //+20141208
        let stringLength = typedKeys.characters.count
        if stringLength > 1 {
            
            var isEmptyy = false
            let documentProxy = self.textDocumentProxy as UITextDocumentProxy
            if let beforeContext = documentProxy.documentContextBeforeInput {
                let previousCharacter = beforeContext[beforeContext.characters.index(before: beforeContext.endIndex)]
                isEmptyy = self.characterIsWhitespace(previousCharacter)
            }
            else {
                isEmptyy = true
            }
            if(isEmptyy){
                typedKeys = "";
            }else{
                
                let proxy = self.textDocumentProxy as UIKeyInput
                
                
                    let f1:NSString = varamozhi.getConvertedText(typedKeys) as! NSString
                    var i:Int = f1.length;
                    while i > 1
                    {
                        proxy.deleteBackward()
                        i -= 1;
                        
                    }
                    typedKeys = typedKeys.substring(to: typedKeys.characters.index(before: typedKeys.endIndex))

                    let f2:NSString = varamozhi.getConvertedText(typedKeys) as! NSString
                    proxy.insertText(f2 as String)
                
                
            }
            
        }else{
            typedKeys = "";
        }
        typedKeys = "";
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = Timer.scheduledTimer(timeInterval: backspaceDelay - backspaceRepeat, target: self, selector: #selector(KeyboardViewController.backspaceDelayCallback), userInfo: nil, repeats: false)
    }
    
    @objc func backspaceUp(_ sender: KeyboardKey) {
        self.cancelBackspaceTimers()
    }
    
    @objc func backspaceDelayCallback() {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = Timer.scheduledTimer(timeInterval: backspaceRepeat, target: self, selector: #selector(KeyboardViewController.backspaceRepeatCallback), userInfo: nil, repeats: true)
    }
    
    @objc func backspaceRepeatCallback() {
        
        self.playKeySound()
        let textDocumentProxy = self.textDocumentProxy as UIKeyInput
        textDocumentProxy.deleteBackward()
        typedKeys = "";
        
    }
    
    @objc func shiftDown(_ sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        lastchar = "sd" //+20150129
        
        if self.shiftWasMultitapped {
            self.shiftWasMultitapped = false
            return
        }
        
        switch self.shiftState {
        case .disabled:
            self.shiftState = .enabled
        case .enabled:
            self.shiftState = .disabled
        case .locked:
            self.shiftState = .disabled
        }
        
        (sender.shape as? ShiftShape)?.withLock = false
    }
    
    @objc func shiftDoubleTapped(_ sender: KeyboardKey) {
        
        if lastchar == "sd" {//+20150129
            
            self.shiftWasMultitapped = true
            
            switch self.shiftState {
            case .disabled:
                self.shiftState = .locked
            case .enabled:
                self.shiftState = .locked
            case .locked:
                self.shiftState = .disabled
            }
        }
        
    }
    
    // TODO: this should be uppercase, not lowercase
    func updateKeyCaps(_ lowercase: Bool) {
        if self.layout != nil {
           // let actualUppercase = true// (NSUserDefaults.standardUserDefaults().boolForKey(kSmallLowercase) ? !lowercase : true)
            
            for (model, key) in self.layout!.modelToView {
                key.text = model.keyCapForCase(!lowercase)//+20151215
                
                if model.type == Key.KeyType.shift {
                    switch self.shiftState {
                    case .disabled:
                        key.isHighlighted = false
                    case .enabled:
                        key.isHighlighted = true
                    case .locked:
                        key.isHighlighted = true
                    }
                    
                    (key.shape as? ShiftShape)?.withLock = (self.shiftState == .locked)
                }
            }
        }
    }
    
    @objc func modeChangeTapped(_ sender: KeyboardKey) {
        //+20141229self.playKeySound()
        
        if let toMode = self.layout?.viewToModel[sender]?.toMode {
            self.currentMode = toMode
        }
    }
    //+20141212
    @objc func dismissKB(_ sender: KeyboardKey){
        
        self.dismissKeyboard();
        
    }
    @objc func advanceTapped(_ sender: KeyboardKey) {
        self.forwardingView.resetTrackedViews()
        //self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        self.advanceToNextInputMode()
    }
    func setMode(_ mode: Int) {
        for (pageIndex, page) in self.keyboard.pages.enumerated() {
            for (_, row) in page.rows.enumerated() {
                for (_, key) in row.enumerated() {
                    if self.layout?.modelToView[key] != nil {
                        let keyView = self.layout?.modelToView[key]
                        keyView?.isHidden = (pageIndex != mode)
                    }
                }
            }
        }
    }
    /*
    @IBAction func toggleSettings() {
        //+20141229self.playKeySound()
        
        if self.settingsView == nil {
            if let aSettings = self.createSettings() {
                
                aSettings.darkMode = self.darkMode()
                
                aSettings.hidden = true
                self.view.addSubview(aSettings)
                self.settingsView = aSettings
                
                aSettings.translatesAutoresizingMaskIntoConstraints = false
                
                let widthConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
                
                self.view.addConstraint(widthConstraint)
                self.view.addConstraint(heightConstraint)
                self.view.addConstraint(centerXConstraint)
                self.view.addConstraint(centerYConstraint)
                
            }
        }
        
        
        
        if let settings = self.settingsView {
            let hidden = settings.hidden
            settings.hidden = !hidden
            self.forwardingView.hidden = hidden
            self.forwardingView.userInteractionEnabled = !hidden
            self.bannerView?.hidden = hidden//+20150325
        }
    }
    */
    // TODO: make this work if cursor position is shifted
    func setCapsIfNeeded() {
        if self.shouldAutoCapitalize() {
            switch self.shiftState {
            case .disabled:
                self.shiftState = .enabled
            case .enabled:
                self.shiftState = .enabled
            case .locked:
                self.shiftState = .locked
            }
        }
    }
    
    func characterIsPunctuation(_ character: Character) -> Bool {
        return (character == ".") || (character == "!") || (character == "?")
    }
    
    func characterIsNewline(_ character: Character) -> Bool {
        return (character == "\n") || (character == "\r")
    }
    
    func characterIsWhitespace(_ character: Character) -> Bool {
        // there are others, but who cares
        return (character == " ") || (character == "\n") || (character == "\r") || (character == "\t")
    }
    
    func stringIsWhitespace(_ string: String?) -> Bool {
        if string != nil {
            for char in (string!).characters {
                if !characterIsWhitespace(char) {
                    return false
                }
            }
        }
        return true
    }
    
    func shouldAutoCapitalize() -> Bool {
        /*if !NSUserDefaults.standardUserDefaults().boolForKey(kAutoCapitalization) {
            return false
        }*/
        return false;//+20141218
        /*if let traits = self.textDocumentProxy as? UITextInputTraits {
            if let autocapitalization = traits.autocapitalizationType {
                var documentProxy = self.textDocumentProxy as? UITextDocumentProxy
                var beforeContext = documentProxy?.documentContextBeforeInput
                
                switch autocapitalization {
                case .None:
                    return false
                case .Words:
                    if let beforeContext = documentProxy?.documentContextBeforeInput {
                        let previousCharacter = beforeContext[beforeContext.endIndex.predecessor()]
                        return self.characterIsWhitespace(previousCharacter)
                    }
                    else {
                        return true
                    }
                
                case .Sentences:
                    if let beforeContext = documentProxy?.documentContextBeforeInput {
                        let offset = min(3, countElements(beforeContext))
                        var index = beforeContext.endIndex
                        
                        for (var i = 0; i < offset; i += 1) {
                            index = index.predecessor()
                            let char = beforeContext[index]
                            
                            if characterIsPunctuation(char) {
                                if i == 0 {
                                    return false //not enough spaces after punctuation
                                }
                                else {
                                    return true //punctuation with at least one space after it
                                }
                            }
                            else {
                                if !characterIsWhitespace(char) {
                                    return false //hit a foreign character before getting to 3 spaces
                                }
                                else if characterIsNewline(char) {
                                    return true //hit start of line
                                }
                            }
                        }
                        
                        return true //either got 3 spaces or hit start of line
                    }
                    else {
                        return true
                    }
                case .AllCharacters:
                    return true
                }
            }
            else {
                return false
            }
        }
        else {
            return false
        }*/
    }
    
    // this only works if full access is enabled
    @objc func playKeySound() {
        if !UserDefaults.standard.bool(forKey: kKeyboardClicks) {
            return
        }
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            AudioServicesPlaySystemSound(1104)
        })
    }
    
    //////////////////////////////////////
    // MOST COMMONLY EXTENDABLE METHODS //
    //////////////////////////////////////
    
    class var layoutClass: KeyboardLayout.Type { get { return KeyboardLayout.self }}
    class var layoutConstants: LayoutConstants.Type { get { return LayoutConstants.self }}
    class var globalColors: GlobalColors.Type { get { return GlobalColors.self }}
    
    func keyPressed(_ key: Key) {
         let proxy = (self.textDocumentProxy as UIKeyInput)
            //+20141209
            let keyOutput = key.outputForCase(self.shiftState.uppercase())
            
            let f1:NSString = varamozhi.getConvertedText(typedKeys) as! NSString
            //proxy.insertText(keyOutput)
            
            if key.type == .character || key.type == .specialCharacter{
                
                typedKeys += keyOutput;
                
                var i:Int = f1.length;
                while i > 0
                {
                    proxy.deleteBackward()
                    i -= 1;
                    
                }
                
                let f2:String = varamozhi.getConvertedText(typedKeys) as String
                
                
                proxy.insertText(f2)
                
            }else{
                
                typedKeys = "";
                
                proxy.insertText(keyOutput)
            
            }
            
            lastchar = keyOutput //+20150129
        
    }
    
    // a banner that sits in the empty space on top of the keyboard
    func createBanner() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        //return ExtraView(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        //+20150325
        if UserDefaults.standard.bool(forKey: kDisablePopupKeys) {
            return nil
        } else{
            return nil//PredictiveBanner(keyboard: self)
        }
    }
    
    // a settings view that replaces the keyboard when the settings button is pressed
    /*func createSettings() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        let settingsView = DefaultSettings(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        settingsView.backButton?.addTarget(self, action: Selector("toggleSettings"), forControlEvents: UIControlEvents.TouchUpInside)
        return settingsView
    }*/
}

//// does not work; drops CPU to 0% when run on device
//extension UIInputView: UIInputViewAudioFeedback {
//    public var enableInputClicksWhenVisible: Bool {
//        return true
//    }
//}

//+20150325
/*
class PredictiveBanner: ExtraView {
    
    //var label: UILabel = UILabel()
    weak var keyboard: KeyboardViewController?
    //+rollvar dataStore : WordsDAO!
    var searchText :String?
    
    let scrolview : UIScrollView = UIScrollView()
    
    convenience init(keyboard: KeyboardViewController) {
        self.init(globalColors: nil, darkMode: false, solidColorMode: false)
        self.keyboard = keyboard
        //+20150326
        //+rolldataStore = WordsDAO()
        dataStore.initWithDataBase()
        
        
        self.addSubview(scrolview)
        
        self.updateAppearance()
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        self.keyboard = nil
        
        
        
    }
    //+20150428
    deinit {
        
        dataStore.closeAll()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrolview.frame = self.frame
        self.scrolview.center = self.center
        
        
    }
    
    func handleBtnPress(sender: UIButton) {
        if self.keyboard != nil {
            
            let kbd = self.keyboard!
            if let textDocumentProxy = kbd.textDocumentProxy as? UIKeyInput {
                
                if searchText != nil {
                    
                    let countt = searchText!.utf16.count
                    for var i = 0 ; i<countt ; i++ {
                        
                        textDocumentProxy.deleteBackward()
                    }
                }
                
                textDocumentProxy.insertText(sender.titleLabel!.text!)
                //textDocumentProxy.insertText(" ")
                
                self.clearBanner()
                self.updateAlternateKeyList(sender.titleLabel!.text!, Mode: 1)
                
                self.keyboard!.typedKeys = sender.titleLabel!.text! //+20150428
                //self.updateAlternateKeyList(sender.titleLabel!.text!, Mode: 100)
                
            }
            
            
        }
    }
    
    func applyConstraints(currentView: UIButton, prevView: UIView?, nextView: UIView?, firstView: UIView) {
        
        
        let parentView = self
        
        var leftConstraint: NSLayoutConstraint
        var rightConstraint: NSLayoutConstraint
        var topConstraint: NSLayoutConstraint
        var bottomConstraint: NSLayoutConstraint
        
        // Constrain to top of parent view
        topConstraint = NSLayoutConstraint(item: currentView, attribute: .Top, relatedBy: .Equal, toItem: parentView,
            attribute: .Top, multiplier: 1.0, constant: 1)
        
        // Constraint to bottom of parent too
        bottomConstraint = NSLayoutConstraint(item: currentView, attribute: .Bottom, relatedBy: .Equal, toItem: parentView, attribute: .Bottom, multiplier: 1.0, constant: -1)
        
        // If last, constrain to right
        if nextView == nil {
            rightConstraint = NSLayoutConstraint(item: currentView, attribute: .Right, relatedBy: .Equal, toItem: parentView, attribute: .Right, multiplier: 1.0, constant: -1)
        } else {
            rightConstraint = NSLayoutConstraint(item: currentView, attribute: .Right, relatedBy: .Equal, toItem: nextView, attribute: .Left, multiplier: 1.0, constant: -1)
        }
        
        // If first, constrain to left of parent
        if prevView == nil {
            leftConstraint = NSLayoutConstraint(item: currentView, attribute: .Left, relatedBy: .Equal, toItem: parentView, attribute: .Left, multiplier: 1.0, constant: 1)
        } else {
            leftConstraint = NSLayoutConstraint(item: currentView, attribute: .Left, relatedBy: .Equal, toItem: prevView, attribute: .Right, multiplier: 1.0, constant: 1)
            
            let widthConstraint = NSLayoutConstraint(item: firstView, attribute: .Width, relatedBy: .Equal, toItem: currentView, attribute: .Width, multiplier: 1.0, constant: 0)
            
            widthConstraint.priority = 800
            
            addConstraint(widthConstraint)
        }
        
        addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        
    }
    
    func clearBanner(){
        
        let sv = scrolview.subviews
        for v in sv {
            v.removeFromSuperview()
        }
        scrolview.scrollRectToVisible(CGRectMake(0,0,1,1), animated: false)
    }
    func updateAlternateKeyList(str: String?, Mode mode: Int32) {
        
        clearBanner()
        
        searchText = str
        
        //dataStore.initWithDataBase()
        let objects = dataStore.getAllMatchedWords(str, mode: mode)
        //dataStore.closeAll()
        
        if objects.count == 0 {
            
            searchText = ""
            return
        }
        
        
        
        scrolview.backgroundColor = UIColor.clearColor()
        
        var i:CGFloat = 0
        var wdth:CGFloat = 0
        var preButton : UIButton?
        for char in objects {
            
            let btn: UIButton = UIButton(type: UIButtonType.System)
            
            
            let text:String = char as! String
            var startx:CGFloat = 0
            if preButton != nil {
                
                startx = preButton!.frame.origin.x + preButton!.frame.size.width + 1
            }
            
            let sizee: CGSize = (text as NSString).sizeWithAttributes([NSFontAttributeName:UIFont.systemFontOfSize(16)]);
            
            
            btn.frame = CGRectMake(startx, 1, sizee.width+10, scrolview.frame.size.height-2)
            btn.setTitle(text, forState: .Normal)
            
            
            //btn.frame = CGRectMake(0, 0, 20, 20)
            //btn.setTitle(char as? String, forState: .Normal)
            //btn.titleLabel!.sizeToFit()
            //btn.sizeToFit()
            btn.titleLabel?.font = UIFont.systemFontOfSize(16)
            //btn.setTranslatesAutoresizingMaskIntoConstraints(false)
            if darkMode {//+20150421
                btn.backgroundColor = UIColor(red: CGFloat(12)/CGFloat(255), green: CGFloat(12)/CGFloat(255), blue: CGFloat(12)/CGFloat(255), alpha: 1)
            }else{
                btn.backgroundColor = UIColor(red: CGFloat(114)/CGFloat(255), green: CGFloat(148)/CGFloat(255), blue: CGFloat(114)/CGFloat(255), alpha: 1)
            }
            
            btn.setTitleColor(UIColor(white: 1.0, alpha: 1.0), forState: .Normal)
            
            //btn.setContentHuggingPriority(1000, forAxis: .Horizontal)
            //btn.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
            
            btn.addTarget(self, action: Selector("handleBtnPress:"), forControlEvents: .TouchUpInside)
            
            scrolview.addSubview(btn)
            preButton = btn
            wdth += preButton!.frame.size.width
            wdth += 1
            i++
        }
        
        if wdth < self.frame.size.width {
            
            let firstBtn = scrolview.subviews[0] as! UIButton
            let lastN = objects.count-1
            var prevBtn: UIButton?
            var nextBtn: UIButton?
            
            for (n, view) in scrolview.subviews.enumerate() {
                let btn = view as! UIButton
                
                btn.frame = CGRectMake(0, 0, 20, 20)
                btn.sizeToFit()
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.setContentHuggingPriority(1000, forAxis: .Horizontal)
                btn.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
                
                if n == lastN {
                    nextBtn = nil
                } else {
                    nextBtn = scrolview.subviews[n+1] as? UIButton
                }
                
                if n == 0 {
                    prevBtn = nil
                } else {
                    prevBtn = scrolview.subviews[n-1] as? UIButton
                }
                
                applyConstraints(btn, prevView: prevBtn, nextView: nextBtn, firstView: firstBtn)
            }
            
        }else{
            
            scrolview.contentSize = CGSizeMake(wdth, scrolview.frame.size.height)
        }
        
        
        
        
    }
    func updateAppearance() {
        
        
        //self.scrolview.sizeToFit()
    }
    
    
}
*/
