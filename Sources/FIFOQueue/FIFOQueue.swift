import Foundation

public struct FIFOQueue<Element> {
    
    class Node {
        let content: Element
        var next: Node?
        var previous: Node?
        
        init(content: Element) {
            self.content = content
            self.next = nil
            self.previous = nil
        }
    }
    
    private var first: Node?
    
    private var last: Node?
    
    public let maxCapacity: Int
    
    public var count: Int
    
    private let lock: NSRecursiveLock = NSRecursiveLock()
    
    public init(maxCapacity: Int) {
        self.maxCapacity = maxCapacity
        self.count = 0
    }
    
    /// Enqueues the element.
    ///
    /// If the `enqueue` causes it to exceed the maximum capacity, it's returned the element that enqueued very first.
    @discardableResult
    public mutating func enqueue(_ element: Element) -> Element? {
        lock.lock(); defer { lock.unlock() }
        
        let node = Node(content: element)
        first?.previous = node
        node.next = first
        first = node
        
        if last == nil {
            last = node
        }
        
        count += 1
        
        if count > maxCapacity {
            return dequeue()
        }
        
        return nil
    }
    
    /// Returns very first enqueuing element.
    @discardableResult
    public mutating func dequeue() -> Element? {
        lock.lock(); defer { lock.unlock() }
        
        guard let last else {
            return nil
        }
        
        count -= 1
        
        let content = last.content
        
        if let previous = last.previous {
            previous.next = nil
            self.last = previous
        } else {
            self.first = nil
            self.last = nil
        }
        
        return content
    }
}
