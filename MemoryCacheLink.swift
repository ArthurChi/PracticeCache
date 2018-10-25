//
//  MemoryCacheLink.swift
//  PracticeCache
//
//  Created by Vassily on 2018/10/22.
//

import Foundation

public class Node<Value> {
    
    var value: Value
    var next: Node?
    
    init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        guard let next = next else { return "\(value)" }
        return "\(value) -> \(next)"
    }
}

public struct LinkedList<Value> {
    
    var head: Node<Value>?
    var trail: Node<Value>?
    
    public init() {}
    
    // head-first insertion
    public mutating func push(_ value: Value) {
        head = Node(value: value, next: head)
        if trail == nil {
            trail = head
        }
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        guard let head = head else { return "empty" }
        return "\(head)"
    }
}

extension LinkedList: Collection {
    public typealias Element = Value
    
    public struct Index: Comparable {
        var node: Node<Value>?
        
        public static func == (lhs: Index, rhs: Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
            case (nil, nil):
                return true
            default:
                return false
            }
        }
        
        public static func < (lhs: LinkedList<Value>.Index, rhs: LinkedList<Value>.Index) -> Bool {
            guard lhs != rhs else { return false }
            let nodes = sequence(first: lhs.node, next: { $0?.next })
            return nodes.contains(where: { $0 === rhs.node })
        }
    }
    
    public var startIndex: LinkedList<Value>.Index {
        return Index(node: head)
    }
    
    public var endIndex: LinkedList<Value>.Index {
        return Index(node: trail?.next)
    }
    
    public func index(after i: LinkedList<Value>.Index) -> LinkedList<Value>.Index {
        return Index(node: i.node?.next)
    }
    
    public subscript(position: LinkedList<Value>.Index) -> Value {
        return position.node!.value
    }
}
