//
//  CreativeResourceRetainer.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 5/28/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import Foundation

public typealias CreativeResourceRetainer<Input, Output> = GenericCreativeResourceRetainer<Input, String, Output>

public class CreativeResourceRetainerStringed<Output>: GenericCreativeResourceRetainer<String, String, Output> {
    public init(_ creator: @escaping Creator) {
        super.init({$0}, creator)
    }
}

public class GenericCreativeResourceRetainer<Input, Key: Hashable, Output> {
    public typealias Transformer = (Input) -> Key
    public typealias Creator = (Input, Key, @escaping ResourceRetainer<Key, Output>.Releaser) -> Output
    
    private let retainer = ResourceRetainer<Key, Output>()
    
    private let transformer: Transformer
    private let creator: Creator
    
    public init(_ transformer: @escaping Transformer, _ creator: @escaping Creator) {
        self.transformer = transformer
        self.creator = creator
    }
    
    public func request(_ input: Input) -> Output {
        let key = transformer(input)
        if let output = retainer.retained(with: key) {
            return output
        }
        let output = retainer.unhandling(key) { releaser -> Output in
            creator(input, key, releaser)
        }
        retainer.retain(output, with: key)
        return output
    }
}
