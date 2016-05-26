//
//  AsyncKit
//  SpinLock.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import Foundation

/// Wrapper class for OSSpinLock, used for locks and synchronization
internal final class SpinLock {
    /// Local OSSpinLock
    private var spinLock: Int32 = OS_SPINLOCK_INIT
    
    internal init() {
        
    }
    
    /// Locks spinlock
    internal func lock() {
        withUnsafeMutablePointer(&self.spinLock, OSSpinLockLock)
    }
    
    /// Unlocks spinlock
    internal func unlock() {
        withUnsafeMutablePointer(&self.spinLock, OSSpinLockUnlock)
    }
    
    /**
     Performs the input block as a synchronized block, that returns
     some generic value specified.
     
     - parameter block: Block to execute within the scope of the lock
     
     - returns: Block's return value
     */
    internal func lock<T>(block: () -> T) -> T {
        self.lock()
        defer { self.unlock() }
        let ret = block()
        
        return ret
    }
}
