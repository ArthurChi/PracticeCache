//
//  MemoryCacheLinkTests.swift
//  PracticeCache_Tests
//
//  Created by Vassily on 2018/10/22.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import PracticeCache

class MemoryCacheLinkTests: XCTestCase {

    func test_count() {
        let count = 30
        var link = LinkedList<String, Int>()
        for i in 0..<count {
            link.push(i, for: "\(i)")
        }
        
        XCTAssert(link.count == count)
    }
    
    func test_first() {
        let count = 30
        var link = LinkedList<String, Int>()
        for i in 0..<count {
            link.push(i, for: "\(i)")
        }
        
        XCTAssert(link.first == link["29"])
    }
    
    func test_last() {
        let count = 30
        var link = LinkedList<String, Int>()
        for i in 0..<count {
            link.push(i, for: "\(i)")
        }
        
        XCTAssert(link.last == link["0"])
    }
    
    func test_empty() {
        var link = LinkedList<String, Int>()
        XCTAssert(link.isEmpty)
        link.push(1, for: "1")
        XCTAssert(!link.isEmpty)
    }
    
    func test_bring_to_head() {
        var link = LinkedList<String, Int>()
        link.push(1, for: "1")
        link.push(2, for: "2")
        XCTAssert(link.first == 2)
        link.push(1, for: "1")
        XCTAssert(link.first == 1, "\(String(describing: link.first))")
    }
    
    func test_remove_last() {
        var link = LinkedList<String, Int>()
        link.push(1, for: "1")
        link.push(2, for: "2")
        
        XCTAssert(link.removeTrail()?.0 == "1")
    }
    
    func test_remove_all() {
        var link = LinkedList<String, Int>()
        link.push(1, for: "1")
        link.push(2, for: "2")
        link.removeAll()
        
        XCTAssert(link.isEmpty)
    }
    
    func test_remove_trail_and_isEmpty() {
        var link = LinkedList<String, Int>()
        link.push(1, for: "1")
        link.push(2, for: "2")
        
        XCTAssert(link.removeTrail()?.0 == "1")
        XCTAssert(link.removeTrail()?.0 == "2")
        
        XCTAssert(link.isEmpty)
    }
    
    func test_remove_and_isEmpty() {
        var link = LinkedList<String, Int>()
        link.push(1, for: "1")
        link.push(2, for: "2")
        
        link.remove(for: "1")
        link.remove(for: "2")
        
        XCTAssert(link.isEmpty)
    }
}
