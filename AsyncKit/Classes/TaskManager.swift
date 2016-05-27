
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
    
    /**
     Completes the task successfully with the result provided
     
     - parameter result: Value to complete the task successfully with
     */
    public func complete(result: T) {
        synchronized(self) {
            self.task.completeWithResult(.Success(TaskResultWrapper(result: result)))
        }
    }
   
    /**
     Completes the task with the TaskResult object provided
     
     - parameter result: TaskResult object to complete the task with
     */
    public func complete(result: TaskResult<T>) {
        synchronized(self) {
            self.task.completeWithResult(result)
        }
    }
    
    /**
     Completes the task with a failure due to an error of type NSError
     
     - parameter error: NSError that caused the task to fail
     */
    public func completeWithError(error: NSError) {
        synchronized(self) {
            self.task.completeWithResult(.FailWithError(error))
        }
    }
   
    /**
     Completes the task with a failure due to an error of type ErrorType
     
     - parameter error: ErrorType that caused the task to fail
     */
    public func completeWithError(error: ErrorType) {
        synchronized(self) {
            self.task.completeWithResult(.FailWithErrorType(error))
        }
    }
   
    /**
     Completes the task with a failure due to an exception
     
     - parameter error: NSException that caused the task to fail
     */
    public func completeWithException(exception: NSException) {
        synchronized(self) {
            self.task.completeWithResult(.FailWithException(exception))
        }
    }
    
    /// Cancels the task
    public func cancel() {
        synchronized(self) {
            self.task.completeWithResult(.Cancel)
        }
    }
}
