//
//  MemoryCacheLink.swift
//  PracticeCache
//
//  Created by Vassily on 2018/10/22.
//

import Foundation

public protocol NodeStandard: class, CustomStringConvertible {
    associatedtype Key where Key: Hashable
    associatedtype Value
    
    var key: Key { get }
    var value: Value { get }
    var next: Self? { get }
    init(key: Key, value: Value, next: Self?)
}

extension NodeStandard {
    public var description: String {
        guard let next = next else { return "\(value)" }
        return "\(value) -> \(next)"
    }
    
    init(key: Key, value: Value, next: Self? = nil) {
        self.init(key: key, value: value, next: next)
    }
}

protocol LinkedNodeListIndexStandard: Comparable {
    associatedtype Node: NodeStandard
    var node: Node? { get }
    init(node: Node?)
}

extension LinkedNodeListIndexStandard {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.node, rhs.node) {
        case let (left?, right?):
            return left.next === right.next
        case (nil, nil):
            return true
        default:
            return false
        }
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs != rhs else { return false }
        let nodes = sequence(first: lhs.node, next: { $0?.next })
        return nodes.contains(where: { $0 === rhs.node })
    }
}

public protocol LinkedNodeListStandard: Collection where Index: LinkedNodeListIndexStandard {
    associatedtype Node where Self.Node == Index.Node
    associatedtype Key where Self.Key == Node.Key
    associatedtype Value where Self.Value == Node.Value
    
    var head: Node? { get }
    var trail: Node? { get }
    subscript(key: Key) -> Node? { get set }
}

final public class LinkNode<K: Hashable, V>: NodeStandard {
    public typealias Key = K
    public typealias Value = V
    
    public var key: Key
    public var value: Value
    public var next: LinkNode?
    
    public init(key: Key, value: Value, next: LinkNode? = nil) {
        self.key = key
        self.value = value
        self.next = next
    }
}

public struct LinkedNodeListIndex<K: Hashable, V>: LinkedNodeListIndexStandard {
    var node: LinkNode<K, V>?
    init(node: LinkNode<K, V>?) {
        self.node = node
    }
}

public struct LinkedList<K: Hashable, V>: LinkedNodeListStandard {
    
    public typealias Key = K
    public typealias Value = V
    public typealias Node = LinkNode<K, V>
    public typealias Index = LinkedNodeListIndex<K, V>
    
    public var head: Node?
    public var trail: Node?
    
    private var dictContainer = Dictionary<Key, Node>()
    
    public init() {}
    
    // head-first insertion
    public mutating func push(_ value: Value, for key: Key) {
        head = Node(key: key, value: value, next: head)
        if trail == nil {
            trail = head
        }
    }
    
    public subscript(key: K) -> LinkNode<K, V>? {
        get {
            return head!
        }
        set {
            
        }
    }
}

extension LinkedList: Collection {
    public var startIndex: Index {
        return Index(node: head)
    }
    
    public var endIndex: Index {
        return Index(node: trail?.next)
    }
    
    public func index(after i: Index) -> Index {
        return Index(node: i.node?.next)
    }
    
    public subscript(position: Index) -> Node {
        return position.node!
    }
}
