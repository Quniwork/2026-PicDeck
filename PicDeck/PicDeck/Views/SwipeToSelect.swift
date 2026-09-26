import SwiftUI
import Photos
import UIKit

/// 網格滑動連選手勢（一滑連選整排照片）
/// 掛載於 ScrollView 內部的 Grid，不阻擋既有單點點擊與原生縱向滾動。
struct GridSwipeToSelectBridge: UIViewRepresentable {
    let isSelecting: Bool
    let columns: Int
    let spacing: CGFloat
    let topInset: CGFloat
    let assetCount: Int
    let onSelectAssetAtIndex: (Int, Bool) -> Void
    let isAssetSelected: (Int) -> Bool

    func makeUIView(context: Context) -> SwipeCoordinatorView {
        let view = SwipeCoordinatorView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: SwipeCoordinatorView, context: Context) {
        uiView.isSelecting = isSelecting
        uiView.columns = columns
        uiView.spacing = spacing
        uiView.topInset = topInset
        uiView.assetCount = assetCount
        uiView.onSelectAssetAtIndex = onSelectAssetAtIndex
        uiView.isAssetSelected = isAssetSelected
        uiView.updateGestureState()
    }

    final class SwipeCoordinatorView: UIView, UIGestureRecognizerDelegate {
        var isSelecting: Bool = false
        var columns: Int = 4
        var spacing: CGFloat = 2
        var topInset: CGFloat = 0
        var assetCount: Int = 0
        var onSelectAssetAtIndex: ((Int, Bool) -> Void)?
        var isAssetSelected: ((Int) -> Bool)?

        private var panGesture: UIPanGestureRecognizer?
        private var initialTargetState: Bool? = nil
        private var lastTouchedIndex: Int? = nil
        private let feedback = UISelectionFeedbackGenerator()
        private var autoScrollLink: CADisplayLink?
        private var autoScrollVelocity: CGFloat = 0
        private weak var parentScrollView: UIScrollView?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            attachGestureIfNeeded()
        }

        func updateGestureState() {
            panGesture?.isEnabled = isSelecting && assetCount > 0
            if !isSelecting {
                stopAutoScroll()
                initialTargetState = nil
                lastTouchedIndex = nil
            }
        }

        private func attachGestureIfNeeded() {
            guard window != nil else { return }
            findParentScrollView()

            if panGesture == nil, let sv = parentScrollView {
                let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                pan.delegate = self
                pan.cancelsTouchesInView = false
                sv.addGestureRecognizer(pan)
                self.panGesture = pan
            }
            updateGestureState()
        }

        private func findParentScrollView() {
            var curr = superview
            while let view = curr {
                if let sv = view as? UIScrollView {
                    parentScrollView = sv
                    return
                }
                curr = view.superview
            }
        }

        override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard isSelecting, assetCount > 0, let pan = gestureRecognizer as? UIPanGestureRecognizer else {
                return false
            }
            guard let sv = parentScrollView else { return false }
            let velocity = pan.velocity(in: sv)
            // 當手指橫向滑動分量明顯大於縱向時（橫掃連選整排），啟動滑動連選；
            // 純縱向拖曳則讓給 UIScrollView 正常捲動。
            return abs(velocity.x) > abs(velocity.y) * 0.7
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // 滑動連選進行中時，避免 UIScrollView 同步縱向滾動產生干擾
            return false
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            let loc = gesture.location(in: self)

            switch gesture.state {
            case .began:
                feedback.prepare()
                if let idx = cellIndex(at: loc) {
                    let currentlySelected = isAssetSelected?(idx) ?? false
                    let target = !currentlySelected
                    initialTargetState = target
                    lastTouchedIndex = idx
                    onSelectAssetAtIndex?(idx, target)
                    feedback.selectionChanged()
                }
                startAutoScrollIfNeeded()

            case .changed:
                guard let target = initialTargetState else { return }
                if let currentIdx = cellIndex(at: loc) {
                    if let last = lastTouchedIndex {
                        if currentIdx != last {
                            let start = min(last, currentIdx)
                            let end = max(last, currentIdx)
                            for i in start...end {
                                onSelectAssetAtIndex?(i, target)
                            }
                            lastTouchedIndex = currentIdx
                            feedback.selectionChanged()
                        }
                    } else {
                        lastTouchedIndex = currentIdx
                        onSelectAssetAtIndex?(currentIdx, target)
                        feedback.selectionChanged()
                    }
                }
                updateAutoScrollVelocity(at: gesture.location(in: window))

            case .ended, .cancelled, .failed:
                initialTargetState = nil
                lastTouchedIndex = nil
                stopAutoScroll()

            default:
                break
            }
        }

        private func cellIndex(at point: CGPoint) -> Int? {
            guard point.x >= 0, point.x <= bounds.width, point.y >= topInset, columns > 0 else { return nil }
            let totalSpacing = CGFloat(columns - 1) * spacing
            let cellWidth = max(1, (bounds.width - totalSpacing) / CGFloat(columns))
            let cellHeight = cellWidth
            let col = Int(point.x / (cellWidth + spacing))
            let row = Int((point.y - topInset) / (cellHeight + spacing))
            guard col >= 0, col < columns, row >= 0 else { return nil }
            let index = row * columns + col
            guard index >= 0, index < assetCount else { return nil }
            return index
        }

        private func startAutoScrollIfNeeded() {
            findParentScrollView()
            if autoScrollLink == nil {
                let link = CADisplayLink(target: self, selector: #selector(autoScrollTick))
                link.add(to: .main, forMode: .common)
                autoScrollLink = link
            }
        }

        private func updateAutoScrollVelocity(at windowLoc: CGPoint) {
            guard let window else { return }
            let topZone: CGFloat = 130
            let bottomZone: CGFloat = window.bounds.height - 110

            if windowLoc.y < topZone {
                let diff = topZone - windowLoc.y
                autoScrollVelocity = -min(diff * 0.3, 16)
            } else if windowLoc.y > bottomZone {
                let diff = windowLoc.y - bottomZone
                autoScrollVelocity = min(diff * 0.3, 16)
            } else {
                autoScrollVelocity = 0
            }
        }

        @objc private func autoScrollTick() {
            guard autoScrollVelocity != 0, let sv = parentScrollView else { return }
            let newY = sv.contentOffset.y + autoScrollVelocity
            let maxY = max(0, sv.contentSize.height - sv.bounds.height + sv.adjustedContentInset.bottom)
            let minY = -sv.adjustedContentInset.top
            let clamped = min(max(newY, minY), maxY)
            sv.setContentOffset(CGPoint(x: sv.contentOffset.x, y: clamped), animated: false)

            if let pan = panGesture, pan.state == .changed {
                handlePan(pan)
            }
        }

        private func stopAutoScroll() {
            autoScrollLink?.invalidate()
            autoScrollLink = nil
            autoScrollVelocity = 0
        }

        deinit {
            stopAutoScroll()
            if let pan = panGesture {
                pan.view?.removeGestureRecognizer(pan)
            }
        }
    }
}

extension View {
    /// 讓網格支援滑動連續選取（橫向一滑連選整排照片，並可持續拖曳）
    func gridSwipeToSelect(
        isSelecting: Bool,
        columns: Int,
        spacing: CGFloat = 2,
        topInset: CGFloat = 0,
        assetCount: Int,
        isSelected: @escaping (Int) -> Bool,
        onSelect: @escaping (Int, Bool) -> Void
    ) -> some View {
        background {
            if isSelecting && assetCount > 0 {
                GridSwipeToSelectBridge(
                    isSelecting: isSelecting,
                    columns: columns,
                    spacing: spacing,
                    topInset: topInset,
                    assetCount: assetCount,
                    onSelectAssetAtIndex: onSelect,
                    isAssetSelected: isSelected
                )
            }
        }
    }
}
