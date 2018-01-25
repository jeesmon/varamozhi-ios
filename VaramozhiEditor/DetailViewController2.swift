//
//  DetailViewController2.swift
//  VaramozhiEditor
//
//  Created by jijo on 1/19/15.
//  Copyright (c) 2015 jeesmon. All rights reserved.
//

import UIKit
import MessageUI
import Social

class DetailViewController2: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UISplitViewControllerDelegate  {
    
    @IBOutlet var textViewType: UITextView!
    @IBOutlet var textViewDisplay: UITextView!
    @IBOutlet var toolBarActions: UIToolbar!
    
    var varamozhi: MyBridge = MyBridge()
    
    
    let kActionClear = 1
    let kActionCopy = 2
    let kActionMail = 3
    let kActionSMS = 4
    
    
    let kActionFB = 5
    let kActionTwitter = 6
    let kActionHelp = 7
    let kActionAbout = 8
    let kActionMore = 9
    
    //@IBOutlet var textViewBottomLayoutGuideConstraint: NSLayoutConstraint!
  
    func toggleToolBarItems(NextPage nextPage: Bool) {
        
        /*var arrayItemsExist: [AnyObject]? = self.toolBarActions?.items
        
        if arrayItemsExist?.count > 0 {
            tagFirst = arrayItemsExist![0].tag
        }*/
        
        var items = [UIBarButtonItem]()
        
        //if (nextPage && tagFirst == kActionFB) || tagFirst == 0 || (!nextPage && tagFirst == kActionClear) {
        
        let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        
        items.append(UIBarButtonItem(image: UIImage(named: "remove.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.clearscreen(_:)) ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        
        items.append(UIBarButtonItem(image: UIImage(named: "copy.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.copyme(_:)) ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        
        
        
        items.append(UIBarButtonItem(image: UIImage(named: "mail.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.mailme(_:)) ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        //let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        if !isPad {
            
            items.append(UIBarButtonItem(image: UIImage(named: "envelope.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.smsme(_:)) ))
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        }
        
        var imgnamefb = "facebook.png"
        if !SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
        {
            imgnamefb = "facebook_gray.png"
        }
        var imgnametw = "twitter.png"
        if !SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter)
        {
            imgnametw = "twitter_gray.png"
        }
        
        items.append(UIBarButtonItem(image: UIImage(named: imgnamefb), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.faceme(_:)) ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil))
        
        items.append(UIBarButtonItem(image: UIImage(named: imgnametw), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.tweetme(_:)) ))
        //items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        
        self.toolBarActions?.items = items
        
    }
    
    @objc func faceme(_ sender: UIBarButtonItem) {
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook))
        {
            let SocialMedia :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            SocialMedia.completionHandler = {
                result -> Void in
                
                
               // var getResult = result as SLComposeViewControllerResult;
                /*switch(getResult.rawValue)
                {
                
                    case SLComposeViewControllerResult.Done.rawValue:
                
                
                }*/
                
                self.dismiss(animated: true, completion: nil)
            }
            self.present(SocialMedia, animated: true, completion: nil)
            SocialMedia.setInitialText(self.textViewDisplay.text)
        }
    }
    @objc func tweetme(_ sender: UIBarButtonItem) {
        
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter))
        {
            let SocialMedia :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            SocialMedia.completionHandler = {
                result -> Void in
                
                
                //var getResult = result as SLComposeViewControllerResult;
                
                self.dismiss(animated: true, completion: nil)
            }
            self.present(SocialMedia, animated: true, completion: nil)
            SocialMedia.setInitialText(self.textViewDisplay.text)
        }
    }
    @objc func smsme(_ sender: UIBarButtonItem) {
        
        if(MFMessageComposeViewController.canSendText()){
            
            let messageComposeVC: MFMessageComposeViewController = MFMessageComposeViewController()
            messageComposeVC.messageComposeDelegate = self
            messageComposeVC.title = "Shared from Varamozhi"
            messageComposeVC.body = self.textViewDisplay.text
            self.present(messageComposeVC, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    @objc func clearscreen(_ sender: UIBarButtonItem) {
        
        self.textViewDisplay.text = nil
        self.textViewType.text = nil
    }
    
    @objc func copyme(_ sender: UIBarButtonItem) {
        
        let pasteboard: UIPasteboard = UIPasteboard.general
        
        pasteboard.string = self.textViewDisplay.text;
        if self.textViewDisplay.text.characters.count > 0 {
            varamozhi.makeToast("Text copied. Paste anywhere.", on: self.view)
        }
    }
    @objc func mailme(_ sender: UIBarButtonItem) {
        
        if(MFMailComposeViewController.canSendMail()){
            
            let myMail: MFMailComposeViewController = MFMailComposeViewController()
            myMail.mailComposeDelegate = self
            myMail.setMessageBody(self.textViewDisplay.text, isHTML: true)
            self.present(myMail, animated: true, completion: nil)
            
        }else{
            /*var alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            
            let mail = ""
            let mailURL: URL =  URL(string: "mailto:\(mail)")!
            UIApplication.shared.openURL(mailURL)
            
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?){
            
            switch(result.rawValue){
            case MFMailComposeResult.sent.rawValue:
                print("Email sent")
                
            default:
                print("Whoops")
            }
            
            self.dismiss(animated: true, completion: nil)
            
    }
    // MARK: Convenience
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var inputStr: NSMutableString
        
        if range.length == 0 {
            
            inputStr = NSMutableString(string: textView.text)
            inputStr.insert(text, at: range.location)
            
        }else{
            
            inputStr = NSMutableString(string: textView.text)
            inputStr.replaceCharacters(in: range, with: text)
        }
        
        let f2:String = varamozhi.getConvertedText(inputStr as String) as String
        
        self.textViewDisplay.text = f2
        
        //self.textViewDisplay.layoutManager.ensureLayoutForTextContainer(self.textViewDisplay.textContainer)
        
        if self.textViewDisplay.contentSize.height > self.textViewDisplay.frame.size.height
        {
            let offset: CGPoint = CGPoint(x: 0, y: self.textViewDisplay.contentSize.height - self.textViewDisplay.frame.size.height);
            self.textViewDisplay.setContentOffset(offset, animated: false)
        }
        
        //self.textViewDisplay.setContentOffset(CGPointMake(0.0, self.textViewDisplay.contentSize.height), animated:false)
        //self.textViewDisplay.scrollRangeToVisible(NSMakeRange(countElements(f2) - 1, 1))
        //self.textViewDisplay.scrollRectToVisible(CGRectMake(0, self.textViewDisplay.contentSize.height-5, self.textViewDisplay.frame.size.width, 5), animated: false)
        // NSRange range = NSMakeRange(textView.text.length - 1, 1);
        //[self.textViewDisplay scrollRangeToVisible:range];
        
        return true
    }
    
    func keyboardWillChangeFrameWithNotification(_ notification: Notification, showsKeyboard: Bool) {
        
       
        
        let userInfo = notification.userInfo!
        
        
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        
        // Convert the keyboard frame from screen to view coordinates.
        
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardViewBeginFrame = view.convert(keyboardScreenBeginFrame, from: view.window)
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        
        
        // The text view should be adjusted, update the constant for this constraint.
        
        
        //self.textViewBottomLayoutGuideConstraint.constant -= originDelta
        
        view.setNeedsUpdateConstraints()
        self.textViewType.setNeedsUpdateConstraints()
        self.textViewDisplay.setNeedsUpdateConstraints()
        self.toolBarActions.setNeedsUpdateConstraints()
        
        //println("self.textViewDisplay.frame1 = \(self.textViewDisplay.frame.size.height)")
        //println("self.toolBarActions.frame1 = \(self.toolBarActions.frame.origin.y)")
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .beginFromCurrentState, animations: {
            
            var recttyp: CGRect = self.textViewType.frame
            var rectdisplay: CGRect = self.textViewDisplay.frame
            var recttool: CGRect = self.toolBarActions.frame
            var rectview: CGRect = self.view.frame
            
            /*
            recttyp.size.height += (originDelta / 2.0)
            rectdisplay.size.height += (originDelta / 2.0)
            rectview.size.height += originDelta
            */
            
            if showsKeyboard {
                //("show kb \(originDelta)");
                recttyp.size.height = 30.0 //+= (originDelta / 2.0)
                rectdisplay.size.height += (originDelta / 2.0)
                rectview.size.height += originDelta
                
                
                
            }else{
                
                //("hide kb");
                let height: CGFloat = UIScreen.main.bounds.size.height - self.navigationController!.navigationBar.frame.size.height
                
                
                recttyp.size.height = (height - self.toolBarActions.frame.size.height) / 2.0
                rectdisplay.size.height = recttyp.size.height
                rectview.size.height = height
                //self.textViewBottomLayoutGuideConstraint.constant = 0;
                
                
            }
            
            
            
            recttool.origin.y = rectdisplay.origin.y + rectdisplay.size.height
            recttyp.origin.y = recttool.origin.y + recttool.size.height
            
            self.view.frame = rectview
            
            self.view.layoutIfNeeded()
            
            self.textViewType.frame = recttyp
            self.textViewDisplay.frame = rectdisplay
            self.toolBarActions.frame = recttool
            
            //self.textViewType.contentSize = CGSize(width: self.textViewType.frame.size.width, height: self.textViewType.frame.size.height)
            
            
            self.textViewType.layoutIfNeeded()
            self.textViewDisplay.layoutIfNeeded()
            self.toolBarActions.layoutIfNeeded()
            
            
            
            }, completion: nil)
        
        
        
        // Scroll to the selected text once the keyboard frame changes.
        
        //let selectedRange = textViewType.selectedRange
        
        //textViewType.scrollRangeToVisible(selectedRange)
        
    }
    
    
    
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
        
    }
    
    
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(DetailViewController2.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(DetailViewController2.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
       

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let delay = 0.05 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.setFocus()
        })
    }
    
    func setFocus() {
        self.textViewType.becomeFirstResponder()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        
        super.viewDidDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.setValue(self.textViewType.text, forKey: "typedtext")
    }
    
    override func viewDidLoad() {
        
        
        //+20150127self.automaticallyAdjustsScrollViewInsets = false;
        
        
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        
        let titleDict: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
        self.toggleToolBarItems(NextPage: false)
        
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        if orientation.isLandscape {
            let btnExp = UIBarButtonItem(image: UIImage(named: "expand.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.expand(_:)))
            self.navigationItem.leftBarButtonItem = btnExp
        }
        
    
        self.textViewType.text = UserDefaults.standard.value(forKey: "typedtext") as? String
        
        let f2:String = varamozhi.getConvertedText(self.textViewType.text) as String
        
        self.textViewDisplay.text = f2
        
        self.title = "Transliteration"
        
        
        
        //textViewType.inputViewController = varamozhi.KeyboardViewController()
    }
    
    // MARK: - Split view Delegate
    
    
    /*override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator){
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition(nil, completion: {context in
            if(UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait || UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown){
                //this is portrait (or upsidedown), do something
                self.navigationItem.leftBarButtonItem = nil
                
            }else{
                //landscape
                var btnExp = UIBarButtonItem(image: UIImage(named: "expand.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("expand:"))
                self.navigationItem.leftBarButtonItem = btnExp
            }
        })
    }*/
    @objc func expand(_ sender: AnyObject){
        
        
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.hideMaster()
        
        let btnCon = UIBarButtonItem(image: UIImage(named: "contract.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.contract(_:)))
        self.navigationItem.leftBarButtonItem = btnCon
        
        
    }
    @objc func contract(_ sender: AnyObject){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMaster()
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        if orientation.isLandscape {
            
            let btnExp = UIBarButtonItem(image: UIImage(named: "expand.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController2.expand(_:)))
            self.navigationItem.leftBarButtonItem = btnExp

        }else{
            self.navigationItem.leftBarButtonItem = appDelegate.getDisplayButton()
            
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
