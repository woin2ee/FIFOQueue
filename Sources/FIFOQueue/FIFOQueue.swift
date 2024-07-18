import Foundation

class Node<T> {
    let content: T?
    var next: Node?
    var previous: Node?
    
    init(content: T? = nil) {
        self.content = content
        self.next = nil
        self.previous = nil
    }
}

public final class FIFOQueue<Element> {
    
    private var first: Node<Element>?
    
    private var last: Node<Element>?
    
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
    public func enqueue(_ element: Element) -> Element? {
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
    public func dequeue() -> Element? {
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

extension FIFOQueue: Sequence {
    
    public struct Iterator: IteratorProtocol {
        private var queue: FIFOQueue<Element>
        private var times = 0
        private var iteratingNode: Node<Element>?
        
        init(_ queue: FIFOQueue<Element>) {
            self.queue = queue
            let iteratingNode = Node<Element>()
            iteratingNode.next = queue.first
            self.iteratingNode = iteratingNode
        }
        
        public mutating func next() -> Element? {
            guard times < queue.count else { return nil }
            times += 1
            iteratingNode = iteratingNode?.next
            return iteratingNode?.content
        }
    }
    
    public func makeIterator() -> Iterator {
        Iterator(self)
    }
}
