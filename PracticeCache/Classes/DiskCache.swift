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
