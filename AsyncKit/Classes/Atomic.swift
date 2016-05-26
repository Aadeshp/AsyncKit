//
//  AsyncKit
//  Atomic.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import Foundation

/// Generic atomic variable class
public class Atomic<T> {
    /// Local lock for synchronization
    private let lock = SpinLock()
    
    /// Wrapper class so that any data type can be represented as
    /// an object
    private var wrappedValue: AtomicValueWrapper<T>!
    
    /// Sets/gets current value atomically
    public var value: T {
        get {
            return self.lock.lock {
                return self.wrappedValue.value
            }
        }
        set {
            self.lock.lock()
            defer { self.lock.unlock() }
            self.wrappedValue = AtomicValueWrapper(newValue)
        }
    }
    
    /**
     Initialize atomic variable with value
     */
    init(_ value: T) {
        self.value = value
    }
    
    /**
     Atomically performs input block which has an input of this atomic
     variable's value.
     
     - parameter block: Block to execute atomically with the current value
     
     - returns: Result of the execution of the block
     */
    func atomically<K>(block: T -> K) -> K {
        return self.lock.lock {
            return block(self.wrappedValue.value)
        }
    }
    
    /**
     Atomically performs input block which has an input of this atomic
     variable's value.
     
     - parameter block: Block to execute atomically with the current value
     */
    func atomically(block: T -> Void) {
        self.lock.lock()
        defer { self.lock.unlock() }
        block(self.wrappedValue.value)
    }
    
    /**
     Atomically returns the current value before updating the value
     
     - returns: Current value before updating with new value
     */
    func getAndSet(value: T) -> T {
        self.lock.lock()
        defer { self.lock.unlock() }
        let ret = self.wrappedValue.value
        self.wrappedValue.value = value
        
        return ret
    }
    
    /**
     Atomically updates the value and then returns the current value
     
     - returns: Current value after update
     */
    func setAndGet(value: T) -> T {
        self.lock.lock()
        defer { self.lock.unlock() }
        self.wrappedValue.value = value
        
        return self.wrappedValue.value
    }
}
