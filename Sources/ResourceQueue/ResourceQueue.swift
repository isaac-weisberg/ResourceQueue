//
//  ResourceQueue.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 4/20/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

public class GenericResourceQueue<Handle: Hashable> {
    typealias Entry = (Handle, Any)

    internal var queue: [Entry] = []
    internal var queueLength: Int
    
    public init(withLengthOf length: Int = 10) {
        queueLength = length
    }
    
    internal func recover() {
        if queue.count > queueLength {
            let diff = queue.count - queueLength
            queue.removeSubrange(0..<diff)
        }
    }
    
    ///
    /// Change the storage length, releasing oldest references to resources.
    ///
    public func setLength(_ length: Int) {
        queueLength = length
        recover()
    }
    
    ///
    /// Enqueue a resource for strong retention at a hashable handle.
    ///
    /// - parameters:
    ///     - resource: a resource to be enqueued.
    ///     - handle: a handle to be used to remember the resource.
    ///
    public func enqueue<Resource>(resource: Resource, for handle: Handle) {
        queue.append((handle, resource))
        recover()
    }
    
    ///
    /// Dequeue a resource at a hashable handle without removing it from strongly retained queue.
    ///
    public func dequeue<Resource>(at handle: Handle) -> Resource? {
        guard let resource = queue.first(where: { $0.0 == handle })?.1 else {
            return nil
        }
        guard let actualResource = resource as? Resource else {
            remove(at: handle)
            return nil
        }
        return actualResource
    }
    
    ///
    /// Remove all strong references to enqueued resources.
    ///
    public func clean() {
        queue.removeAll(keepingCapacity: true)
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

public class ResourceQueue<Handle: Hashable, Resource>: GenericResourceQueue<Handle> {
    ///
    /// Enqueue a resource for strong retention at a hashable handle.
    ///
    /// - parameters:
    ///     - resource: a resource to be enqueued.
    ///     - handle: a handle to be used to remember the resource.
    ///
    public func enqueue(resource: Resource, for handle: Handle) {
        return enqueue(resource: resource, for: handle)
    }
    
    ///
    /// Dequeue a resource at a hashable handle without removing it from strongly retained queue.
    ///
    public func dequeue(at handle: Handle) -> Resource? {
        return dequeue(at: handle)
    }
}
