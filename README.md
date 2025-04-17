# Requirements
iOS 15+

# Usage

## Title + SystemImage
**AsyncButton**(_ title: String, _ systemImage: String?, cancellationMessage: String?, onRunningChanged: ((Bool) -> Void)?, action: () async -> Void)

## Title
**AsyncButton**(_ title: String, cancellationMessage: String?, onRunningChanged: ((Bool) -> Void)?, action: () async -> Void)

## Custom Label View
**AsyncButton**(label: () -> View, cancellationMessage: String?, onRunningChanged: ((Bool) -> Void)?, action: () async -> Void)

# Examples
```swift
AsyncButton("Sleep for 3 Seconds", cancellationMessage: "This will stop the sleeping Task!", onRunningChanged: { value in
print(value.description)
            }) {
                try? await Task.sleep(nanoseconds: 3000000000) 
            }
```
