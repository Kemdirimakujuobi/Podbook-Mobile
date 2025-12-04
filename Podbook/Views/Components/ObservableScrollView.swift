import SwiftUI
import UIKit

// ScrollView wrapper that detects user scroll gestures
struct ObservableScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let onScrollBegin: () -> Void
    let onScrollEnd: () -> Void
    let scrollToIndex: Int?

    init(
        scrollToIndex: Int?,
        onScrollBegin: @escaping () -> Void,
        onScrollEnd: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.onScrollBegin = onScrollBegin
        self.onScrollEnd = onScrollEnd
        self.scrollToIndex = scrollToIndex
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScrollBegin: onScrollBegin, onScrollEnd: onScrollEnd)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        context.coordinator.hostingController = hostingController

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // Update the hosting controller's content
        context.coordinator.hostingController?.rootView = content

        // Handle programmatic scrolling to specific index
        if let index = scrollToIndex, let hostingController = context.coordinator.hostingController {
            // Calculate approximate offset based on line height
            let lineHeight: CGFloat = 50 // Approximate height per line
            let targetY = CGFloat(index) * lineHeight
            let centerOffset = (scrollView.bounds.height / 2) - (lineHeight / 2)
            let scrollY = max(0, targetY - centerOffset)

            if !context.coordinator.isUserScrolling {
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollY), animated: true)
            }
        }
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>?
        var isUserScrolling = false
        var scrollEndTimer: Timer?

        let onScrollBegin: () -> Void
        let onScrollEnd: () -> Void

        init(onScrollBegin: @escaping () -> Void, onScrollEnd: @escaping () -> Void) {
            self.onScrollBegin = onScrollBegin
            self.onScrollEnd = onScrollEnd
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isUserScrolling = true
            onScrollBegin()
            scrollEndTimer?.invalidate()
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                scheduleScrollEnd()
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            scheduleScrollEnd()
        }

        private func scheduleScrollEnd() {
            scrollEndTimer?.invalidate()
            scrollEndTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self] _ in
                self?.isUserScrolling = false
                self?.onScrollEnd()
            }
        }
    }
}
