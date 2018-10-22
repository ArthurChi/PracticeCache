//
//  ViewController.swift
//  PracticeCache
//
//  Created by sun-fox-cj on 09/27/2018.
//  Copyright (c) 2018 sun-fox-cj. All rights reserved.
//

import UIKit
import PracticeCache

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var memoryCache = MemoryCache<String, User>()
        
        let exeCount = 50000
        
        DispatchQueue.concurrentPerform(iterations: exeCount) { (index) in
            
            let user = User(isActive: true, account: Account(alias: "test\(index)"))
            memoryCache.save(value: user, for: "abc\(index)")
            print("write is \(index)")
            
            print(Thread.current)
            
            DispatchQueue.global().async {
                print("read is \(index)")
                let _ = memoryCache.query(key: "abc\(index)")
            }
        }
    }
    
    
    class Account: Codable {
        var alias: String
        
        init(alias: String) {
            self.alias = alias
        }
    }
    
    struct User: Codable, Equatable {
        static func == (lhs: User, rhs: User) -> Bool {
            return
                lhs.account.alias == rhs.account.alias &&
                    lhs.isActive == rhs.isActive
        }
        
        var isActive: Bool
        var account: Account
        
        init(isActive: Bool, account: Account) {
            self.isActive = isActive
            self.account = account
        }
    }
    
}
