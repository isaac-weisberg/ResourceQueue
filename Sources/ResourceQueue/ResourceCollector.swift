//
//  ResourceCollector.swift
//  ResourceQueue
//
//  Created by Isaac Weisberg on 5/19/18.
//  Copyright © 2018 Isaac Weisberg. All rights reserved.
//

public typealias ResourceCollector<Input, Output> = GenericResourceCollector<Input, String, Output>

public class GenericResourceCollector<Input, Key: Hashable, Output> {
    public typealias Converter = (Input) -> Key
    public typealias Creator = (Input) -> Output
    
    public let queue: ResourceQueue<Key, Output>
    
    public init(length: Int = 10, _ keyConverter: @escaping Converter, _ creator: @escaping Creator) {
        self.queue = ResourceQueue<Key, Output>(withLengthOf: length)
        self.creator = creator
        self.converter = keyConverter
    }
    
    public var converter: Converter
    public var creator: Creator
    
    public func request(_ input: Input) -> Output {
        let key = converter(input)
        if let res = queue.dequeue(at: key) {
            return res
        }
        
        let result = creator(input)
        queue.enqueue(resource: result, for: key)
        return result
    }
    
    public func clean() {
        queue.clean()
    }
}
