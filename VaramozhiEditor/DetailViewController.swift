//
//  DetailViewController.swift
//  VaramozhiEditor
//
//  Created by jijo pulikkottil on 12/23/14.
//  Copyright (c) 2014 jeesmon. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController , UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var viewSettings: UIView!
    @IBOutlet var editorView: UITextView!
    
    var modeDisplay: Int = 0
    
    var toolBarActions: UIToolbar!

    var filePath: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    @IBAction func openSettings(sender: UIButton) {
    
        UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
        
    }
    
    func configureView() {
        
        webView?.hidden = true
        editorView?.resignFirstResponder()
        editorView?.editable = false
        editorView?.hidden = true
        viewSettings?.hidden = true
        
        
        if modeDisplay == 0 {
            
            self.title = "Installation"
            viewSettings?.hidden = false
            
        }else if modeDisplay == 1 {
            
            if let detail: String = self.filePath {
                
                self.title = "Guide"
                var url = NSURL(fileURLWithPath: detail)
                if webView != nil {
                    
                    webView.delegate = self
                    webView.hidden = false
                    webView.loadRequest(NSURLRequest(URL: url!))
                }
            }
        }else{
            
            /*editorView?.hidden = false
            editorView?.editable = true
            editorView?.becomeFirstResponder()
*/
            if let detail: String = self.filePath {
                
                self.title = "Info"
                var url = NSURL(fileURLWithPath: detail)
                if webView != nil {
                    
                    webView.delegate = self
                    webView.hidden = false
                    webView.loadRequest(NSURLRequest(URL: url!))
                }
            }
        }
       
        
    }

    override func viewDidLoad() {
        
        
        
        
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func keyboardWillShowNotification(notification : NSNotification){
        
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                /*var rect: CGRect = editorView.frame
                rect.size.height = self.view.frame.size.height - keyboardSize.height
                
                editorView.frame = rect
                */
                editorView?.contentInset = contentInsets
                
            } else {
                // no UIKeyboardFrameBeginUserInfoKey entry in userInfo
            }
        } else {
            // no userInfo dictionary in notification
        }
        
    }
    func keyboardWillHideNotification(noti : NSNotification){
        
        /*var rect: CGRect = editorView.frame
        rect.size.height = self.view.frame.size.height
        
        editorView.frame = rect
        */
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.view.frame.size.height, right: 0)
        editorView.contentInset = contentInsets

    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        
    }
}

