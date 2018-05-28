//
//  ResourceRetainer.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 5/28/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import Foundation

public class ResourceRetainer<Handle: Hashable, Resource> {
    public typealias Releaser = () -> Void
    public typealias Setupper = (Handle, Resource, @escaping Releaser) -> Void
    
    private var dictionary = [Handle: Resource]()
    
    public func retained(with handle: Handle) -> Resource? {
        return dictionary[handle]
    }
    
    public func retain(_ resource: Resource, with handle: Handle, releaseSetup: @escaping Setupper) {
        unhandling(handle) { releaser in
            retain(resource, with: handle) {
                releaseSetup(handle, resource, releaser)
            }
        }
    }
    
    public func retain(_ resource: Resource, with handle: Handle, simpleSetup: @escaping (@escaping Releaser) -> Void) {
        unhandling(handle) { releaser in
            retain(resource, with: handle) {
                simpleSetup(releaser)
            }
        }
    }
    
    internal func retain(_ resource: Resource, with handle: Handle, doingStuff: (Releaser)? = nil) {
        dictionary[handle] = resource
        doingStuff?()
    }
    
    internal func unhandling(_ handle: Handle, _ actions: (@escaping Releaser) -> Void) {
        let releaser = unhandler(for: handle)
        actions(releaser)
    }
    
    internal func unhandler(for handle: Handle) -> Releaser {
        return {[weak self] in
            self?.dictionary[handle] = nil
        }
    }
}
