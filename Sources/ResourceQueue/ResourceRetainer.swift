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
    
    public func retain(_ resource: Resource, with handle: Handle, releaseSetup: Setupper) {
        retain(resource, with: handle) {
            releaseSetup(handle, resource, unhandle(handle))
        }
    }
    
    public func retain(_ resource: Resource, with handle: Handle, simpleSetup: (@escaping Releaser) -> Void) {
        retain(resource, with: handle) {
            simpleSetup(unhandle(handle))
        }
    }
    
    private func retain(_ resource: Resource, with handle: Handle, doingStuff: () -> Void) {
        dictionary[handle] = resource
        doingStuff()
    }
    
    private func unhandle(_ handle: Handle) -> () -> Void {
        return {[weak self] in
            self?.dictionary[handle] = nil
        }
    }
}
