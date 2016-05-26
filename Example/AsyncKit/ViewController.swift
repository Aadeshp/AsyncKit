//
//  ViewController.swift
//  AsyncKit
//
//  Created by aadesh on 05/25/2016.
//  Copyright (c) 2016 aadesh. All rights reserved.
//

import UIKit
import AsyncKit

class ViewController: UIViewController {
    func test() -> Task<String> {
        let manager: TaskManager<String> = TaskManager()
        
        let q: dispatch_queue_t = dispatch_queue_create("com.task.background", nil)
        dispatch_async(q) {
            NSLog("Async Start")
            
            NSThread.sleepForTimeInterval(5.0)
            
            // Success
            manager.complete("Success")
            
            // Fail With Error
            // manager.completeWithError(NSError())
            
            // Fail With Exception
            // manager.completeWithException(NSException())
            
            // Cancel
            // manager.cancel()
            
            NSLog("Async End")
        }
        
        return manager.task
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test().then(.Current) { (result: String) -> String in
            NSLog("1: Is Main Thread?: \(NSThread.currentThread().isMainThread)")
            NSLog("1: Result: \(result)")
            
            return "Done With First Then"
            }.then { (result: String) -> Void in
                NSLog("2: Is Main Thread?: \(NSThread.currentThread().isMainThread)")
                NSLog("2: Result: \(result)")
            }.error { (error: NSError) -> Void in
                NSLog("Error: \(error)")
            }.error { (ex: NSException) -> Void in
                NSLog("Exception: \(ex)")
            }.finally {
                NSLog("Finally")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

