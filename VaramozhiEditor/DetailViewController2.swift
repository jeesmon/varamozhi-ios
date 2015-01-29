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
        
        var arrayItemsExist: [AnyObject]? = self.toolBarActions?.items
        
        var tagFirst = 0
        
        if arrayItemsExist?.count > 0 {
            tagFirst = arrayItemsExist![0].tag
        }
        
        var items = [AnyObject]()
        
        //if (nextPage && tagFirst == kActionFB) || tagFirst == 0 || (!nextPage && tagFirst == kActionClear) {
        
        let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        
        items.append(UIBarButtonItem(image: UIImage(named: "remove.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("clearscreen:") ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        
        items.append(UIBarButtonItem(image: UIImage(named: "copy.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("copyme:") ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        
        
        
        items.append(UIBarButtonItem(image: UIImage(named: "mail.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("mailme:") ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        //let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        if !isPad {
            
            items.append(UIBarButtonItem(image: UIImage(named: "envelope.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("smsme:") ))
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        
        var imgnamefb = "facebook.png"
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
        {
            imgnamefb = "facebook_gray.png"
        }
        var imgnametw = "twitter.png"
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
        {
            imgnametw = "twitter_gray.png"
        }
        
        items.append(UIBarButtonItem(image: UIImage(named: imgnamefb), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("faceme:") ))
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        
        items.append(UIBarButtonItem(image: UIImage(named: imgnametw), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("tweetme:") ))
        //items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        
        self.toolBarActions?.items = items
        
    }
    
    func faceme(sender: UIBarButtonItem) {
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook))
        {
            var SocialMedia :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            SocialMedia.completionHandler = {
                result -> Void in
                
                
                var getResult = result as SLComposeViewControllerResult;
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(SocialMedia, animated: true, completion: nil)
            SocialMedia.setInitialText(self.textViewDisplay.text)
        }
    }
    func tweetme(sender: UIBarButtonItem) {
        
        if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter))
        {
            var SocialMedia :SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            SocialMedia.completionHandler = {
                result -> Void in
                
                
                var getResult = result as SLComposeViewControllerResult;
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(SocialMedia, animated: true, completion: nil)
            SocialMedia.setInitialText(self.textViewDisplay.text)
        }
    }
    func smsme(sender: UIBarButtonItem) {
        
        if(MFMessageComposeViewController.canSendText()){
            
            let messageComposeVC: MFMessageComposeViewController = MFMessageComposeViewController()
            messageComposeVC.messageComposeDelegate = self
            messageComposeVC.title = "Shared from Varamozhi"
            messageComposeVC.body = self.textViewDisplay.text
            self.presentViewController(messageComposeVC, animated: true, completion: nil)
            
        }else{
            var alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    func clearscreen(sender: UIBarButtonItem) {
        
        
        
        self.textViewDisplay.text = nil
        self.textViewType.text = nil
    }
    
    func copyme(sender: UIBarButtonItem) {
        
        var pasteboard: UIPasteboard = UIPasteboard.generalPasteboard()
        
        pasteboard.string = self.textViewDisplay.text;
    }
    func mailme(sender: UIBarButtonItem) {
        
        if(MFMailComposeViewController.canSendMail()){
            
            var myMail: MFMailComposeViewController = MFMailComposeViewController()
            myMail.mailComposeDelegate = self
            myMail.setMessageBody(self.textViewDisplay.text, isHTML: true)
            self.presentViewController(myMail, animated: true, completion: nil)
            
        }else{
            /*var alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            */
            
            let mail = ""
            let mailURL: NSURL =  NSURL(string: "mailto:\(mail)")!
            UIApplication.sharedApplication().openURL(mailURL)
            
        }
    }
    func mailComposeController(controller: MFMailComposeViewController!,
        didFinishWithResult result: MFMailComposeResult,
        error: NSError!){
            
            switch(result.value){
            case MFMailComposeResultSent.value:
                println("Email sent")
                
            default:
                println("Whoops")
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
    }
    // MARK: Convenience
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var inputStr: NSMutableString
        
        if range.length == 0 {
            
            inputStr = NSMutableString(string: textView.text)
            inputStr.insertString(text, atIndex: range.location)
            
        }else{
            
            inputStr = NSMutableString(string: textView.text)
            inputStr.replaceCharactersInRange(range, withString: text)
        }
        
        let f2:String = varamozhi.getConvertedText(inputStr) as String
        
        self.textViewDisplay.text = f2
        
        //self.textViewDisplay.layoutManager.ensureLayoutForTextContainer(self.textViewDisplay.textContainer)
        
        if self.textViewDisplay.contentSize.height > self.textViewDisplay.frame.size.height
        {
            let offset: CGPoint = CGPointMake(0, self.textViewDisplay.contentSize.height - self.textViewDisplay.frame.size.height);
            self.textViewDisplay.setContentOffset(offset, animated: false)
        }
        
        //self.textViewDisplay.setContentOffset(CGPointMake(0.0, self.textViewDisplay.contentSize.height), animated:false)
        //self.textViewDisplay.scrollRangeToVisible(NSMakeRange(countElements(f2) - 1, 1))
        //self.textViewDisplay.scrollRectToVisible(CGRectMake(0, self.textViewDisplay.contentSize.height-5, self.textViewDisplay.frame.size.width, 5), animated: false)
        // NSRange range = NSMakeRange(textView.text.length - 1, 1);
        //[self.textViewDisplay scrollRangeToVisible:range];
        
        return true
    }
    
    func keyboardWillChangeFrameWithNotification(notification: NSNotification, showsKeyboard: Bool) {
        
       
        
        let userInfo = notification.userInfo!
        
        
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
        
        
        
        // Convert the keyboard frame from screen to view coordinates.
        
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        
        
        // The text view should be adjusted, update the constant for this constraint.
        
        
        //self.textViewBottomLayoutGuideConstraint.constant -= originDelta
        
        view.setNeedsUpdateConstraints()
        self.textViewType.setNeedsUpdateConstraints()
        self.textViewDisplay.setNeedsUpdateConstraints()
        self.toolBarActions.setNeedsUpdateConstraints()
        
        //println("self.textViewDisplay.frame1 = \(self.textViewDisplay.frame.size.height)")
        //println("self.toolBarActions.frame1 = \(self.toolBarActions.frame.origin.y)")
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: .BeginFromCurrentState, animations: {
            
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
                recttyp.size.height = 30.0 //+= (originDelta / 2.0)
                rectdisplay.size.height += (originDelta / 2.0)
                rectview.size.height += originDelta
                
                
                
            }else{
                
                var height: CGFloat = UIScreen.mainScreen().bounds.size.height - self.navigationController!.navigationBar.frame.size.height
                
                
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
    
    
    
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: true)
        
    }
    
    
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        
        keyboardWillChangeFrameWithNotification(notification, showsKeyboard: false)
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        println("appear")
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
       

    }
    
    
    override func viewDidDisappear(animated: Bool) {
        

        super.viewDidDisappear(animated)
        
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        

    }
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
  
        NSUserDefaults.standardUserDefaults().setValue(self.textViewType.text, forKey: "typedtext")
    }
    
    override func viewDidLoad() {
        
        println("viewDidLoad")
        //+20150127self.automaticallyAdjustsScrollViewInsets = false;
        
        
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        
        self.toggleToolBarItems(NextPage: false)
        
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isLandscape {
            var btnExp = UIBarButtonItem(image: UIImage(named: "expand.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("expand:"))
            self.navigationItem.leftBarButtonItem = btnExp
        }
        
    
        self.textViewType.text = NSUserDefaults.standardUserDefaults().valueForKey("typedtext") as? String
        
        let f2:String = varamozhi.getConvertedText(self.textViewType.text) as String
        
        self.textViewDisplay.text = f2
        
        
        
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
    func expand(sender: AnyObject){
        
        
       let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.hideMaster()
        
        var btnCon = UIBarButtonItem(image: UIImage(named: "contract.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("contract:"))
        self.navigationItem.leftBarButtonItem = btnCon
        
        
    }
    func contract(sender: AnyObject){
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.showMaster()
        
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation.isLandscape {
            
            var btnExp = UIBarButtonItem(image: UIImage(named: "expand.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("expand:"))
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