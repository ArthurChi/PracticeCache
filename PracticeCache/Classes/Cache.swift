//
//  Cache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

protocol CacheStandard {
    associatedtype ValueType: Codable
    associatedtype Key: Hashable
    func containsObject(key: Key) -> Bool
    func query(key: Key) -> ValueType?
    func save(value: ValueType, for key: Key)
    func remove(key: Key)
    func removeAll()
}

protocol CacheAsyncStandard {
    associatedtype ValueType: Codable
    associatedtype Key: Hashable
    func containsObject(key: Key, _ result: @escaping ((_ key: Key, _ contain: Bool) -> Void))
    func query(key: Key, _ result: @escaping ((_ key: Key, _ value: ValueType?) -> Void))
    func save(value: ValueType, for key: Key, _ result: @escaping (()->Void))
    func remove(key: Key, _ result: @escaping ((_ key: Key) -> Void))
    func removeAll(_ result: @escaping (()->Void))
}

protocol Lock {
    func lock()
    func unLock()
}

final class Mutex: Lock {
    private var mutex: pthread_mutex_t = {
        var mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        return mutex
    }()
    
    func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    func unLock() {
        pthread_mutex_unlock(&mutex)
    }
}

struct Cache<K, V, M: CacheStandard, D: CacheStandard & CacheAsyncStandard> where M.ValueType == V, D.ValueType == V, M.Key == K, D.Key == K {
    
    typealias Key = K
    typealias ValueType = V
    
    private var memoryCache: M
    private var diskCache: D
    
    init(memoryCache: M, diskCache: D) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
}

extension Cache: CacheStandard {
    func containsObject(key: Key) -> Bool {
        return memoryCache.containsObject(key: key) || diskCache.containsObject(key: key)
    }

    func query(key: Key) -> ValueType? {
        var value: ValueType? = memoryCache.query(key: key)
        if value == nil {
            value = diskCache.query(key: key)
            if let value = value {
                memoryCache.save(value: value, for: key)
            }
        }

        return value
    }

    func save(value: ValueType, for key: Key) {
        memoryCache.save(value: value, for: key)
        diskCache.save(value: value, for: key)
    }

    func remove(key: Key) {
        memoryCache.remove(key: key)
        diskCache.remove(key: key)
    }

    func removeAll() {
        memoryCache.removeAll()
        diskCache.removeAll()
    }
}

extension Cache: CacheAsyncStandard {
    func containsObject(key: Key, _ result: @escaping ((Key, Bool) -> Void)) {
        if memoryCache.containsObject(key: key) {
            DispatchQueue.global().async {
                result(key, true)
            }
        } else {
            diskCache.containsObject(key: key, result)
        }
    }

    func query(key: Key, _ result: @escaping ((Key, ValueType?) -> Void)) {
        if let value: ValueType = memoryCache.query(key: key) {
            DispatchQueue.global().async {
                result(key, value)
            }
        } else {
            diskCache.query(key: key, result)
        }
    }

    func save(value: ValueType, for key: Key, _ result: @escaping (() -> Void)) {
        memoryCache.save(value: value, for: key)
        diskCache.save(value: value, for: key, result)
    }

    func remove(key: Key, _ result: @escaping ((Key) -> Void)) {
        memoryCache.remove(key: key)
        diskCache.remove(key: key, result)
    }

    func removeAll(_ result: @escaping (() -> Void)) {
        memoryCache.removeAll()
        diskCache.removeAll(result)
    }
}
