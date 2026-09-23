import SwiftUI

/// 日子卡片上文字的位置與樣式。App 的「選集」卡片與桌面小工具共用同一份，設定也同步。
/// 這個檔案 App 與小工具兩邊都會編譯，所以不放需要翻譯的文字（標題由 App 自己補）。
enum CardTextPosition: String, Codable, CaseIterable, Identifiable {
    case top, center, bottom
    var id: String { rawValue }

    var alignment: Alignment {
        switch self {
        case .top: return .topLeading
        case .center: return .leading
        case .bottom: return .bottomLeading
        }
    }
}

enum CardTextStyle: String, Codable, CaseIterable, Identifiable {
    /// 白字加陰影，底下有深色漸層。
    case shadow
    /// 黑字，底下有淺色漸層。
    case dark
    /// 白字，放在半透明黑色底板上。
    case plate
    /// 系統藍字，底下有淺色漸層。
    case accent
    /// 白字，天數放大。
    case bold
    var id: String { rawValue }

    var foreground: Color {
        switch self {
        case .dark: return .black
        case .accent: return Color(red: 0.0, green: 0.478, blue: 1.0)
        default: return .white
        }
    }

    /// 淺色底的樣式用白色漸層，其餘用黑色。
    var usesLightScrim: Bool { self == .dark || self == .accent }
    var primaryScale: CGFloat { self == .bold ? 1.4 : 1.0 }
    var hasPlate: Bool { self == .plate }
    var hasShadow: Bool { self == .shadow || self == .bold }
}

/// 疊在封面上的文字：標籤名稱、日子（或張數）、副標。
struct CardTextOverlay<Icon: View>: View {
    let name: String
    let primary: String
    var secondary: String?
    var position: CardTextPosition = .bottom
    var style: CardTextStyle = .shadow
    /// 整體縮放：小卡片、小尺寸小工具用比較小的字。
    var scale: CGFloat = 1
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        ZStack {
            scrim
            VStack(alignment: .leading, spacing: 3 * scale) {
                if !name.isEmpty {
                    HStack(spacing: 5 * scale) {
                        icon()
                        Text(name).lineLimit(1)
                    }
                    .font(.system(size: 14 * scale, weight: .semibold))
                }
                Text(primary)
                    .font(.system(size: 19 * scale * style.primaryScale, weight: .bold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                if let secondary {
                    Text(secondary)
                        .font(.system(size: 11 * scale))
                        .opacity(0.85)
                }
            }
            .foregroundStyle(style.foreground)
            .shadow(color: style.hasShadow ? .black.opacity(0.45) : .clear, radius: 3, y: 1)
            .padding(style.hasPlate ? 10 * scale : 0)
            .background {
                if style.hasPlate {
                    RoundedRectangle(cornerRadius: 12 * scale, style: .continuous).fill(.black.opacity(0.45))
                }
            }
            .padding(12 * scale)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position.alignment)
        }
    }

    /// 文字後面的漸層，位置跟著文字走：上面就從上往下，中間整片淡淡蓋上，下面從下往上。
    @ViewBuilder
    private var scrim: some View {
        let color: Color = style.usesLightScrim ? .white : .black
        let strength: Double = style.usesLightScrim ? 0.7 : 0.7
        switch position {
        case .top:
            LinearGradient(colors: [color.opacity(strength), .clear], startPoint: .top, endPoint: .center)
        case .center:
            color.opacity(strength * 0.55)
        case .bottom:
            LinearGradient(colors: [.clear, color.opacity(strength)], startPoint: .center, endPoint: .bottom)
        }
    }
}

// MARK: - 封面的定位

/// 封面照片的顯示位置：放大倍數與往哪邊移。App 的卡片、編輯畫面與桌面小工具用同一套算法，看起來一致。
/// x、y 是 -1 到 1 的比例：0 是置中，1 是照片放大後多出來的那一邊移到最靠邊。
struct CoverFraming: Codable, Hashable {
    var zoom: Double = 1
    var x: Double = 0
    var y: Double = 0

    static let standard = CoverFraming()
    static let zoomRange: ClosedRange<Double> = 1...3

    var isDefault: Bool { self == .standard }

    /// 在給定的框裡，照片填滿後的大小。
    func filledSize(image: CGSize, frame: CGSize) -> CGSize {
        guard image.width > 0, image.height > 0 else { return frame }
        let scale = max(frame.width / image.width, frame.height / image.height) * zoom
        return CGSize(width: image.width * scale, height: image.height * scale)
    }

    /// 照片中心相對框中心的位移。
    func offset(image: CGSize, frame: CGSize) -> CGSize {
        let size = filledSize(image: image, frame: frame)
        return CGSize(width: -(size.width - frame.width) / 2 * x,
                      height: -(size.height - frame.height) / 2 * y)
    }

    func clamped() -> CoverFraming {
        CoverFraming(zoom: min(max(zoom, Self.zoomRange.lowerBound), Self.zoomRange.upperBound),
                     x: min(max(x, -1), 1), y: min(max(y, -1), 1))
    }
}

/// 依定位顯示的封面，填滿框並裁掉多的部分。
struct PositionedImage: View {
    let image: UIImage
    var framing: CoverFraming = .standard

    var body: some View {
        GeometryReader { geo in
            let size = framing.filledSize(image: image.size, frame: geo.size)
            let move = framing.offset(image: image.size, frame: geo.size)
            Image(uiImage: image)
                .resizable()
                .frame(width: size.width, height: size.height)
                .position(x: geo.size.width / 2 + move.width, y: geo.size.height / 2 + move.height)
        }
        .clipped()
    }
}
