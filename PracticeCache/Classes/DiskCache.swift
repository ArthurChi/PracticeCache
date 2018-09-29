//
//  DiskCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

protocol DiskCacheable: CacheStandard, CacheAsyncStandard {
    init(path: URL)
}

struct DiskCache<T: Codable>: DiskCacheable {
    typealias ValueType = T
    
    private var path: URL
    
    init(path: URL) {
        self.path = path
    }
}

extension DiskCache {
    func containsObject(key: String) -> Bool {
        return true
    }
    
    func query(key: String) -> T? {
        return nil
    }
    
    func save(value: T, for key: String) {
        
    }
    
    func remove(key: String) {
        
    }
    
    func removeAll() {
        
    }
}

extension DiskCache {
    func containsObject(key: String, _ result: @escaping ((String, Bool) -> Void)) {
        
    }
    
    func query(key: String, _ result: @escaping ((String, T?) -> Void)) {
        
    }
    
    func save(value: T, for key: String, _ result: @escaping (() -> Void)) {
        
    }
    
    func remove(key: String, _ result: @escaping ((String) -> Void)) {
        
    }
    
    func removeAll(_ result: @escaping (() -> Void)) {
        
    }
}
