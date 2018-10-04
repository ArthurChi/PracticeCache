//
//  MockMemoryCache.swift
//  PracticeCache_Example
//
//  Created by Vassily on 2018/9/29.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import PracticeCache

struct MockMemoryCache<K, V>: MemoryCacheable where K: Hashable, V: Codable {
    typealias Key = K
    typealias ValueType = V
    
    private var dict = [K:V]()
    
    func containsObject(key: K) -> Bool {
        return dict.contains(where: { $0.key == key })
    }
    
    func query(key: K) -> V? {
        return dict[key]
    }
    
    func save(value: V, for key: K) {
        
    }
    
    func remove(key: K) {
        
    }
    
    func removeAll() {
        
    }
}
