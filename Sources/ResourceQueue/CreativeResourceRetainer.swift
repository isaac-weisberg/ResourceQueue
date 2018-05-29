//
//  CreativeResourceRetainer.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 5/28/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import Foundation

public typealias CreativeResourceRetainer<Input, Output> = GenericCreativeResourceRetainer<Input, String>

public class CreativeResourceRetainerStringed<Output>: GenericCreativeResourceRetainer<String, String> {
    public init<Object>(_ creator: @escaping Creator<Object>) {
        super.init({$0}, creator)
    }
}

public class GenericCreativeResourceRetainer<Input, Key: Hashable> {
    public typealias Transformer = (Input) -> Key
    public typealias Creator<Object> = (Input, Key, @escaping ResourceRetainer<Key>.Releaser) -> Object
    
    private let retainer = ResourceRetainer<Key>()
    
    private let transformer: Transformer
    private let creator: Creator<Any>
    
    public init<Object>(_ transformer: @escaping Transformer, _ creator: @escaping Creator<Object>) {
        self.transformer = transformer
        self.creator = creator
    }
    
    public func request<Object>(_ input: Input) -> Object {
        let key = transformer(input)
        if let output: Object = retainer.retained(with: key) {
            return output
        }
        let output = retainer.unhandling(key) { releaser -> Object in
            // I am terrified by the unsafety of this code.
            creator(input, key, releaser) as! Object
        }
        retainer.retain(output, with: key)
        return output
    }
}
