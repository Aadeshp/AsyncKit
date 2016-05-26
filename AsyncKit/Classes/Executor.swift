//
//  AsyncKit
//  Executor.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import UIKit

/// Service that executes a block in the specified executor queue
internal class Executor {
    /// Queue to execute block in
    private var type: ExecutorType!
    
    internal init(type: ExecutorType) {
        self.type = type
    }
    
    /**
     Executes block within the queue specified
     
     - parameter type: Executor queue to execute block in
     - parameter block: Block to execute
     */
    internal func execute(block: dispatch_block_t) {
        self.executionBlock(block)()
    }
    
    internal func executionBlock<T>(block: (T) -> Void) -> ((T) -> Void) {
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
    
    private func createDispatchBlock<T>(queue: AKQueue, block: (T) -> Void) -> ((T) -> Void) {
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
    internal var queue: AKQueue {
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
