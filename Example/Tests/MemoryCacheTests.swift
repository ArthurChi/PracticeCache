//
//  MemoryCacheTests.swift
//  PracticeCache_Tests
//
//  Created by Vassily on 2018/9/29.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import PracticeCache

class MemoryCacheTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_memory_contain_thread_safe() {
        var memoryCache = MemoryCache<String, User>()
        
        let ext = self.expectation(description: "ext")
        
        let exeCount = 10000
        
        DispatchQueue.concurrentPerform(iterations: exeCount) { (index) in
            
            let user = User(isActive: true, account: Account(alias: "test\(index)"))
            memoryCache.save(value: user, for: "abc\(index)")
            print("write is \(index)")
            
            DispatchQueue.global().async {
                print("read is \(index)")
                let _ = memoryCache.query(key: "abc\(index)")
                if index == exeCount - 1 {
                    ext.fulfill()
                }
            }
        }
        
        wait(for: [ext], timeout: 200)
    }
    
    func test_lru_query_trail() {
        var memoryCache = MemoryCache<String, User>()
        
        let key = "1"
        let key1 = "2"
        
        let nilUser = memoryCache.query(key: key)
        XCTAssertNil(nilUser)
        
        let user = User(isActive: true, account: Account(alias: "test123"))
        memoryCache.save(value: user, for: key)
        
        let user1 = User(isActive: true, account: Account(alias: "test456"))
        memoryCache.save(value: user1, for: key1)
        let u = memoryCache.query(key: key)
        let firstUser = memoryCache.firstObject
        XCTAssertNotNil(u)
        XCTAssertNotNil(firstUser)
        XCTAssertEqual(u, firstUser)
    }
    
    func test_lru_query_not_trail() {
        var memoryCache = MemoryCache<String, User>()
        
        let key = "1"
        let key1 = "2"
        let key2 = "3"
        
        let nilUser = memoryCache.query(key: key)
        XCTAssertNil(nilUser)
        
        let user = User(isActive: true, account: Account(alias: "test123"))
        memoryCache.save(value: user, for: key)
        
        let user1 = User(isActive: true, account: Account(alias: "test456"))
        memoryCache.save(value: user1, for: key1)
        
        let user2 = User(isActive: true, account: Account(alias: "test789"))
        memoryCache.save(value: user2, for: key2)
        
        let u = memoryCache.query(key: key1)
        let firstUser = memoryCache.firstObject
        XCTAssertNotNil(u)
        XCTAssertNotNil(firstUser)
        XCTAssertEqual(u, firstUser)
    }

}
