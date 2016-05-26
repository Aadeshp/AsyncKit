//
//  AsyncKit
//  TaskQueue.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import UIKit

internal class TaskQueue<T> {
    internal typealias QueueMapBlock = (item: T?) -> Void
    
    private var tail: Node<T>?
    private(set) public var count: Int = 0
    
    internal init() {
        self.tail = nil
    }
    
    internal func enqueue(item: T) {
        self.count += 1
        
        if (self.tail == nil) {
            self.tail = Node(value: item, next: self.tail)
            
            return
        }
        
        let temp: Node<T> = Node(value: item, next: tail?.next)
        self.tail?.next = temp
        self.tail = temp
    }
    
    internal func dequeue() -> T? {
        let result: T? = tail?.next?.value
        tail?.next = tail?.next?.next
        
        self.count -= 1
        
        return result
    }
    
    internal func map(block: QueueMapBlock) {
        if (self.count == 0) {
            return
        }
        
        if (self.count == 1) {
            block(item: tail?.value)
            
            return
        }
        
        var head: Node<T>? = tail?.next
        
        for _ in 0..<self.count {
            block(item: head?.value)
            
            head = head?.next
        }
    }
    
    internal func clear() {
        self.tail = nil
        self.count = 0
    }
}

private class Node<T> {
    var value: T?
    var next: Node?
    
    init(value: T?, next: Node?) {
        self.value = value
        self.next = next
    }
    
    convenience init(value: T?) {
        self.init(value: value, next: nil)
    }
}
