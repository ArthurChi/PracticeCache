//
//  Cache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

protocol CacheStandard {
    associatedtype ValueType: Codable
    func containsObject(key: String) -> Bool
    func query(key: String) -> ValueType?
    func save(value: ValueType, for key: String)
    func remove(key: String)
    func removeAll()
}

protocol CacheAsyncStandard {
    associatedtype ValueType: Codable
    func containsObject(key: String, _ result: @escaping ((_ key: String, _ contain: Bool) -> Void))
    func query(key: String, _ result: @escaping ((_ key: String, _ value: ValueType?) -> Void))
    func save(value: ValueType, for key: String, _ result: @escaping (()->Void))
    func remove(key: String, _ result: @escaping ((_ key: String) -> Void))
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

struct Cache<T, M: CacheStandard, D: CacheStandard & CacheAsyncStandard> where M.ValueType == T, D.ValueType == T {
    typealias ValueType = T
    
    private var memoryCache: M
    private var diskCache: D
    
    init(memoryCache: M, diskCache: D) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
}

extension Cache: CacheStandard {
    
    func containsObject(key: String) -> Bool {
        return memoryCache.containsObject(key: key) || diskCache.containsObject(key: key)
    }
    
    func query(key: String) -> T? {
        var value: T? = memoryCache.query(key: key)
        if value == nil {
            value = diskCache.query(key: key)
            if let value = value {
                memoryCache.save(value: value, for: key)
            }
        }
        
        return value
    }
    
    func save(value: T, for key: String) {
        memoryCache.save(value: value, for: key)
        diskCache.save(value: value, for: key)
    }
    
    func remove(key: String) {
        memoryCache.remove(key: key)
        diskCache.remove(key: key)
    }
    
    func removeAll() {
        memoryCache.removeAll()
        diskCache.removeAll()
    }
}

extension Cache: CacheAsyncStandard {
    func containsObject(key: String, _ result: @escaping ((String, Bool) -> Void)) {
        if memoryCache.containsObject(key: key) {
            DispatchQueue.global().async {
                result(key, true)
            }
        } else {
            diskCache.containsObject(key: key, result)
        }
    }
    
    func query(key: String, _ result: @escaping ((String, T?) -> Void)) {
        if let value: T = memoryCache.query(key: key) {
            DispatchQueue.global().async {
                result(key, value)
            }
        } else {
            diskCache.query(key: key, result)
        }
    }
    
    func save(value: T, for key: String, _ result: @escaping (() -> Void)) {
        memoryCache.save(value: value, for: key)
        diskCache.save(value: value, for: key, result)
    }
    
    func remove(key: String, _ result: @escaping ((String) -> Void)) {
        memoryCache.remove(key: key)
        diskCache.remove(key: key, result)
    }
    
    func removeAll(_ result: @escaping (() -> Void)) {
        memoryCache.removeAll()
        diskCache.removeAll(result)
    }
}
