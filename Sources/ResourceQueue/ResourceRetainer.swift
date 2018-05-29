//
//  ResourceRetainer.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 5/28/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import Foundation

public class ResourceRetainer<Handle: Hashable> {
    public typealias Releaser = () -> Void
    public typealias SimpleSetupper = (@escaping Releaser) -> Void
    public typealias Setupper<ResourceType> = (Handle, ResourceType, @escaping Releaser) -> Void
    
    private var dictionary: [Handle: Any]
    
    public init() {
        dictionary = [:]
    }
    
    public func retained<Object>(with handle: Handle) -> Object? {
        return dictionary[handle] as? Object
    }
    
    public func retain<Object>(_ resource: Object, with handle: Handle, releaseSetup: @escaping Setupper<Object>) {
        prepare(resource, with: handle) { releaser in
            releaseSetup(handle, resource, releaser)
        }
    }
    
    public func retain<Object>(_ resource: Object, with handle: Handle, simpleSetup: @escaping SimpleSetupper) {
        prepare(resource, with: handle) { releaser in
            simpleSetup(releaser)
        }
    }
    
    private func prepare<Object>(_ resource: Object, with handle: Handle, _ actions: (@escaping Releaser) -> Void) {
        unhandling(handle) { releaser in
            retain(resource, with: handle)
            actions(releaser)
        }
    }
    
    internal func retain<Object>(_ resource: Object, with handle: Handle) {
        dictionary[handle] = resource
    }
    
    @discardableResult
    internal func unhandling<Object>(_ handle: Handle, _ actions: (@escaping Releaser) -> Object) -> Object {
        let releaser = {[weak self] in
            self?.dictionary[handle] = nil
            return
        }
        return actions(releaser)
    }
}
