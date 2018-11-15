//
//  CacheProtocols.swift
//  Pods-PracticeCache_Example
//
//  Created by Vassily on 2018/11/2.
//

import Foundation

// MARK: - Cache
public protocol Cacheable {
    associatedtype M: CacheStandard
    associatedtype D: CacheStandard & CacheAsyncStandard where M.Key == D.Key, M.Value == D.Value
    init(memoryCache: M, diskCache: D)
}

public protocol CacheStandard {
    associatedtype Value: Codable
    associatedtype Key: Hashable
    func containsObject(key: Key) -> Bool
    mutating func query(key: Key) -> Value?
    mutating func save(value: Value, for key: Key)
    mutating func remove(key: Key)
    mutating func removeAll()
}

public protocol CacheAsyncStandard {
    associatedtype Value: Codable
    associatedtype Key: Hashable
    func containsObject(key: Key, _ result: @escaping ((_ key: Key, _ contain: Bool) -> Void))
    mutating func query(key: Key, _ result: @escaping ((_ key: Key, _ value: Value?) -> Void))
    mutating func save(value: Value, for key: Key, _ result: @escaping (()->Void))
    mutating func remove(key: Key, _ result: @escaping ((_ key: Key) -> Void))
    mutating func removeAll(_ result: @escaping (()->Void))
}

// MARK: - Lock
protocol Lock {
    func lock()
    func unLock()
}

// MARK: - Trim
protocol CountTrimable {
    mutating func trimToCount(_ count: Int)
}

protocol CostTrimable {
    mutating func trimToCost(_ cost: Int)
}

protocol AgeTrimable {
    mutating func trimToAge(_ age: TimeInterval)
}

protocol AutoTrimable: CountTrimable, CostTrimable, AgeTrimable {
    var countLimit: Int { get }
    var costLimit: Int { get }
    var ageLimit: TimeInterval { get }
    var autoTrimInterval: TimeInterval { get }
    var shouldAutoTrim: Bool { get set }
}

extension AutoTrimable {
    mutating func autoTrim() {
        var result = self
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + autoTrimInterval) {
            result.trimToAge(result.ageLimit)
            result.trimToCost(result.costLimit)
            result.trimToCount(result.countLimit)
            if result.shouldAutoTrim { result.autoTrim() }
        }
        
        self = result
    }
}

// MARK: - Node and Link
protocol NodeStandard: class, Equatable, CustomStringConvertible {
    associatedtype Key where Key: Hashable
    associatedtype Value
    
    var key: Key { get }
    var value: Value { get }
    var pre: Self? { get }
    var next: Self? { get }
    init(key: Key, value: Value, pre: Self?, next: Self?)
}

extension NodeStandard {
    public var description: String {
        guard let next = next else { return "\(value)" }
        return "\(value) -> \(next)"
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.key == rhs.key
    }
}

protocol LinkedNodeListIndexStandard: Comparable {
    associatedtype Node: NodeStandard
    var node: Node? { get }
    init(node: Node?)
}

extension LinkedNodeListIndexStandard {
    static public func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.node, rhs.node) {
        case let (left?, right?):
            return left.next === right.next
        case (nil, nil):
            return true
        default:
            return false
        }
    }
    
    static public func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs != rhs else { return false }
        let nodes = sequence(first: lhs.node, next: { $0?.next })
        return nodes.contains(where: { $0 === rhs.node })
    }
}

protocol LinkedNodeListStandard: BidirectionalCollection where Index: LinkedNodeListIndexStandard {
    associatedtype Key: Hashable
    associatedtype Value
    
    subscript(key: Key) -> Value? { mutating get set }
    
    func contains(where predicate: (Key) throws -> Bool) rethrows -> Bool
    mutating func push(_ value: Value, for key: Key)
    mutating func remove(for key: Key) -> AnyLinkNode<Key, Value>?
    mutating func removeAll()
    mutating func removeTrail() -> AnyLinkNode<Key, Value>?
    mutating func value(for key: Key) -> Value?
}
