import SwiftUI
import UIKit

/// 跟 `withAnimation` 一樣，但使用者在系統開了「減少動態效果」時就直接切換，不做動畫。
/// 全專案的動畫都改走這個，這是無障礙的基本要求。
@MainActor
func withMotion<Result>(_ animation: Animation? = .default,
                        _ body: () throws -> Result) rethrows -> Result {
    try withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : animation, body)
}
