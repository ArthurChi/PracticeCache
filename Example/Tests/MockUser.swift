//
//  MockUser.swift
//  PracticeCache_Tests
//
//  Created by Vassily on 2018/9/30.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

class Account: Codable {
    var alias: String
    
    init(alias: String) {
        self.alias = alias
    }
}

struct User: Codable {
    var isActive: Bool
    var account: Account
    
    init(isActive: Bool, account: Account) {
        self.isActive = isActive
        self.account = account
    }
}
