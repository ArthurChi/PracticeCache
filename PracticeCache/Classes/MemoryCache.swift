//
//  MemoryCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

protocol MemoryCacheable: CacheStandard { }

struct MemoryLinkNode<V: Codable> {
    
}

struct MemoryLink<T: Codable> {
    
    var head: MemoryLinkNode<T>?
    var trail: MemoryLinkNode<T>?
    private(set) var totalCost: Int = 0
    private(set) var totalCount: Int = 0
    
    func insertNodeToHead(_ node: MemoryLinkNode<T>) {
        
    }
    
    func bringNodeToHead(_ node: MemoryLinkNode<T>) {
        
    }
    
    func removeNode(_ node: MemoryLinkNode<T>) {
        
    }
    
    func removeTrailNode() {
        
    }
    
    func removeAll() {
        
    }
}

struct MemoryCache<T: Codable> {
    typealias ValueType = T
    
    private let lock: Lock = Mutex()
    private var dict = [String : T]()
    private var link: MemoryLink<T>
    
    
    
    
}

extension MemoryCache: MemoryCacheable {
    func containsObject(key: String) -> Bool {
        return dict.contains(where: { $0.key == key })
    }
    
    func query(key: String) -> T? {
        return dict[key]
    }
    
    func save(value: T, for key: String) {
        
    }
    
    func remove(key: String) {
        
    }
    
    func removeAll() {
        
    }
    
    
}
