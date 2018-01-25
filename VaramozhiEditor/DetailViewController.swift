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
    @IBOutlet var activity: UIActivityIndicatorView!
    
    var modeDisplay: Int = 0
    
    var filePath: String? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }
    
    func configureView() {
        
        
        if modeDisplay == 0 {
            
            self.title = "Setup & Usage"
           
            
        }else if modeDisplay == 1 {
            
            self.title = "Transliteration"
            
        }else if modeDisplay == 2 {
        
            self.title = "User Guide"
        }else{
            
            self.title = "About"
        }
        
        if let detail: String = self.filePath {
            
           
            if webView != nil {
                let url = URL(fileURLWithPath: detail)
                webView.loadRequest(URLRequest(url: url))
            }
            
        }
        
        
    }

    override func viewDidLoad() {
        
        
        
        
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        
        let titleDict: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.white

        
        // Do any additional setup after loading the view, typically from a nib.
        //let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        if self.filePath == nil {
            self.filePath = Bundle.main.path(forResource: "installation", ofType: "html")
        }
        self.configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        activity.startAnimating()
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        
        activity.stopAnimating()
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        
        activity.stopAnimating()
    }
}

