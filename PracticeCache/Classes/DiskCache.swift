//
//  DiskCache.swift
//  PracticeCache
//
//  Created by Vassily on 2018/9/24.
//

import Foundation

protocol DiskCacheable: Cacheable, CacheableAsync {
    init(path: URL)
}