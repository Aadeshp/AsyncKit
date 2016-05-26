//
//  AsyncKit
//  AKQueue.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import UIKit

/// Wrapper class of dispatch_queue_t
public struct AKQueue {
    public static let main = AKQueue(dispatch_get_main_queue())
    public static let def = AKQueue(globalPriortyQueue: DISPATCH_QUEUE_PRIORITY_DEFAULT)
    public static let high = AKQueue(globalPriortyQueue: DISPATCH_QUEUE_PRIORITY_HIGH)
    public static let low = AKQueue(globalPriortyQueue: DISPATCH_QUEUE_PRIORITY_LOW)
    
    private(set) public var queue: dispatch_queue_t!
    
    public init(_ queue: dispatch_queue_t) {
        self.queue = queue
    }
    
    public init(globalPriortyQueue: Int) {
        self.init(dispatch_get_global_queue(globalPriortyQueue, 0))
    }
    
    public func async(block: dispatch_block_t) {
        dispatch_async(self.queue, block)
    }
    
    public func sync(block: dispatch_block_t) {
        dispatch_sync(self.queue, block)
    }
}
