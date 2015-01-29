//
//  AppDelegate.swift
//  VaramozhiEditor
//
//  Created by jijo pulikkottil on 12/23/14.
//  Copyright (c) 2014 jeesmon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    var rootsplitview: UISplitViewController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
       
        let splitViewController = self.window!.rootViewController as UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        self.rootsplitview = splitViewController
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        return true
    }

    
    func getDisplayButton() -> UIBarButtonItem {
        
       let splitViewController = self.window!.rootViewController as UISplitViewController
       return splitViewController.displayModeButtonItem()
        
    }
    func hideMaster(){
        
        let splitViewController = self.window!.rootViewController as UISplitViewController
        splitViewController.preferredDisplayMode = UISplitViewControllerDisplayMode.PrimaryHidden
        
    }
    func showMaster(){
        
        self.rootsplitview?.preferredDisplayMode = UISplitViewControllerDisplayMode.Automatic
        
    }
    
    func hideMasterOnPortrait() {
        
        UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.hideMaster()
            
            }, completion:{
                
                (Bool) in self.rootsplitview?.preferredDisplayMode = UISplitViewControllerDisplayMode.Automatic
                return ()
                
        })
        
        
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let splitViewController = self.window!.rootViewController as UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as UINavigationController
        let viewController: DetailViewController2? = navigationController.topViewController as? DetailViewController2
        
        if viewController != nil && viewController!.isKindOfClass(DetailViewController2) {
            
            viewController!.textViewType.resignFirstResponder()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.filePath == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }
    func splitViewController(svc: UISplitViewController, willChangeToDisplayMode displayMode: UISplitViewControllerDisplayMode) {
        
        //let isPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
        
        if displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
            
            let navigationController = svc.viewControllers[svc.viewControllers.count-1] as UINavigationController
            let controler: DetailViewController2? = navigationController.topViewController as? DetailViewController2
            if controler != nil && controler!.isKindOfClass(DetailViewController2) {
                
                controler!.textViewType.resignFirstResponder()
                controler!.navigationItem.leftBarButtonItem = svc.displayModeButtonItem()
            }
            
            
            
        }else{
            
            let navigationController = svc.viewControllers[svc.viewControllers.count-1] as UINavigationController
            let viewController: DetailViewController2? = navigationController.topViewController as? DetailViewController2
            
            if viewController != nil && viewController!.isKindOfClass(DetailViewController2) {
                
                viewController!.textViewType.resignFirstResponder()
                var btnExp = UIBarButtonItem(image: UIImage(named: "expand.png"), style: UIBarButtonItemStyle.Plain, target: viewController, action: Selector("expand:"))
                viewController!.navigationItem.leftBarButtonItem = btnExp
            }
            
            
        }
    }

}

