//
//  ResourceRetainerTests.swift
//  ResourceQueueTests
//
//  Created by Isaac Weisberg on 5/29/18.
//  Copyright © 2018 isaac-weisberg. All rights reserved.
//

import XCTest
@testable import ResourceQueue

class ResourceRetainerTests: XCTestCase {
    let retainer = ResourceRetainer<String>()
    
    func testRegularObject() {
        let key = "Piece"
        let piece = Piece()
        retainer.retain(piece, with: key) { release in
            DispatchQueue.main.async {
                release()
            }
        }
        
        guard let retained: Piece = retainer.retained(with: key) else {
            XCTFail("How comes, I just retained it.")
            return
        }
        
        XCTAssert(retained === piece, "Should be same object")
    }
    
    func testGenericObject() {
        let key = "Thingie"
        let piece = Thing(123)
        retainer.retain(piece, with: key) { release in
            DispatchQueue.main.async {
                release()
            }
        }
        
        guard let retained: Thing<Int> = retainer.retained(with: key) else {
            XCTFail("How comes, I just retained it.")
            return
        }
        
        XCTAssert(retained === piece, "Should be same object")
    }
}

class Piece {
    let porsche = "911"
}

class Thing<Type> {
    let th: Type
    init(_ th: Type) {
        self.th = th
    }
}

