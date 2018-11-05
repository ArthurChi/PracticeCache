//
//  MemoryCacheLink.swift
//  PracticeCache
//
//  Created by Vassily on 2018/10/22.
//

import Foundation

final public class LinkNode<K: Hashable, V>: NodeStandard {
    public typealias Key = K
    public typealias Value = V
    
    public var key: Key
    public var value: Value
    public weak var pre: LinkNode?
    public weak var next: LinkNode?
    
    public init(key: Key, value: Value, pre: LinkNode? = nil, next: LinkNode? = nil) {
        self.key = key
        self.value = value
        self.pre = pre
        self.next = next
    }
    
    public static func == (lhs: LinkNode, rhs: LinkNode) -> Bool {
        return lhs.key == rhs.key
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
    
    public subscript(key: K) -> V? {
        mutating get {
            return value(for: key)
        }
        
        set {
            if let value = newValue {
                push(value, for: key)
            } else {
                remove(for: key)
            }
        }
    }
    
    public func contains(where predicate: (Key) throws -> Bool) rethrows -> Bool {
        do {
            for key in dictContainer.keys where try predicate(key) {
                return true
            }
            
            return false
        } catch {
            return false
        }
    }
}

extension LinkedList: BidirectionalCollection {
    public var startIndex: Index {
        return Index(node: head)
    }

    public var endIndex: Index {
        return Index(node: trail?.next)
    }

    public func index(before i: Index) -> Index {
        return Index(node: i.node?.pre)
    }

    public func index(after i: Index) -> Index {
        return Index(node: i.node?.next)
    }

    public subscript(position: Index) -> Value {
        if position == endIndex { return trail!.value }
        return position.node!.value
    }
}


// MARK: - add
extension LinkedList {
    // head-first insertion
    public mutating func push(_ value: Value, for key: Key) {
        if let node = dictContainer[key] {
            bringNodeToHead(node)
        } else {
            let node = Node(key: key, value: value, next: head)
            dictContainer[key] = node
            head?.pre = node
            head = node
            if trail == nil {
                trail = head
            }
        }
    }
    
    private mutating func push(_ node: Node) {
        push(node.value, for: node.key)
    }
}

// MARK: - remove
extension LinkedList {
    @discardableResult
    public mutating func remove(for key: Key) -> (Key, Value)? {
        if let node = dictContainer.removeValue(forKey: key) {
            if node == head {
                node.next?.pre = nil
                head = node.next
                node.next = nil
            } else if node == trail {
                node.pre?.next = nil
                trail = node.pre
                node.pre = nil
            } else {
                node.pre?.next = node.next
                node.next?.pre = node.pre
            }
            
            return (node.key, node.value)
        }
        
        return nil
    }
    
    @discardableResult
    private mutating func remove(_ node: Node) -> (Key, Value)? {
        return remove(for: node.key)
    }
    
    mutating func removeAll() {
        head = nil
        trail = nil
        dictContainer.removeAll()
    }
    
    @discardableResult
    mutating func removeLast() -> (Key, Value)? {
        let removedNode = trail
        trail = trail?.pre
        trail?.next?.pre = nil
        trail?.next = nil
        if let removedNode = removedNode {
            return (removedNode.key, removedNode.value)
        }
        
        return nil
    }
}

// MARK: - query
extension LinkedList {
    public mutating func value(for key: Key) -> V? {
        if let node = dictContainer[key] {
            bringNodeToHead(node)
            return node.value
        }
        
        return nil
    }
}

// MARK: - update
extension LinkedList {
    private mutating func bringNodeToHead(_ node: Node) {
        if node == head { return }
        
        if node == trail {
            trail = trail?.pre
        } else {
            node.next?.pre = node.pre
            node.pre?.next = node.next
        }
        
        node.next = head
        head?.pre = node
        head = node
    }
}
