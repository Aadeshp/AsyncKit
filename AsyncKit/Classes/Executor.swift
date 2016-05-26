//
//  AsyncKit
//  Executor.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import UIKit

/// Service that executes a block in the specified executor queue
public class Executor {
    /// Queue to execute block in
    private var type: ExecutorType!
    
    public init(type: ExecutorType) {
        self.type = type
    }
    
    /**
     Executes block within the queue specified
     
     - parameter type: Executor queue to execute block in
     - parameter block: Block to execute
     */
    public func execute(type: ExecutorType!, block: dispatch_block_t) {
        let _ = self.executionBlock(block)
    }
    
    public func executionBlock<T>(block: (T) -> Void) -> ((T) -> Void) {
        let wrappedBlock = { (t: T) -> Void in
            block(t)
        }
        
        switch(self.type!) {
        case .Current:
            return block
        default:
            return self.createDispatchBlock(self.type.queue, block: wrappedBlock)
        }
    }
    
    private func createDispatchBlock<T>(queue: AKQueue, block: (T) -> Void) -> ((T) -> Void)
    {
        let wrappedBlock = { (t: T) -> Void in
            queue.async {
                block(t)
            }
        }
        
        return wrappedBlock
    }
}

/// Queue executor enum
public enum ExecutorType {
    /// Main Queue
    case Main
    
    /// Queue used in previous task block
    case Current
    
    /// Default priority global queue
    case Async
    
    /// Custom queue
    case Queue(dispatch_queue_t)
    
    /// Gets queue object based on ExecutorType
    public var queue: AKQueue {
        get {
            switch(self) {
            case .Main:
                return AKQueue.main
            case let .Queue(queue):
                return AKQueue(queue)
            default:
                return AKQueue.def
            }
        }
    }
}
