import SwiftUI
import Photos

/// 選集的「卡片樣式」：日子卡片上文字的位置與樣式、卡片大小、排列方式。
/// 設定全部標籤共用，桌面小工具也用同一份文字位置與樣式。
struct CardSettingsView: View {
    let sampleTag: PhotoTag?
    let sampleCover: PHAsset?

    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    preview
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }

                Section("Text position") {
                    Picker("Text position", selection: $model.cardTextPosition) {
                        ForEach(CardTextPosition.allCases) { Text(title(for: $0)).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("cards.position")
                }

                Section("Text style") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(CardTextStyle.allCases) { style in styleTile(style) }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                } footer: {
                    Text("These settings apply to every card, and the Home Screen widget uses the same text position and style. Card size is set in each block.")
                }
            }
            .appCanvas()
            .navigationTitle("Card style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.accessibilityIdentifier("cards.done")
                }
            }
        }
    }

    // MARK: - 預覽

    private var preview: some View {
        let dimension = CGSize(width: 260, height: 190)
        let scale = CardSize.textScale(for: dimension)
        return ZStack {
            if let sampleCover {
                CoverImage(assetID: sampleCover.localIdentifier, size: 400)
            } else {
                LinearGradient(colors: [Color(red: 0.25, green: 0.6, blue: 1), Color(red: 0.0, green: 0.42, blue: 1)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            CardTextOverlay(name: sampleTag?.name ?? String(localized: "Sample"),
                            primary: sampleTag?.anniversaryText(on: Date()) ?? "6年1個月16天",
                            secondary: nil,
                            position: model.cardTextPosition,
                            style: model.cardTextStyle,
                            scale: scale) {
                if let sampleTag { IconLabel(raw: sampleTag.symbol, size: 17 * scale) } else { Text("🧒") }
            }
        }
        .frame(width: dimension.width, height: dimension.height)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        .padding(.vertical, 8)
    }

    /// 樣式一排縮圖，點一下套用。
    private func styleTile(_ style: CardTextStyle) -> some View {
        let isOn = model.cardTextStyle == style
        return Button {
            model.cardTextStyle = style
        } label: {
            ZStack {
                LinearGradient(colors: [Color(red: 0.55, green: 0.65, blue: 0.9), Color(red: 0.35, green: 0.3, blue: 0.7)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                CardTextOverlay(name: "", primary: "100", position: model.cardTextPosition,
                                style: style, scale: 0.55) { EmptyView() }
            }
            .frame(width: 74, height: 88)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(isOn ? Color.accentColor : Color.clear, lineWidth: 3))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title(for: style)))
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("cards.style.\(style.rawValue)")
    }

    private func title(for position: CardTextPosition) -> String {
        switch position {
        case .top: return String(localized: "Top")
        case .center: return String(localized: "Middle")
        case .bottom: return String(localized: "Bottom")
        }
    }

    private func title(for style: CardTextStyle) -> String {
        switch style {
        case .shadow: return String(localized: "White")
        case .dark: return String(localized: "Black")
        case .plate: return String(localized: "Plate")
        case .accent: return String(localized: "Blue")
        case .bold: return String(localized: "Large text")
        }
    }
}
