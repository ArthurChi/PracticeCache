//
//  MemoryCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

public protocol MemoryCacheable: CacheStandard {
    mutating func save(value: Value, for key: Key, cost: Int)
    mutating func removeLast()
}

public struct MemoryCache<Key: Hashable, T: Codable> {
    public typealias K = Key
    public typealias ValueType = T
    
    private let lock: Lock = Mutex()
    private var link = LinkedList<K, T>()
    private var trimDict = [K:TrimNode]()
    
    private(set) var countLimit: Int
    private(set) var costLimit: Int
    private(set) var ageLimit: TimeInterval
    private(set) var autoTrimInterval: TimeInterval
    
    private var totalCost: Int = 0
    
    public var first: T? {
        return link.first
    }
    
    public init(countLimit: Int = Int.max, costLimit: Int = Int.max, ageLimit: TimeInterval = Double.greatestFiniteMagnitude, autoTrimInterval: TimeInterval = 5) {
        self.countLimit = countLimit
        self.costLimit = costLimit
        self.ageLimit = ageLimit
        self.autoTrimInterval = autoTrimInterval
    }
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
        
        trimDict[key]?.updateAge()
        return link.value(for: key)
    }
    
    // MARK: - save
    public mutating func save(value: T, for key: Key) {
        save(value: value, for: key, cost: 0)
    }
    
    public mutating func save(value: T, for key: Key, cost: Int) {
        lock.lock()

        defer {
            lock.unLock()
        }
        
        trimDict[key] = TrimNode(cost: cost)
        totalCost += cost
        
        link.push(value, for: key)
    }
    
    // MARK: - remove
    public mutating func remove(key: Key) {
        lock.lock()
        
        defer {
            lock.unLock()
        }
        
        let cost = trimDict.removeValue(forKey: key)?.cost ?? 0
        totalCost -= cost
        link.remove(for: key)
    }
    
    public mutating func removeAll() {
        lock.lock()
        
        defer {
            lock.unLock()
        }
        
        trimDict.removeAll()
        totalCost = 0
        link.removeAll()
    }
    
    public mutating func removeLast() {
        lock.lock()
        
        defer {
            lock.unLock()
        }
        
        if let key = link.removeTrail()?.0, let cost = trimDict.removeValue(forKey: key)?.cost {
            totalCost -= cost
        }
    }
}

extension MemoryCache: AutoTrimable {
    public mutating func trimToCount(_ countLimit: Int) {
        if countLimit <= 0 {
            self.removeAll()
        } else {
            while link.count >= countLimit, !link.isEmpty {
                self.removeLast()
            }
        }
    }
    
    public mutating func trimToCost(_ costLimit: Int) {
        if costLimit <= 0 {
            self.removeAll()
        } else {
            while totalCost >= costLimit, totalCost > 0 {
                self.removeLast()
            }
        }
    }
    
    public mutating func trimToAge(_ ageLimit: TimeInterval) {
        if ageLimit <= 0 {
            self.removeAll()
        } else {
            let now = Date().timeIntervalSince1970
            while
                let lastNodeKey = link.endIndex.node?.key,
                let lastTrimNode = trimDict[lastNodeKey],
                now - lastTrimNode.age > ageLimit {
                self.removeLast()
            }
        }
    }
}

extension MemoryCache {
    private struct TrimNode: Hashable {
        private(set) var cost: Int
        private(set) var age: TimeInterval = Date().timeIntervalSince1970
        
        mutating func updateAge() {
            self.age = Date().timeIntervalSince1970
        }
        
        init(cost: Int) {
            self.cost = cost
        }
    }
}
