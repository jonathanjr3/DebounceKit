//
//  Debounce.swift
//  DebounceKit
//
//  Created by Jonathan Rajya on 25/10/2025.
//

import Foundation

public actor Debounce <each Parameter: Sendable> {
    private let action: @Sendable (repeat each Parameter) async -> Void
    private let delay: Duration
    private var task: Task<Void, Never>?

    public init(
        _ action: @Sendable @escaping (repeat each Parameter) async -> Void,
        for dueTime: Duration
    ) {
        delay = dueTime
        self.action = action
    }
}

public extension Debounce {
    func callAsFunction(_ parameter: repeat each Parameter) {
        task?.cancel()

        task = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await action(repeat each parameter)
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
