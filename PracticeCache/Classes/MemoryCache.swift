//
//  MemoryCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

public protocol MemoryCacheable: CacheStandard { }

class MemoryLinkNode<Key: Hashable, V: Codable> {
    var time: TimeInterval
    var cost: NSInteger
    
    var key: Key
    var value: V
    
    var next: MemoryLinkNode?
    var pre: MemoryLinkNode?
    
    init(key:Key, value: V, cost: NSInteger = 0, time: TimeInterval = Date().timeIntervalSince1970) {
        self.key = key
        self.value = value
        self.cost = cost
        self.time = time
    }
}

extension MemoryLinkNode: Equatable {
    static func == (lhs: MemoryLinkNode<Key, V>, rhs: MemoryLinkNode<Key, V>) -> Bool {
        return lhs.key == rhs.key
    }
}

struct MemoryLink<Key: Hashable, T: Codable> {
    
    var head: MemoryLinkNode<Key, T>?
    var trail: MemoryLinkNode<Key, T>?
    private(set) var totalCost: Int = 0
    private(set) var totalCount: Int = 0
    private(set) var dict = [Key : MemoryLinkNode<Key, T>]()
    
    mutating func insertNodeToHead(_ node: MemoryLinkNode<Key, T>) {
        dict[node.key] = node
        
        if let head = head {
            node.next = head
            head.pre = node
            self.head = node
        } else {
            self.head = node
            self.trail = self.head
        }
    }
    
    mutating func bringNodeToHead(_ node: MemoryLinkNode<Key, T>) {
        if head == node { return }
        
        if trail == node {
            trail = node.pre
            trail?.next = nil
        } else {
            node.pre?.next = node.next
            node.next?.pre = node.pre
        }
        
        node.next = head
        node.pre = nil
        head?.pre = node
        head = node
    }
    
    func removeNode(_ node: MemoryLinkNode<Key, T>) {
        
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
    
    public var firstObject: T? {
        return link.head?.value
    }
    
    public init() {}
}

extension MemoryCache: MemoryCacheable {
    public mutating func containsObject(key: Key) -> Bool {
        return link.dict.contains(where: { $0.key == key })
    }
    
    public mutating func query(key: Key) -> T? {
        if let node = link.dict[key] {
            node.time = Date().timeIntervalSince1970
            link.bringNodeToHead(node)
            return node.value
        }
        
        return nil
    }
    
    public mutating func save(value: T, for key: Key) {
        if let node = link.dict[key] {
            node.value = value
            node.time = Date().timeIntervalSince1970
            link.bringNodeToHead(node)
        } else {
            let node = MemoryLinkNode<Key, T>(key: key, value: value)
            link.insertNodeToHead(node)
        }
    }
    
    public mutating func remove(key: Key) {
        
    }
    
    public mutating func removeAll() {
        link.removeAll()
    }
}
