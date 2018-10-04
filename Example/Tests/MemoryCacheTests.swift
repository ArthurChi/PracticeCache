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
            print(index)
            
            DispatchQueue.global().async {
                let _ = memoryCache.query(key: "abc\(index)")
                if index == exeCount - 1 {
                    ext.fulfill()
                }
            }
        }
        
        wait(for: [ext], timeout: 200)
    }

}
