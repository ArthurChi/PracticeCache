//
//  MemoryCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

public protocol MemoryCacheable: CacheStandard { }

public struct MemoryCache<Key: Hashable, T: Codable> {
    public typealias K = Key
    public typealias ValueType = T
    
    private let lock: Lock = Mutex()
    private var link = LinkedList<K, T>()
    
    private(set) var countLimit: Int = Int.max
    private(set) var costLimit: Int = Int.max
    private(set) var ageLimit: TimeInterval = Double.greatestFiniteMagnitude
    
    public var firstObject: T? {
        return link.head?.value
    }
    
    public init() {}
}

extension MemoryCache: MemoryCacheable {
    public mutating func containsObject(key: Key) -> Bool {
        return link.contains(where: { $0 == key })
    }
    
    public mutating func query(key: Key) -> T? {
        lock.lock()
        
        defer {
            lock.unLock()
        }
        
        return link.value(for: key)
    }
    
    public mutating func save(value: T, for key: Key) {
        lock.lock()
        
        defer {
            lock.unLock()
        }
        
        link.push(value, for: key)
    }
    
    public mutating func remove(key: Key) {
        link.remove(for: key)
    }
    
    public mutating func removeAll() {
        link.removeAll()
    }
}
