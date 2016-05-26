//
//  AsyncKit
//  AtomicValueWrapper.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import Foundation

/// Value wrapper struct, so that any data type can be represented
/// as an object
internal struct AtomicValueWrapper<T> {
    private var value_: T!
    
    /// - returns: Current value
    internal var value: T {
        get {
            return self.value_
        }
        set {
            self.value_ = newValue
        }
    }
    
    /// Sets value
    init(_ value: T) {
        self.value = value
    }
}
