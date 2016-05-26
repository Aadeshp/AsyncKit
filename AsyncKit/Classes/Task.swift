//
//  AsyncKit
//  Task.swift
//
//  Copyright (c) 2016 Aadesh Patel. All rights reserved.
//
//

import Foundation

public func task<T>(block: () throws -> T) -> Task<T> {
    let manager = TaskManager<T>()
    
    let executor = Executor(type: .Async)
    executor.execute {
        do {
            let ret = try block()
            manager.complete(ret)
        } catch {
            manager.completeWithError(error)
        }
    }
    
    return manager.task
}

public class TaskResultWrapper<T> {
    private var result: T!
    
    public init(result: T) {
        self.result = result
    }
}

/// Generic result of a Task object
/// - Success
/// - Failure with NSError
/// - Failure with NSException
/// - Canceled
public enum TaskResult<T> {
    /// Task completed successfully
    case Success(TaskResultWrapper<T>)
    
    /// Task failed with an error
    case FailWithError(NSError)
    
    /// Task failed with an error type
    case FailWithErrorType(ErrorType)
    
    /// Task failed with an exception
    case FailWithException(NSException)
    
    /// Task was canceled
    case Cancel
    
    public var isSuccess: Bool {
        get {
            switch(self) {
            case .Success:
                return true
            default:
                return false
            }
        }
    }
    
    public var isFail: Bool {
        get {
            switch(self) {
            case .FailWithError:
                return true
            case .FailWithErrorType:
                return true
            case .FailWithException:
                return true
            default:
                return false
            }
        }
    }
    
    public var isCancel: Bool {
        get {
            switch(self) {
            case .Cancel:
                return true
            default:
                return false
            }
        }
    }
    
    public var result: T! {
        get {
            switch(self) {
            case let .Success(r):
                return r.result
            default:
                return nil
            }
        }
    }
    
    public var error: NSError! {
        get {
            switch(self) {
            case let .FailWithError(e):
                return e
            default:
                return nil
            }
        }
    }
    
    public var errorType: ErrorType! {
        get {
            switch(self) {
            case let .FailWithErrorType(e):
                return e
            default:
                return nil
            }
        }
    }
    
    public var exception: NSException! {
        get {
            switch(self) {
            case let .FailWithException(e):
                return e
            default:
                return nil
            }
        }
    }
}

public class Task<T> {
    public var result: TaskResult<T>!
    private var callbackQueue: TaskQueue<((TaskResult<T>) -> Void)>?
    private var callbacks: [(TaskResult<T>) -> Void]!
    //private var errorBlock: ((NSError) -> Void)!
    
    public init() {
        self.callbacks = []
    }
    
    public func completeWithResult(result: TaskResult<T>) {
        self.completeWithBlock({ () -> TaskResult<T> in
            return result
        })
    }
    
    private func completeWithBlock(block: (() -> TaskResult<T>)) {
        synchronized(self) {
            if (self.result != nil) {
                return
            }
            
            self.result = block()
            for callback in self.callbacks {
                callback(self.result)
            }
        }
    }
    
    public func then<K>(executorType: ExecutorType = ExecutorType.Current, _ block: ((T) -> Task<K>)) -> Task<K> {
        let manager = TaskManager<K>()
        
        self.then(executorType) { (ret: T) in
            let nextTask = block(ret)
            
            nextTask.then { ret2 in
                manager.complete(ret2)
            }.error { (error: NSError) in
                manager.completeWithError(error)
            }.error { (error: ErrorType) in
                manager.completeWithError(error)
            }.error { (ex: NSException) in
                manager.completeWithException(ex)
            }
        }
        
        return manager.task
    }
    
    public func then<K>(executorType: ExecutorType = ExecutorType.Current, _ block: ((T) -> K)) -> Task<K> {
        let executor: Executor = Executor(type: executorType)
        
        return self.thenWithResultBlock(executor) { (t: T) -> TaskResult<K> in
            return TaskResult<K>.Success(TaskResultWrapper(result: block(t)))
        }
    }
    
    private func thenWithResultBlock<K>(executor: Executor, _ block: (T) -> TaskResult<K>) -> Task<K> {
        return self.taskForBlock(executor) { (result: TaskResult<T>) -> TaskResult<K> in
            switch(result) {
            case .Success:
                return block(result.result)
            case .FailWithError:
                return .FailWithError(result.error)
            case .FailWithErrorType:
                return .FailWithErrorType(result.errorType)
            case .FailWithException:
                return .FailWithException(result.exception)
            case .Cancel:
                return .Cancel
            }
        }
    }
    
    public func error(block: (NSError) -> Void) -> Task<T> {
        self.queueTaskCallback { (result: TaskResult<T>) -> Void in
            if (result.error != nil) {
                block(result.error)
            }
        }
        
        return self
    }
    
    public func error(block: (NSException) -> Void) -> Task<T> {
        self.queueTaskCallback { (result: TaskResult<T>) -> Void in
            if (result.exception != nil) {
                block(result.exception)
            }
        }
        
        return self
    }
    
    public func finally(block: () -> Void) -> Task<T> {
        self.queueTaskCallback { (_: TaskResult<T>) -> Void in
            block()
        }
        
        return self
    }
    
    private func taskForBlock<K>(executor: Executor, _ block: (TaskResult<T>) -> TaskResult<K>) -> Task<K> {
        let taskManager: TaskManager<K> = TaskManager<K>()
        let taskCallback: ((TaskResult<T>) -> Void) = { (result: TaskResult<T>) -> Void in
            taskManager.complete(block(result))
            
            return
        }
        
        let execBlock = executor.executionBlock(taskCallback)
        self.queueTaskCallback(execBlock)
        
        return taskManager.task
    }
    
    private func queueTaskCallback(callback: (TaskResult<T>) -> Void) {
        synchronized(self) {
            if (self.result != nil) {
                callback(self.result)
                return
            }
            
            self.callbacks.append(callback)
        }
    }
}

extension Task {
    /**
     Converts this instance of Task to Task<Void>
     
     - returns: Task<Void> of this instance of Task
     */
    private func toVoidTask() -> Task<Void> {
        return self.then { _ -> Void in }
    }
}

/// Static functions to use with Tasks
extension Task {
    /**
     Executes multiple tasks simultaneously and returns void Task object
     that only becomes available when all input tasks are completed
     
     - parameter tasks: Tasks to complete simultaneously
     
     - returns: Void Task object that becomes available only when all input tasks
     have been completed
     */
    public static func join(tasks: Task...) -> Task<Void> {
        let manager = TaskManager<Void>()
        
        guard tasks.count > 0 else {
            manager.complete()
            return manager.task
        }
        
        let numTasks = Atomic<Int>(tasks.count)
        let numErrors = Atomic<Int>(0)
        
        tasks.forEach { task in
            task.then(.Current) { (Void) -> Void in
                
            }.error { (error: NSError) in
                numErrors.value += 1
            }.error { (error: ErrorType) in
                numErrors.value += 1
            }.error { (ex: NSException) in
                numErrors.value += 1
            }.finally {
                numTasks.value -= 1
                guard numTasks.value == 0 else { return }
                    
                if (numErrors.value > 0) {
                    manager.completeWithError(NSError(domain: "Task Error", code: 0, userInfo: nil))
                } else {
                    manager.complete()
                }
            }
        }
        
        return manager.task
    }
    
    /*public static func join<T, U, V>(taskT: Task<T>, _ taskU: Task<U>, _ taskV: Task<V>)-> Task<(T, U, V)> {
     let manager = TaskManager<(T, U, V)>()
     var ret: (T, U, V)!
     
     let numTasks = Atomic<Int>(3)
     let numErrors = Atomic<Int>(0)
     
     taskT.then(.Current) { taskRet in
     ret.0 = taskRet
     }.error { (error: NSError) in
     numErrors.value += 1
     }.finally {
     numTasks.value -= 1
     guard numTasks.value == 0 else { return }
     
     if (numErrors.value > 0) {
     manager.completeWithError(NSError(domain: "Task Error", code: 0, userInfo: nil))
     } else {
     manager.complete(ret)
     }
     }
     
     taskU.then(.Current) { taskRet in
     ret.1 = taskRet
     }.error { (error: NSError) in
     numErrors.value += 1
     }.finally {
     numTasks.value -= 1
     guard numTasks.value == 0 else { return }
     
     if (numErrors.value > 0) {
     manager.completeWithError(NSError(domain: "Task Error", code: 0, userInfo: nil))
     } else {
     manager.complete(ret)
     }
     }
     
     taskV.then(.Current) { taskRet in
     ret.2 = taskRet
     }.error { (error: NSError) in
     numErrors.value += 1
     }.finally {
     numTasks.value -= 1
     guard numTasks.value == 0 else { return }
     
     if (numErrors.value > 0) {
     manager.completeWithError(NSError(domain: "Task Error", code: 0, userInfo: nil))
     } else {
     manager.complete(ret)
     }
     }
     
     /*let tasks = [taskT, taskU, taskV]
     tasks.forEach { task in
     task.then(.Current) { ret in
     
     }.error { (error: NSError) in
     numErrors.value += 1
     }.finally {
     numTasks.value -= 1
     guard numTasks.value == 0 else { return }
     
     if (numErrors.value > 0) {
     manager.completeWithError(NSError(domain: "Task Error", code: 0, userInfo: nil))
     } else {
     manager.complete()
     }
     }
     }*/
     
     return manager.task
     }*/
    
    /*
     private static func join<U>(tasks: [Task<U>]) -> Task<Void> {
     return self.join(tasks)
     }
     
     public static func join<U, V>(taskT: Task<U>, _ taskK: Task<V>) -> Task<(U, V)> {
     let manager = TaskManager<(U, V)>()
     
     Task.join([taskT.toVoidTask(), taskK.toVoidTask()]).then {
     manager.complete((taskT.result.result, taskK.result.result))
     }
     
     return manager.task
     }
     
     public static func join<U, V, W>(taskT: Task<U>, _ taskK: Task<V>, _ taskU: Task<W>) -> Task<(U, V, W)> {
     let manager = TaskManager<(U, V, W)>()
     
     Task.join([taskT.toVoidTask(), taskK.toVoidTask(), taskU.toVoidTask()]).then {
     manager.complete((taskT.result.result, taskK.result.result, taskU.result.result))
     }
     
     return manager.task
     }*/
}
