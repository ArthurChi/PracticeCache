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

    func test_memory_contain_thread_safe() {
        let memoryCache = MemoryCache<String, User>()
        
        let ext = self.expectation(description: "ext")
        
        let exeCount = 10000
        
        DispatchQueue.concurrentPerform(iterations: exeCount) { (index) in
            
            let user = User(isActive: true, account: Account(alias: "test\(index)"))
            memoryCache.save(value: user, for: "abc\(index)")
            print("write is \(index)")
            
            print(Thread.current)
            
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
        let memoryCache = MemoryCache<String, User>()
        
        let key = "1"
        let key1 = "2"
        
        let nilUser = memoryCache.query(key: key)
        XCTAssertNil(nilUser)
        
        let user = User(isActive: true, account: Account(alias: "test123"))
        memoryCache.save(value: user, for: key)
        
        let user1 = User(isActive: true, account: Account(alias: "test456"))
        memoryCache.save(value: user1, for: key1)
        let u = memoryCache.query(key: key)
        let firstUser = memoryCache.first
        XCTAssertNotNil(u)
        XCTAssertNotNil(firstUser)
        XCTAssertEqual(u, firstUser)
    }
    
    func test_lru_query_not_trail() {
        let memoryCache = MemoryCache<String, User>()
        
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
        let firstUser = memoryCache.first
        XCTAssertNotNil(u)
        XCTAssertNotNil(firstUser)
        XCTAssertEqual(u, firstUser)
    }

    func test_remove_by_cost() {
        let memoryCache = MemoryCache<String, User>()
        
        let key = "1"
        let key1 = "2"
        let key2 = "3"
        
        let user = User(isActive: true, account: Account(alias: "test123"))
        memoryCache.save(value: user, for: key, cost: 10)
        XCTAssert(memoryCache.totalCost == 10)
        
        let user1 = User(isActive: true, account: Account(alias: "test456"))
        memoryCache.save(value: user1, for: key1, cost: 20)
        XCTAssert(memoryCache.totalCost == 30)
        
        let user2 = User(isActive: true, account: Account(alias: "test789"))
        memoryCache.save(value: user2, for: key2, cost: 30)
        XCTAssert(memoryCache.totalCost == 60)
        
        memoryCache.trimToCost(40)
        
        XCTAssert(memoryCache.query(key: "1") == nil)
        XCTAssert(memoryCache.query(key: "2") == nil)
        XCTAssert(memoryCache.query(key: "3") != nil)
        XCTAssert(memoryCache.totalCost == 30)
    }
    
    func test_trim_by_count() {
        let memoryCache = MemoryCache<String, User>(autoTrimInterval: -1)
        
        for i in 0..<10 {
            var user = User(isActive: true, account: Account(alias: "test\(index)"))
            user.key = "\(i)"
            memoryCache.save(value: user, for: "\(i)")
        }
        
        XCTAssert(memoryCache.totalCount == 10)
        memoryCache.trimToCount(8)
        XCTAssert(memoryCache.totalCount == 8, "count is \(memoryCache.totalCount)")
        XCTAssert(memoryCache.last!.key == "2", "key is \(memoryCache.last!.key)")
    }
    
    func test_trim_by_age() {

        let memoryCache = MemoryCache<String, User>(autoTrimInterval: -1)

        for i in 0..<10 {
            let user = User(isActive: true, account: Account(alias: "test\(index)"))
            sleep(1)
            memoryCache.save(value: user, for: "\(i)")
        }

        XCTAssert(memoryCache.totalCount == 10)
        memoryCache.trimToAge(5)
        XCTAssert(memoryCache.totalCount == 5, "count is \(memoryCache.totalCount)")
    }
    
    func test_trim_by_cost() {
        let memoryCache = MemoryCache<String, User>(autoTrimInterval: -1)
        
        print(memoryCache.totalCost)
        
        for i in 0..<10 {
            let user = User(isActive: true, account: Account(alias: "test\(index)"))
            memoryCache.save(value: user, for: "\(i)", cost: i)
        }
        
        XCTAssert(memoryCache.totalCount == 10)
        memoryCache.trimToCost(9)
        XCTAssert(memoryCache.totalCount == 1, "count is \(memoryCache.totalCount)")
    }

    func test_trim_auto_thread_safe() {
        let memoryCache = MemoryCache<String, User>(countLimit: 8, autoTrimInterval: 0.2)
        
        let exeCount = 10
        let extAuto = self.expectation(description: "ext_auto")
        extAuto.expectedFulfillmentCount = exeCount

        DispatchQueue.concurrentPerform(iterations: exeCount) { (index) in

            let user = User(isActive: true, account: Account(alias: "test\(index)"))
            memoryCache.save(value: user, for: "abc\(index)")
            print("write is \(index)")

            print(Thread.current)

            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                XCTAssert(memoryCache.totalCount == 8, "count is \(memoryCache.totalCount)")
                extAuto.fulfill()
            })
        }

        wait(for: [extAuto], timeout: 200)
    }
}
