//
//  CacheProtocols.swift
//  Pods-PracticeCache_Example
//
//  Created by Vassily on 2018/11/2.
//

import Foundation

// MARK: - Cache
public protocol CacheStandard {
    associatedtype Value: Codable
    associatedtype Key: Hashable
    mutating func containsObject(key: Key) -> Bool
    mutating func query(key: Key) -> Value?
    mutating func save(value: Value, for key: Key)
    mutating func remove(key: Key)
    mutating func removeAll()
}

public protocol CacheAsyncStandard {
    associatedtype Value: Codable
    associatedtype Key: Hashable
    mutating func containsObject(key: Key, _ result: @escaping ((_ key: Key, _ contain: Bool) -> Void))
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
    
    init(key: Key, value: Value, pre: Self? = nil, next: Self? = nil) {
        self.init(key: key, value: value, pre: pre, next: next)
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
    associatedtype Node where Self.Node == Index.Node
    associatedtype Key where Self.Key == Node.Key
    associatedtype Value where Self.Value == Node.Value
    
    var head: Node? { get }
    var trail: Node? { get }
    subscript(key: Key) -> Value? { mutating get set }
}
