//
//  DiskCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

public protocol DiskCacheable: CacheStandard, CacheAsyncStandard {
    init(path: URL)
}

public struct DiskCache<K: Hashable, V: Codable>: DiskCacheable {
    
    private var path: URL
    
    public init(path: URL) {
        self.path = path
    }
}

extension DiskCache {
    public func containsObject(key: K) -> Bool {
        return true
    }
    
    public func query(key: K) -> V? {
        return nil
    }
    
    public func save(value: V, for key: K) {
        
    }
    
    public func remove(key: K) {
        
    }
    
    public func removeAll() {
        
    }
}

extension DiskCache {
    public func containsObject(key: K, _ result: @escaping ((K, Bool) -> Void)) {
        
    }
    
    public func query(key: K, _ result: @escaping ((K, V?) -> Void)) {
        
    }
    
    public func save(value: V, for key: K, _ result: @escaping (() -> Void)) {
        
    }
    
    public func remove(key: K, _ result: @escaping ((K) -> Void)) {
        
    }
    
    public func removeAll(_ result: @escaping (() -> Void)) {
        
    }
}
