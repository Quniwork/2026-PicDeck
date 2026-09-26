import SwiftUI

private struct NoteTextHeights: Equatable {
    var full: CGFloat = 0
    var collapsed: CGFloat = 0
}

private struct NoteHeightPreferenceKey: PreferenceKey {
    static var defaultValue = NoteTextHeights()
    static func reduce(value: inout NoteTextHeights, nextValue: () -> NoteTextHeights) {
        let next = nextValue()
        if next.full > 0 { value.full = next.full }
        if next.collapsed > 0 { value.collapsed = next.collapsed }
    }
}

/// Shows four lines until the text actually exceeds that height.
struct ExpandableNoteText: View {
    let text: String
    var font: Font = .subheadline
    var color: Color = .primary
    var collapsedLineCount = 4
    @State private var expanded = false
    @State private var fullHeight: CGFloat = 0
    @State private var collapsedHeight: CGFloat = 0
    @State private var availableWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(font)
                .foregroundStyle(color)
                .multilineTextAlignment(.leading)
                .lineLimit(expanded ? nil : collapsedLineCount)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .topLeading) {
                    Text(text)
                        .font(font)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: availableWidth, alignment: .leading)
                        .hidden()
                        .background(GeometryReader { proxy in
                            Color.clear.preference(key: NoteHeightPreferenceKey.self,
                                                   value: NoteTextHeights(full: proxy.size.height))
                        })
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    Text(text)
                        .font(font)
                        .lineLimit(collapsedLineCount)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: availableWidth, alignment: .leading)
                        .hidden()
                        .background(GeometryReader { proxy in
                            Color.clear.preference(key: NoteHeightPreferenceKey.self,
                                                   value: NoteTextHeights(collapsed: proxy.size.height))
                        })
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

            if fullHeight > collapsedHeight + 1 {
                Button {
                    withMotion(.easeInOut(duration: 0.2)) { expanded.toggle() }
                } label: {
                    Text(expanded ? "顯示較少" : "顯示更多")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("note.expand")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GeometryReader { proxy in
            Color.clear.onAppear { availableWidth = proxy.size.width }
                .onChange(of: proxy.size.width) { _, width in availableWidth = width }
        })
        .onPreferenceChange(NoteHeightPreferenceKey.self) {
            fullHeight = $0.full
            collapsedHeight = $0.collapsed
        }
        .onChange(of: text) { _, _ in expanded = false }
    }
}
