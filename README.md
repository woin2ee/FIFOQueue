# FIFOQueue
FIFO Queue

## Usage
```swift
struct Item {
    let content: String
}

let queue = FIFOQueue<Item>(maxCapacity: 3)

queue.enqueue(Item(content: "Item1"))
queue.enqueue(Item(content: "Item2"))
queue.enqueue(Item(content: "Item3"))

let item1 = queue.enqueue(Item(content: "Item4")) // Pop out the first entered item
let item2 = queue.enqueue(Item(content: "Item5")) // Pop out the second entered item
```
