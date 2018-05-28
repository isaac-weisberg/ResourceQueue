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
    public typealias Setupper = (Handle, Resource, Releaser) -> Void
    
    private var dictionary = [Handle: Resource]()
    
    public func retained(with handle: Handle) -> Resource? {
        return dictionary[handle]
    }
    
    public func retain(_ resource: Resource, with handle: Handle, releaseSetup: Setupper) {
        releaseSetup(handle, resource) {
            dictionary[handle] = nil
        }
        dictionary[handle] = resource
    }
    
    public func retain(_ resource: Resource, with handle: Handle, simpleSetup: (Releaser) -> Void) {
        simpleSetup {
            dictionary[handle] = nil
        }
        dictionary[handle] = resource
    }
}
