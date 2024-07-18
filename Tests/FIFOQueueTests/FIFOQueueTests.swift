@testable import FIFOQueue
import XCTest

final class FIFOQueueTests: XCTestCase {
    
    func test_enqueue_dequeue() {
        let queue = FIFOQueue<Int>(maxCapacity: 10)
        queue.enqueue(1)
        XCTAssertEqual(queue.dequeue(), 1)
    }
    
    func test_enqueue_whenOverCapacity() {
        let queue = FIFOQueue<Int>(maxCapacity: 3)
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        let first = queue.enqueue(4)
        XCTAssertEqual(first, 1)
    }
    
    func test_count() {
        // Given
        let queue = FIFOQueue<Int>(maxCapacity: .max)
        
        // When
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        
        // Then
        XCTAssertEqual(queue.count, 3)
    }
    
    func test_count_whenComplexEnAndDequeue() {
        // Given
        let queue = FIFOQueue<Int>(maxCapacity: .max)
        
        // When
        queue.dequeue()
        queue.enqueue(1)
        queue.dequeue()
        queue.enqueue(1)
        queue.enqueue(2)
        queue.dequeue()
        queue.dequeue()
        queue.dequeue()
        queue.enqueue(1)
        
        // Then
        XCTAssertEqual(queue.count, 1)
    }
    
    func test_count_whenOverMaxCapacity() {
        // Given
        let queue = FIFOQueue<Int>(maxCapacity: 3)
        
        // When
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        queue.enqueue(4)
        
        // Then
        XCTAssertEqual(queue.count, 3)
    }
    
    func test_lock_withMultiThreading() {
        // Given
        let queue = FIFOQueue<Int>(maxCapacity: .max)
        
        let expectation = expectation(description: "Enqueue done.")
        expectation.expectedFulfillmentCount = 20_000
        
        let testQueue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        let testQueue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        
        // When
        for _ in (1...10_000) {
            testQueue1.async {
                queue.enqueue(1)
                expectation.fulfill()
            }
            testQueue2.async {
                queue.enqueue(2)
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation])
        XCTAssertEqual(queue.count, 20_000)
    }
    
    func test_recursiveLock_whenOverCapacity_withMultiThreading() {
        // Given
        let queue = FIFOQueue<Int>(maxCapacity: 100)
        var overElements: [Int] = []
        let lock = NSLock()
        
        let expectation = expectation(description: "Enqueue done.")
        expectation.expectedFulfillmentCount = 20_000
        
        let testQueue1 = DispatchQueue(label: "queue1", attributes: .concurrent)
        let testQueue2 = DispatchQueue(label: "queue2", attributes: .concurrent)
        
        // When
        for _ in (1...10_000) {
            testQueue1.async {
                let overElement = queue.enqueue(1)
                if let overElement {
                    lock.lock()
                    overElements.append(overElement)
                    lock.unlock()
                }
                expectation.fulfill()
            }
            testQueue2.async {
                let overElement = queue.enqueue(2)
                if let overElement {
                    lock.lock()
                    overElements.append(overElement)
                    lock.unlock()
                }
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(queue.count, 100)
        XCTAssertEqual(overElements.count, 19_900)
    }
    
    func test_iterating() {
        // Given
        let queue = FIFOQueue<Node>(maxCapacity: 10)
        (1...10).forEach { _ in
            queue.enqueue(Node(content: 1))
        }
        
        // When
        queue.forEach { node in
            node.content += 1
        }
        
        // Then
        (1...10).forEach { _ in
            XCTAssertEqual(queue.dequeue()?.content, 2)
        }
    }
}

fileprivate class Node {
    var content: Int
    init(content: Int) {
        self.content = content
    }
}
