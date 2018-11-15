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

struct User: Codable, Equatable {
    var isActive: Bool
    var account: Account
    var key: String = ""
    
    init(isActive: Bool, account: Account) {
        self.isActive = isActive
        self.account = account
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return
            lhs.account.alias == rhs.account.alias &&
                lhs.isActive == rhs.isActive
    }
}
