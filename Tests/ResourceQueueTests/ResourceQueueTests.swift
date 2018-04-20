//
//  ResourceQueueTests.swift
//  ResourceQueueTests
//
//  Created by Isaac Weisberg on 4/20/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import XCTest
@testable import ResourceQueue

class ResourceQueueTests: XCTestCase {
    func testQueueRecovery() {
        let samples = [
            ("Donkey", 1567),
            ("Lowkey", 45),
            ("Honkey", 13567)
        ]
        
        let oddSample = (key: "Howkey", value: 13565)
        
        let queue: ResourceQueue<String, Int> = .init(withLengthOf: samples.count)
        
        samples.forEach { key, value in
            queue.enqueue(resource: value, for: key)
        }
        
        XCTAssertTrue(queue.queue.count == samples.count, "Should be of same length as initial samples")
        
        queue.enqueue(resource: oddSample.value, for: oddSample.key)
        
        XCTAssertTrue(queue.queue.count == samples.count, "Should still be of very same length")
        
        let value = queue.dequeue(at: samples[0].0)
        
        XCTAssertNil(value, "Should not return the first object because it has been dequeued during the recovering cycle.")
    }
    
    func testQueueSuddenLengthChanges() {
        let initialSamples = { () -> [(key: String, value: Int)] in
            var array = [(key: String, value: Int)]()
            for index in 0...60 {
                array.append((key: "\(index)", value: index))
            }
            return array
        }()
        
        let queue: ResourceQueue<String, Int> = .init(withLengthOf: initialSamples.count)
        
        initialSamples.forEach { key, value in
            queue.enqueue(resource: value, for: key)
        }
        
        XCTAssertTrue(queue.queue.count == initialSamples.count, "Should be of same length as initial samples")
        
        let newLength = 20
        
        queue.setLength(newLength)
        
        XCTAssertTrue(queue.queue.count == newLength, "Should be of same length as new length")
    }
}
