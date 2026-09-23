import AppIntents
import SwiftUI
import UIKit
import WidgetKit

// MARK: - 選擇要顯示哪個標籤

struct TagEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Tag"
    static var defaultQuery = TagQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }
}

struct TagQuery: EntityQuery {
    private func all() -> [TagEntity] {
        (WidgetSnapshot.load()?.tags ?? []).map { TagEntity(id: $0.id, name: $0.name) }
    }

    func entities(for identifiers: [String]) async throws -> [TagEntity] {
        all().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [TagEntity] { all() }

    func defaultResult() async -> TagEntity? { all().first }
}

struct SelectTagIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Choose a tag"
    static var description = IntentDescription("Pick the tag to show on your Home Screen.")

    @Parameter(title: "Tag")
    var tag: TagEntity?
}

// MARK: - 時間軸

struct TagEntry: TimelineEntry {
    let date: Date
    let tag: WidgetTag?
    let dayText: String?
}

struct TagProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TagEntry {
        TagEntry(date: Date(),
                 tag: WidgetTag(id: "sample", name: "Tag", emoji: "🍜", symbolName: nil,
                                countText: "12", dayTexts: [], coverFiles: [], coverFraming: nil),
                 dayText: nil)
    }

    func snapshot(for configuration: SelectTagIntent, in context: Context) async -> TagEntry {
        entry(for: configuration, on: Date())
    }

    func timeline(for configuration: SelectTagIntent, in context: Context) async -> Timeline<TagEntry> {
        // 每天 0 點換一次，日子的天數才會跟著走。預先排好一週。
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        var entries = [entry(for: configuration, on: Date())]
        for offset in 1...7 {
            if let day = calendar.date(byAdding: .day, value: offset, to: start) {
                entries.append(entry(for: configuration, on: day))
            }
        }
        return Timeline(entries: entries, policy: .atEnd)
    }

    private func entry(for configuration: SelectTagIntent, on date: Date) -> TagEntry {
        let snapshot = WidgetSnapshot.load()
        let tag = snapshot?.tags.first { $0.id == configuration.tag?.id } ?? snapshot?.tags.first
        return TagEntry(date: date, tag: tag, dayText: tag.flatMap { snapshot?.dayText(for: $0, on: date) })
    }
}

// MARK: - 畫面

private func coverImage(_ file: String) -> UIImage? {
    guard let url = WidgetSnapshot.coversDirectory?.appendingPathComponent(file) else { return nil }
    return UIImage(contentsOfFile: url.path)
}

private struct TagIcon: View {
    let tag: WidgetTag
    var body: some View {
        if let emoji = tag.emoji {
            Text(emoji)
        } else {
            Image(systemName: tag.symbolName ?? "tag.fill")
        }
    }
}

private struct CoverView: View {
    let file: String?
    var framing: CoverFraming = .standard
    var body: some View {
        // 圖片放在透明底的 overlay 裡再裁切：圖片再大也不會撐大外面的版面，
        // 疊在上面的文字才會留在卡片範圍內（中尺寸比較寬，以前文字被擠出畫面外）。
        Color.clear
            .overlay {
                if let file, let image = coverImage(file) {
                    PositionedImage(image: image, framing: framing)
                } else {
                    LinearGradient(colors: [Color(red: 0.25, green: 0.6, blue: 1), Color(red: 0.0, green: 0.42, blue: 1)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            }
            .clipped()
    }
}

struct TagCardView: View {
    let entry: TagEntry
    var scale: CGFloat

    var body: some View {
        if let tag = entry.tag {
            let snapshot = WidgetSnapshot.load()
            ZStack {
                CoverView(file: tag.coverFiles.first, framing: tag.coverFraming ?? .standard)
                CardTextOverlay(name: tag.name,
                                primary: entry.dayText ?? tag.countText,
                                secondary: entry.dayText != nil ? tag.countText : nil,
                                position: snapshot?.textPosition ?? .bottom,
                                style: snapshot?.textStyle ?? .shadow,
                                scale: scale) {
                    TagIcon(tag: tag)
                }
            }
            .widgetURL(URL(string: "picdeck://tag/\(tag.id)"))
        } else {
            EmptyTagView()
        }
    }
}

struct EmptyTagView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "tag").font(.title2)
            Text("Open PicDeck and create a tag").font(.caption).multilineTextAlignment(.center)
        }
        .foregroundStyle(.secondary)
    }
}

struct TagWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TagEntry

    var body: some View {
        // 小尺寸與中尺寸都是封面滿版加文字，文字位置與樣式跟 App 的設定同步。
        TagCardView(entry: entry, scale: family == .systemMedium ? 1.0 : 0.85)
    }
}

// MARK: - 小工具

struct TagWidget: Widget {
    let kind = "TagWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectTagIntent.self, provider: TagProvider()) { entry in
            TagWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color(.secondarySystemBackground) }
        }
        .configurationDisplayName("Tag")
        .description("Show one of your tags: its photos and how long it has been.")
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
    }
}

@main
struct PicDeckWidgetBundle: WidgetBundle {
    var body: some Widget { TagWidget() }
}
