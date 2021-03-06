//
//  ResourceQueue.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 4/20/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import Foundation

public protocol ResourceQueueProtocol: class {
    associatedtype Handle: Hashable

    typealias Entry = (Handle, Any)

    var semaphore: DispatchSemaphore { get }

    var queue: ArraySlice<Entry> { get set }

    var queueLength: Int { get set }

    func setLength(_ length: Int)

    func clean()

    func remove(at handle: Handle)
}

extension ResourceQueueProtocol {
    func semaphoring<ReturnType>(_ actions: () -> ReturnType) -> ReturnType {
        semaphore.wait()
        let res = actions()
        semaphore.signal()
        return res
    }

    ///
    /// Change the storage length, releasing oldest references to resources.
    ///
    public func setLength(_ length: Int) {
        semaphoring {
            queueLength = length
            recover()
        }
    }

    func recover() {
        if queue.count > queueLength {
            let diff = queue.count - queueLength
            queue.removeSubrange(0..<diff)
        }
    }

    ///
    /// Remove all strong references to enqueued resources.
    ///
    public func clean() {
        semaphoring {
            queue.removeAll(keepingCapacity: true)
        }
    }

    ///
    /// Remove strong reference to an enqueued resource at handle.
    ///
    /// If there is no known resource enqueued at handle, nothing happens.
    ///
    public func remove(at handle: Handle) {
        if let index = queue.index(where: {
            $0.0 == handle
        }) {
            queue.remove(at: index)
        }
    }
}

public class GenericResourceQueue<Handle: Hashable>: ResourceQueueProtocol {
    public var semaphore = DispatchSemaphore(value: 1)

    public var queue: ArraySlice<(Handle, Any)> = ArraySlice([])
    public var queueLength: Int
    
    public init(withLengthOf length: Int = 10) {
        queueLength = length
    }

    ///
    /// Enqueue a resource for strong retention at a hashable handle.
    ///
    /// - parameters:
    ///     - resource: a resource to be enqueued.
    ///     - handle: a handle to be used to remember the resource.
    ///
    public func enqueue<Resource>(resource: Resource, for handle: Handle) {
        semaphoring {
            queue.append((handle, resource))
            recover()
        }
    }
    
    ///
    /// Dequeue a resource at a hashable handle without removing it from strongly retained queue.
    ///
    public func dequeue<Resource>(at handle: Handle) -> Resource? {
        return semaphoring { () -> Resource? in
            guard let resource = queue.first(where: { $0.0 == handle })?.1 else {
                return nil
            }
            guard let actualResource = resource as? Resource else {
                remove(at: handle)
                return nil
            }
            return actualResource
        }
    }
}

public class ResourceQueue<Handle: Hashable, Resource>: ResourceQueueProtocol {
    public var semaphore = DispatchSemaphore(value: 1)

    public var queue: ArraySlice<(Handle, Any)> = ArraySlice([])
    public var queueLength: Int

    public init(withLengthOf length: Int = 10) {
        queueLength = length
    }

    ///
    /// Enqueue a resource for strong retention at a hashable handle.
    ///
    /// - parameters:
    ///     - resource: a resource to be enqueued.
    ///     - handle: a handle to be used to remember the resource.
    ///
    public func enqueue(resource: Resource, for handle: Handle) {
        semaphoring {
            queue.append((handle, resource))
            recover()
        }
    }
    
    ///
    /// Dequeue a resource at a hashable handle without removing it from strongly retained queue.
    ///
    public func dequeue(at handle: Handle) -> Resource? {
        return semaphoring { () -> Resource? in
            guard let res = queue.first(where: { $0.0 == handle })?.1 else {
                return nil
            }
            return (res as! Resource)
        }
    }
}
