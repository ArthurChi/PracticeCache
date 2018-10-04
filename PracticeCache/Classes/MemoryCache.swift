//
//  MemoryCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

public protocol MemoryCacheable: CacheStandard { }

struct MemoryLinkNode<V: Codable> {
    var time: TimeInterval
    var cost: NSInteger
    var value: V
}

struct MemoryLink<Key: Hashable, T: Codable> {
    
    var head: MemoryLinkNode<T>?
    var trail: MemoryLinkNode<T>?
    private(set) var totalCost: Int = 0
    private(set) var totalCount: Int = 0
    private(set) var dict = [Key : MemoryLinkNode<T>]()
    
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

public struct MemoryCache<Key: Hashable, T: Codable> {
    public typealias K = Key
    public typealias ValueType = T
    
    private let lock: Lock = Mutex()
    private var link = MemoryLink<K, T>()
    
    public init() {}
}

extension MemoryCache: MemoryCacheable {
    public mutating func containsObject(key: Key) -> Bool {
        return link.dict.contains(where: { $0.key == key })
    }
    
    public mutating func query(key: Key) -> T? {
        return link.dict[key]?.value
    }
    
    public mutating func save(value: T, for key: Key) {
        if var node = link.dict[key] {
            node.value = value
            node.time = Date().timeIntervalSince1970
            link.bringNodeToHead(node)
        } else {
            let node = MemoryLinkNode(time: Date().timeIntervalSince1970, cost: 0, value: value)
            link.insertNodeToHead(node)
        }
    }
    
    public mutating func remove(key: Key) {
        
    }
    
    public mutating func removeAll() {
        link.removeAll()
    }
}
