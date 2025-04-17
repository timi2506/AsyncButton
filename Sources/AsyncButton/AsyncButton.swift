import SwiftUI

struct Showcase: View {
    @State var simpleTitleRunning = false
    var body: some View {
        VStack {
            AsyncButton("Simple Title", cancellationMessage: "This might break shit!", onRunningChanged: { newValue in
                simpleTitleRunning = newValue
            }) {
                let threeSeconds: UInt64 = 3 * 1_000_000_000
                do {
                    try await Task.sleep(nanoseconds: threeSeconds)
                } catch {
                    print("Sleep was cancelled: \(error)")
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            AsyncButton("Favorites", "star.fill") {
                let threeSeconds: UInt64 = 3 * 1_000_000_000
                do {
                    try await Task.sleep(nanoseconds: threeSeconds)
                } catch {
                    print("Sleep was cancelled: \(error)")
                }
            }
            AsyncButton {
                HStack {
                    Image(systemName: "flame")
                    Text("Custom Button")
                        .fontWeight(.bold)
                }
            } action: {
                let threeSeconds: UInt64 = 3 * 1_000_000_000
                do {
                    try await Task.sleep(nanoseconds: threeSeconds)
                } catch {
                    print("Sleep was cancelled: \(error)")
                }
            }
        }
    }
}

public struct AsyncButton: View {
    @State private var isRunning: Bool = false
    @State private var task: Task<Void, Never>? = nil
    
    private let labelContent: LabelContent
    private let action: () async -> Void
    private let onRunningChanged: ((Bool) -> Void)?
    private let cancellationMessage: String?
    
    private enum LabelContent {
        case textOnly(String)
        case textWithImage(String, String)
        case custom(AnyView)
    }
    
    init(
        _ title: String,
        _ systemImage: String? = nil,
        cancellationMessage: String? = nil,
        onRunningChanged: ((Bool) -> Void)? = nil,
        action: @escaping () async -> Void
    ) {
        if let systemImage {
            self.labelContent = .textWithImage(title, systemImage)
        } else {
            self.labelContent = .textOnly(title)
        }
        self.cancellationMessage = cancellationMessage
        self.action = action
        self.onRunningChanged = onRunningChanged
    }
    
    init<Content: View>(
        cancellationMessage: String? = nil,
        onRunningChanged: ((Bool) -> Void)? = nil,
        @ViewBuilder label: () -> Content,
        action: @escaping () async -> Void
    ) {
        self.labelContent = .custom(AnyView(label()))
        self.cancellationMessage = cancellationMessage
        self.action = action
        self.onRunningChanged = onRunningChanged
    }
    
    public var body: some View {
        Button {
            if isRunning {
                confirmationAlert(
                    "Are you sure?",
                    subtitle: cancellationMessage ?? "This will cancel the currently running Action which might result into losing your data",
                    completion: { value in
                        if value {
                            task?.cancel()
                            updateRunning(false)
                        }
                    }
                )
            } else {
                task = Task {
                    updateRunning(true)
                    await action()
                    updateRunning(false)
                }
            }
        } label: {
            ZStack {
                contentView()
                    .blur(radius: isRunning ? 10 : 0)
                if isRunning {
                    ProgressView()
                }
            }
        }
    }
    
    private func updateRunning(_ value: Bool) {
        withAnimation {
            isRunning = value
        }
        onRunningChanged?(value)
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        switch labelContent {
        case .textOnly(let title):
            Text(title)
        case .textWithImage(let title, let systemImage):
            Label(title, systemImage: systemImage)
        case .custom(let view):
            view
        }
    }
}

import UIKit

public func confirmationAlert(_ title: String? = nil, subtitle: String, completion: @escaping (Bool) -> Void) {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first?.rootViewController else {
        return
    }
    
    let alert = UIAlertController(
        title: title ?? "Confirm Action",
        message: subtitle,
        preferredStyle: .alert
    )
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
        completion(false)
    })
    
    alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
        completion(true)
    })
    
    root.presentedViewController?.present(alert, animated: true)
    ?? root.present(alert, animated: true)
}
