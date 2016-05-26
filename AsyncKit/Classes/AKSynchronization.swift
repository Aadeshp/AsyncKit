//
//  AsyncKit
//  AKSynchronization.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import UIKit

public func synchronized(lock: AnyObject!, @noescape block: () -> Void) {
    objc_sync_enter(lock)
    block()
    objc_sync_exit(lock)
}

public func synchronized<T>(lock: AnyObject!, @noescape block: () -> T?) -> T? {
    objc_sync_enter(lock)
    let result: T? = block()
    objc_sync_exit(lock)
    
    return result
}
