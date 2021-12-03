//
//  Heap_PriorityQueue.swift
//  DSA self study CommandLine
//
//  Created by sungwook on 11/19/21.
//
import Foundation

public enum Enum_Heap_Kind { case max, min }

///public struct Heap<Key: Equatable & Comparable>: ExpressibleByArrayLiteral {
public struct Heap<Key: Equatable & Comparable> {
    public let kind: Enum_Heap_Kind
    public let comp: (Key, Key) -> Bool
    // MARK: If you want it as ArraySlice, uncomment below
    //    public var keys: ArraySlice<Key> /// [Key]
    public var keys: [Key]
    
    public init(kind: Enum_Heap_Kind, keyType: Key.Type, compare: @escaping (Key, Key) -> Bool) {
        self.kind = kind
        self.comp = compare
        // MARK: If you want it as ArraySlice, uncomment below
        //        self.keys = ArraySlice<Key>()
        self.keys = Array<Key>()
    }
    public init(kind: Enum_Heap_Kind, keyType: Key.Type) {
        switch kind {
        case .max:
            self.init(kind: .max, keyType: keyType, compare: >)
        case .min:
            self.init(kind: .min, keyType: keyType, compare: <)
        }
    }
    public init(kind: Enum_Heap_Kind, keys: [Key]) {
        self.kind = kind
        switch kind {
        case .max:
            self.comp = { $0 > $1 }
        case .min:
            self.comp = { $0 < $1 }
        }
        // MARK: If you want it as ArraySlice, uncomment below
        //        self.keys = ArraySlice<Key>() /// [Key]()
        self.keys = [Key]()
        
        keys.forEach {
            self.insert($0)
        }
    }
    public var first: Key? { keys.first }
    public mutating func insert(_ key: Key) {
        keys.append(key)
        var i = keys.endIndex - 1
        while i > keys.startIndex, comp(keys[i], keys[parent(i)]) {
            keys.swapAt(i, parent(i))
            i = parent(i)
        }
    }
    public mutating func remove(_ i: Int) {
        keys.remove(at: i)
        shiftUp(keys.endIndex-1)
    }
    public mutating func extractFirst() -> Key? {
        guard let max = keys.first else {
            return nil
        }
        /// #CAVEAT
        /// What I tried to do was not intended to rearrange all the indexes of the dynamic array
        ///  that will occur if I did `keys.removeFirst()`,
        /// but copying the last element to the first and then
        /// heapify(index) or shiftDown(index)
        keys[0] = keys.last!
        keys.removeLast()
        heapify(keys.startIndex)
        //        heapify(0) /// Why does **NOT** this work? Is there a case when keys.startIndex != keys.count -1 ?
        return max
    }
    public mutating func shiftUp(_ starting_index: Int) {
        var i = starting_index
        while i > keys.startIndex, comp(keys[i], keys[parent(i)]) {
            //        while i > 0, comp(keys[i], keys[parent(i)]) { /// However, this does **NOT** affact the integrity.
            keys.swapAt(i, parent(i))
            i = parent(i)
        }
    }
    /// regard this as `shiftDown(_ i: Int)`
    public mutating func heapify(_ i: Int) {
        let l = left(i)
        let r = right(i)
        var max_or_min_idx = i
        if l < keys.endIndex, comp(keys[l], keys[max_or_min_idx]) {
            //        if l < keys.count - 1, comp(keys[l], keys[max_i]) { /// Why does **NOT** this work? Is there a case when keys.endIndex != keys.count -1 ?
            max_or_min_idx = l
        }
        if r < keys.endIndex, comp(keys[r], keys[max_or_min_idx]) {
            //        if r < keys.count - 1, comp(keys[r], keys[max_i]) { /// Why does **NOT** this work? Is there a case when keys.endIndex != keys.count -1 ?
            max_or_min_idx = r
        }
        if max_or_min_idx != i  {
            keys.swapAt(i, max_or_min_idx)
            heapify(max_or_min_idx)
        }
    }
    // MARK: An impossible attempt to improve more performance than O(V) because there is no definitive structural rules to find the mpq index by `the value of the key`.
    // MARK: A catch - the value of keys can be not unique.
    // MARK: Not faster than rigorous search -> ended up a meaningless func!!!
    public func firstIndex(of key: Key) -> Int? {
        var i = keys.endIndex - 1
        /// I hoped that this portion expediate the search, but it didn't.
        while i > keys.startIndex, comp(keys[i], keys[parent(i)]) {
            i = parent(i)
        }
        while keys[i] != key, i >= keys.startIndex {
            i -= 1
        }
        return i >= keys.startIndex ? i:nil
    }
    
    public func isEmpty() -> Bool {
        keys.isEmpty
    }
    public mutating func shiftDown(_ i: Int) {
        heapify(i)
    }
    private func left(_ i: Int) -> Int {
        i<<1 + 1
    }
    private func right(_ i: Int) -> Int {
        i<<1 + 2
    }
    private func parent(_ i: Int) -> Int {
        (i-1)>>1
    }
}
public struct MaxHeap<Key: Equatable & Comparable>: ExpressibleByArrayLiteral {
    public var heap: Heap<Key>
    public init(keyType: Key.Type) {
        let heap = Heap(kind: .max, keyType: Key.self)
        self.heap = heap
    }
    public init(keys: [Key]) {
        let heap = Heap(kind: .max, keys: keys)
        self.heap = heap
    }
    public init(arrayLiteral: Key...) {
        let heap = Heap(kind: .max, keys: arrayLiteral)
        self.heap = heap
    }
    public var max: Key? { heap.first }
    public mutating func insert(_ key: Key) {
        heap.insert(key)
    }
    public mutating func remove(_ i: Int) {
        heap.remove(i)
    }
    public mutating func extractMax() -> Key? {
        heap.extractFirst()
    }
    public mutating func shiftUp(_ i: Int) {
        heap.shiftUp(i)
    }
    public mutating func heapify(_ i: Int) {
        heap.heapify(i)
    }
    public func isEmpty() -> Bool {
        heap.keys.isEmpty
    }
}
public struct MinHeap<Key: Equatable & Comparable>: ExpressibleByArrayLiteral {
    public var heap: Heap<Key>
    public init(keyType: Key.Type) {
        let heap = Heap(kind: .min, keyType: Key.self)
        self.heap = heap
    }
    public init(keys: [Key]) {
        let heap = Heap(kind: .min, keys: keys)
        self.heap = heap
    }
    public init(arrayLiteral: Key...) {
        let heap = Heap(kind: .min, keys: arrayLiteral)
        self.heap = heap
    }
    public var min: Key? { heap.first }
    public mutating func insert(_ key: Key) {
        heap.insert(key)
    }
    public mutating func remove(_ i: Int) {
        heap.remove(i)
    }
    public mutating func shiftUp(_ i: Int) {
        heap.shiftUp(i)
    }
    public mutating func extractMin() -> Key? {
        heap.extractFirst()
    }
    public mutating func heapify(_ i: Int) {
        heap.heapify(i)
    }
    public func isEmpty() -> Bool {
        heap.keys.isEmpty
    }
}
public struct MaxPriorityQueue<Key: Equatable & Comparable>: ExpressibleByArrayLiteral {
    public var heap: Heap<Key>
    public init(keyType: Key.Type) {
        let heap = Heap(kind: .max, keyType: Key.self)
        self.heap = heap
    }
    public init(keys: [Key]) {
        let heap = Heap(kind: .max, keys: keys)
        self.heap = heap
    }
    public init(arrayLiteral: Key...) {
        let heap = Heap(kind: .max, keys: arrayLiteral)
        self.heap = heap
    }
    public var max: Key? { heap.first }
    public mutating func insert(_ key: Key) {
        heap.insert(key)
    }
    public mutating func changePriority(_ i: Int, _ p: Key) {
        let old_p = heap.keys[i]
        heap.keys[i] = p
        /// p > old_p ? shiftUp(i) : heapify(i)
        heap.comp(p, old_p) ? shiftUp(i) : heapify(i)
    }
    public mutating func remove(_ i: Int) {
        heap.remove(i)
    }
    public mutating func extractMax() -> Key? {
        heap.extractFirst()
    }
    public mutating func shiftUp(_ i: Int) {
        heap.shiftUp(i)
    }
    public mutating func heapify(_ i: Int) {
        heap.heapify(i)
    }
    public func isEmpty() -> Bool {
        heap.keys.isEmpty
    }
}
public struct MinPriorityQueue<Key: Equatable & Comparable>: ExpressibleByArrayLiteral {
    public var heap: Heap<Key>
    public init(keyType: Key.Type) {
        let heap = Heap(kind: .min, keyType: Key.self)
        self.heap = heap
    }
    public init(keys: [Key]) {
        let heap = Heap(kind: .min, keys: keys)
        self.heap = heap
    }
    public init(arrayLiteral: Key...) {
        let heap = Heap(kind: .min, keys: arrayLiteral)
        self.heap = heap
    }
    public var min: Key? { heap.first }
    public mutating func insert(_ key: Key) {
        heap.insert(key)
    }
    public mutating func shiftUp(_ i: Int) {
        heap.shiftUp(i)
    }
    public mutating func changePriority(_ i: Int, _ p: Key) {
        let old_p = heap.keys[i]
        heap.keys[i] = p
        /// p < old_p ? shiftUp(i) : heapify(i)
        heap.comp(p, old_p) ? shiftUp(i) : heapify(i)
    }
    public mutating func remove(_ i: Int) {
        heap.remove(i)
    }
    public mutating func extractMin() -> Key? {
        heap.extractFirst()
    }
    public mutating func heapify(_ i: Int) {
        heap.heapify(i)
    }
    public func isEmpty() -> Bool {
        heap.keys.isEmpty
    }
}

func test__MaxHeap_MinHeap() {
    let testCases = [
        [2, 4, 6, 3, 1, -2, 7, 9],
        [],
        [21, 4, 5, 3, 5, -2, 7, 12],
        [6, 7, -5, 5, 4, 3, 2, 1],
    ]
    for testCase in testCases {
        var maxHeap_test1st = MaxHeap(keyType: Int.self); testCase.forEach { maxHeap_test1st.insert($0) }
        var minHeap_test1st = MinHeap(keyType: Int.self); testCase.forEach { minHeap_test1st.insert($0) }
        print("testCase = \(testCase), max = \(String(describing: maxHeap_test1st.max)), min = \(String(describing: minHeap_test1st.min))")
        print("\tmaxHeap_test1st and minHeap_test1st keys = ", maxHeap_test1st.heap.keys)
        _ = maxHeap_test1st.extractMax()
        print("maxHeap.extractMax()")
        print("\tmaxHeap_test1st keys = ", maxHeap_test1st.heap.keys)
        _ = minHeap_test1st.extractMin()
        print("minHeap.extractMin()")
        print("\tminHeap_test1st keys = ", minHeap_test1st.heap.keys)
        print("After extracting max and min, max from maxHeap = \(String(describing: maxHeap_test1st.max)), min from minHeap = \(String(describing: minHeap_test1st.min))")
        print("\n")
    }
    
    
    let testCase_2nd = ["ki", "dui", "abc", "bef", "a", "c", "b"]
    var maxHeap_test2nd = MaxHeap(keyType: String.self); testCase_2nd.forEach { maxHeap_test2nd.insert($0) }
    var minHeap_test2nd = MinHeap(keyType: String.self); testCase_2nd.forEach { minHeap_test2nd.insert($0) }
    print("testCase = \(testCase_2nd), max = \(maxHeap_test2nd.max!), min = \(minHeap_test2nd.min!)")
    print("\tmaxHeap_test2nd keys = ", maxHeap_test2nd.heap.keys)
    print("\tminHeap_test2nd keys = ", minHeap_test2nd.heap.keys)
    _ = maxHeap_test2nd.extractMax()
    print("maxHeap_test2nd.extractMax()")
    print("\tmaxHeap_test2nd keys = ", maxHeap_test2nd.heap.keys)
    _ = minHeap_test2nd.extractMin()
    print("minHeap_test2nd.extractMin()")
    print("\tminHeap_test2nd keys = ", minHeap_test2nd.heap.keys)
    print("After extracting max and min, max from maxHeap = \(maxHeap_test2nd.max!), min from minHeap = \(minHeap_test2nd.min!)")
    print("\n")
    
    
    let testCase_3rd = [20, 15, 8, 10, 5, 7, 6, 2, 9, 1]
    var minHeap_test3rd = MinHeap(keys: testCase_3rd)
    print("testCase = \(testCase_3rd), min = \(minHeap_test3rd.min!)")
    minHeap_test3rd.insert(22)
    print("minHeap_test3rd.insert(22)")
    print("\tkeys = ", minHeap_test3rd.heap.keys)
    minHeap_test3rd.insert(13)
    print("minHeap_test3rd.insert(13)")
    print("\tkeys = ", minHeap_test3rd.heap.keys)
    print("min = \(minHeap_test3rd.min!)")
    
    var sorted_array = [Int]()
    var min: Int?
    repeat {
        min = minHeap_test3rd.extractMin()
        if min != nil {
            sorted_array.append(min!)
        }
    } while min != nil
    /// See if it is sorted <
    print("sorted_array =", sorted_array)
    /// Test driven coding
    assert(sorted_array == (testCase_3rd+[22, 13]).sorted())
    
    
    var maxHeap_test4th = MaxHeap(keys: testCase_3rd)
    print("testCase = \(testCase_3rd), max = \(maxHeap_test4th.max!)")
    sorted_array.removeAll(keepingCapacity: true)
    var max: Int?
    repeat {
        max = maxHeap_test4th.extractMax()
        if max != nil {
            sorted_array.append(max!)
        }
    } while max != nil
    print("sorted_array =", sorted_array)
    let checking_array = testCase_3rd.sorted(by: >)
    /// Test driven coding
    assert(sorted_array == checking_array)
    
    maxHeap_test4th = MaxHeap(keys: testCase_3rd)
    print("\tkeys = ", maxHeap_test4th.heap.keys)
    maxHeap_test4th.heap.remove(1)
    print("maxHeap_test4th.heap.remove(1)")
    print("\tkeys = ", maxHeap_test4th.heap.keys)
    sorted_array.removeAll(keepingCapacity: true)
    repeat {
        max = maxHeap_test4th.extractMax()
        if max != nil {
            sorted_array.append(max!)
        }
    } while max != nil
    /// See if it is sorted >
    print("sorted_array =", sorted_array)
    let ans = testCase_3rd.sorted(by: >).enumerated().filter { $0.offset != 1 }.map { $0.element }
    /// Test driven coding
    assert(ans == sorted_array)
}


func test__PriorityQueue() {
    var testCases = [
        [20, 15, 8, 10, 5, 7, 6, 2, 9, 1],
    ]
    var newCase = [Int]()
    for _ in 1...10 { newCase.append((0...100).randomElement()!)}
    testCases.append(newCase)
    
    for testCase in testCases {
        var maxPriorityQueue = MaxPriorityQueue(keys: testCase)
        
        print("maxPriorityQueue.keys =", maxPriorityQueue.heap.keys)
        maxPriorityQueue.changePriority(1, 3)
        print("maxPriorityQueue.changePriority(1, 3)")
        print("maxPriorityQueue.keys =", maxPriorityQueue.heap.keys)
        
        var minPriorityQueue = MinPriorityQueue(keys: testCase)
        print("minPriorityQueue.heap.keys =", minPriorityQueue.heap.keys)
        minPriorityQueue.changePriority(1, 90)
        print("minPriorityQueue.changePriority(1, 90)")
        print("minPriorityQueue.heap.keys =", minPriorityQueue.heap.keys)
        
        let copied_from_maxPriorityQueue = maxPriorityQueue.heap.keys
        let sorted_decreasingly_by_max_heap = (0..<maxPriorityQueue.heap.keys.count).reduce(into: Array<Int>()) { (result, element) in
            if let max = maxPriorityQueue.extractMax() {
                result.append(max)
            }
        }
        let copied_from_minPriorityQueue = minPriorityQueue.heap.keys
        let sorted_increasingly_by_min_heap = (0..<minPriorityQueue.heap.keys.count).reduce(into: Array<Int>()) { (result, _) in
            if let min = minPriorityQueue.extractMin() {
                result.append(min)
            }
        }
        
        /// Test driven coding
        assert(sorted_decreasingly_by_max_heap == copied_from_maxPriorityQueue.sorted(by: >))
        assert(sorted_increasingly_by_min_heap == copied_from_minPriorityQueue.sorted())
    }
}
