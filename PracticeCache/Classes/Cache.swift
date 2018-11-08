//
//  Cache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

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

public struct Cache<MT, DT>: Cacheable where MT: CacheStandard, DT: CacheStandard & CacheAsyncStandard, MT.Key == DT.Key, MT.Value == DT.Value {
    
    public typealias M = MT
    public typealias D = DT
    
    public typealias Value = M.Value
    public typealias Key = M.Key
    
    private var memoryCache: M
    private var diskCache: D
    
    public init(memoryCache: M, diskCache: D) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
}

extension Cache: CacheStandard {

    public func containsObject(key: Key) -> Bool {
        return memoryCache.containsObject(key: key) || diskCache.containsObject(key: key)
    }

    mutating public func query(key: Key) -> Value? {
        var value: Value? = memoryCache.query(key: key)
        if value == nil {
            value = diskCache.query(key: key)
            if let value = value {
                memoryCache.save(value: value, for: key)
            }
        }

        return value
    }

    mutating public func save(value: Value, for key: Key) {
        memoryCache.save(value: value, for: key)
        diskCache.save(value: value, for: key)
    }

    mutating public func remove(key: Key) {
        memoryCache.remove(key: key)
        diskCache.remove(key: key)
    }

    mutating public func removeAll() {
        memoryCache.removeAll()
        diskCache.removeAll()
    }
}

extension Cache: CacheAsyncStandard {
    public func containsObject(key: Key, _ result: @escaping ((Key, Bool) -> Void)) {
        if memoryCache.containsObject(key: key) {
            DispatchQueue.global().async {
                result(key, true)
            }
        } else {
            diskCache.containsObject(key: key, result)
        }
    }

    mutating public func query(key: Key, _ result: @escaping ((Key, Value?) -> Void)) {
        if let value: Value = memoryCache.query(key: key) {
            DispatchQueue.global().async {
                result(key, value)
            }
        } else {
            diskCache.query(key: key, result)
        }
    }

    mutating public func save(value: Value, for key: Key, _ result: @escaping (() -> Void)) {
        memoryCache.save(value: value, for: key)
        diskCache.save(value: value, for: key, result)
    }

    mutating public func remove(key: Key, _ result: @escaping ((Key) -> Void)) {
        memoryCache.remove(key: key)
        diskCache.remove(key: key, result)
    }

    mutating public func removeAll(_ result: @escaping (() -> Void)) {
        memoryCache.removeAll()
        diskCache.removeAll(result)
    }
}
