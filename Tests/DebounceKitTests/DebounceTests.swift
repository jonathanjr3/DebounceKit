//
//  DebounceTests.swift
//  DebounceKit
//

import Testing
import Foundation
@testable import DebounceKit

// Thread-safe box for use in @Sendable closures
private actor Box<T: Sendable> {
    private(set) var value: T?
    func set(_ newValue: T) { value = newValue }
    func modify(_ transform: (T?) -> T) { value = transform(value) }
}

@Suite("Debounce")
struct DebounceTests {

    @Test("fires action after delay")
    func firesAfterDelay() async {
        let count = Box<Int>()
        let debounce = Debounce({ await count.modify { ($0 ?? 0) + 1 } }, for: .milliseconds(50))

        await debounce()

        try? await Task.sleep(for: .milliseconds(100))
        #expect(await count.value == 1)
    }

    @Test("cancels previous call when invoked again")
    func cancelsPreviousCall() async {
        let count = Box<Int>()
        let debounce = Debounce({ await count.modify { ($0 ?? 0) + 1 } }, for: .milliseconds(100))

        await debounce()
        await debounce()
        await debounce()

        try? await Task.sleep(for: .milliseconds(200))
        #expect(await count.value == 1)
    }

    @Test("does not fire after cancel()")
    func doesNotFireAfterCancel() async {
        let count = Box<Int>()
        let debounce = Debounce({ await count.modify { ($0 ?? 0) + 1 } }, for: .milliseconds(100))

        await debounce()
        await debounce.cancel()

        try? await Task.sleep(for: .milliseconds(200))
        #expect(await count.value == nil)
    }

    @Test("forwards parameters to action")
    func forwardsParameters() async {
        let box = Box<String>()
        let debounce = Debounce({ (value: String) async in await box.set(value) }, for: .milliseconds(50))

        await debounce("hello")

        try? await Task.sleep(for: .milliseconds(100))
        #expect(await box.value == "hello")
    }

    @Test("uses the last value when called multiple times")
    func usesLastValue() async {
        let box = Box<String>()
        let debounce = Debounce({ (value: String) async in await box.set(value) }, for: .milliseconds(100))

        await debounce("first")
        await debounce("second")
        await debounce("third")

        try? await Task.sleep(for: .milliseconds(200))
        #expect(await box.value == "third")
    }

    @Test("fires independently for separate calls after delay")
    func separateCallsEachFire() async {
        let count = Box<Int>()
        let debounce = Debounce({ await count.modify { ($0 ?? 0) + 1 } }, for: .milliseconds(50))

        await debounce()
        try? await Task.sleep(for: .milliseconds(100))

        await debounce()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(await count.value == 2)
    }
}
