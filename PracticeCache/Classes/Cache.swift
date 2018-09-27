//
//  Cache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

protocol Cacheable {
    func containsObject(key: String) -> Bool
    func query<T: Codable>(key: String) -> T?
    func save<T: Codable>(value: T, for key: String)
    func remove(key: String)
    func removeAll()
}

protocol CacheableAsync {
    func containsObject(key: String, _ result: @escaping ((_ key: String, _ contain: Bool) -> Void))
    func query<T: Codable>(key: String, _ result: @escaping ((_ key: String, _ value: T?) -> Void))
    func save<T: Codable>(value: T, for key: String, _ result: @escaping (()->Void))
    func remove(key: String, _ result: @escaping ((_ key: String) -> Void))
    func removeAll(_ result: @escaping (()->Void))
}

struct Cache {
    
    private var memoryCache: MemoryCacheable
    private var diskCache: DiskCacheable
    
    init(memoryCache: MemoryCacheable, diskCache: DiskCacheable) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
}

extension Cache: Cacheable {
    func containsObject(key: String) -> Bool {
        return memoryCache.containsObject(key: key) || diskCache.containsObject(key: key)
    }
    
    func query<T>(key: String) -> T? where T : Decodable, T : Encodable {
        var value: T? = memoryCache.query(key: key)
        if value == nil {
            value = diskCache.query(key: key)
            if value != nil {
                memoryCache.save(value: value, for: key)
            }
        }
        
        return value
    }
    
    func save<T>(value: T, for key: String) where T : Decodable, T : Encodable {
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

extension Cache: CacheableAsync {
    func containsObject(key: String, _ result: @escaping ((String, Bool) -> Void)) {
        if memoryCache.containsObject(key: key) {
            DispatchQueue.global().async {
                result(key, true)
            }
        } else {
            diskCache.containsObject(key: key, result)
        }
    }
    
    func query<T>(key: String, _ result: @escaping ((String, T?) -> Void)) where T : Decodable, T : Encodable {
        if let value: T = memoryCache.query(key: key) {
            DispatchQueue.global().async {
                result(key, value)
            }
        } else {
            diskCache.query(key: key, result)
        }
    }
    
    func save<T>(value: T, for key: String, _ result: @escaping (() -> Void)) where T : Decodable, T : Encodable {
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
