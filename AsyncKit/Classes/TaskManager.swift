
//
//  AsyncKit
//  TaskManager.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import Foundation

public class TaskManager<T> {
    private(set) public var task: Task<T>
    
    public init() {
        self.task = Task()
    }
    
    public func complete(result: T) {
        synchronized(self) {
            self.task.completeWithResult(.Success(TaskResultWrapper(result: result)))
        }
    }
    
    public func complete(result: TaskResult<T>) {
        synchronized(self) {
            self.task.completeWithResult(result)
        }
    }
    
    public func completeWithError(error: NSError) {
        synchronized(self) {
            self.task.completeWithResult(.FailWithError(error))
        }
    }
    
    public func completeWithError(error: ErrorType) {
        synchronized(self) {
            self.task.completeWithResult(.FailWithErrorType(error))
        }
    }
    
    public func completeWithException(exception: NSException) {
        synchronized(self) {
            self.task.completeWithResult(.FailWithException(exception))
        }
    }
    
    public func cancel() {
        synchronized(self) {
            self.task.completeWithResult(.Cancel)
        }
    }
}
