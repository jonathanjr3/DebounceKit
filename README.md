# DebounceKit

DebounceKit helps you wait for a pause before running work. It is built with Swift concurrency, uses `Task.sleep(for:)`, and does not depend on Combine.

- Debounce any async action with a lightweight actor.
- React to SwiftUI `onChange` events with a debounced view modifier.
- Share or inspect the underlying `Task` when you need manual control.

This package is based on the concepts presented in the article [How to use Debounce in SwiftUI or in Observable classes](https://livsycode.com/swiftui/how-to-use-debounce-in-swiftui-or-in-observable-classes/)

## Requirements

- iOS 17 or later
- macOS 14 or later

## Installation

Add **DebounceKit** to your project with Swift Package Manager.

```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/jonathanjr3/DebounceKit.git", from: "1.0.0")
]
```

You can also add the package in Xcode: **File > Add Packages...** and enter the Git URL of this repo.

## Debounce actor

Use the `Debounce` actor when you want to debounce work you already run from async code.

```swift
import DebounceKit

let searchDebounce = Debounce({ (query: String) async in
    await searchProducts(matching: query)
}, for: .milliseconds(300))

Task {
    await searchDebounce("laptop stand") // starts the timer
    await searchDebounce("laptop")       // cancels the first call and restarts the timer
}
```

The actor keeps only the latest call alive. Every new call cancels the stored task before starting a fresh delay. If you need to stop the pending work (for example when leaving a screen), cancel the actor:

```swift
await searchDebounce.cancel()
```

The closure you pass to `Debounce` must be `@Sendable`. That keeps the work thread-safe inside the actor's isolated task. Mark your function `@Sendable` or restructure captures so you do not pull in unsafe references like class instances.

```swift
// Mark the helper as @Sendable so it is safe to use with Debounce.
let searchAction: @Sendable (String) async -> Void = { query in
    await searchProducts(matching: query)
}

let searchDebounce = Debounce(searchAction, for: .milliseconds(300))
```

## SwiftUI view modifier

`onChangeDebounced` helps you react to state updates in SwiftUI while ignoring rapid changes.

```swift
struct SearchField: View {
    @State private var text = ""
    @State private var task: Task<Void, Never>?

    var body: some View {
        TextField("Search", text: $text)
            .onChangeDebounced(of: text, for: .milliseconds(250), task: $task, initial: false) { _, newValue in
                Task {
                    await searchProducts(matching: newValue)
                }
            }
    }
}
```

Pass a `Binding` to the task if you want to cancel or inspect the work from the parent view. Skip the binding when you do not need that level of control. Set `initial: true` if you want the action to fire once on appear before the first change.

## How it works

- The actor stores the latest `Task` created with `Task.sleep(for:)` and runs your action when the delay ends.
- The SwiftUI modifier mirrors the same idea by keeping its own `Task` (or one passed in from the outside).
- Everything uses `Duration` and `Task.sleep(for:)`, so it matches modern Swift concurrency best practices and stays independent from Combine.

## Contributing

Issues and pull requests are welcome. Please open a discussion if you have ideas for extra helpers or find a bug.
