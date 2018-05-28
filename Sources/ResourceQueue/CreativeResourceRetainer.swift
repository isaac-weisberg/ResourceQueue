//
//  CreativeResourceRetainer.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 5/28/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import Foundation

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
        let output = creator(input, key, retainer.unhandler(for: key))
        retainer.retain(output, with: key)
        return output
    }
}
