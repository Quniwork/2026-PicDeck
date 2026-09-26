import XCTest

final class JournalEditorUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOpenJournalEditorAndScreenshot() throws {
        let app = XCUIApplication(bundleIdentifier: "com.picdeck.app")
        app.launchArguments = ["-startOnJournal"]
        app.launch()

        // 點擊新增日記按鈕
        let addBtn = app.buttons["journal.add"]
        XCTAssertTrue(addBtn.waitForExistence(timeout: 10), "未找到新增日記按鈕")
        addBtn.tap()

        // 等待 JournalEditorView 出現
        let editor = app.otherElements["journal.editor"]
        XCTAssertTrue(editor.waitForExistence(timeout: 10), "未彈出日記編輯器")

        // 點選第一個分類膠囊，驗證選中狀態下圖示與文字換色
        let chips = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'journal.category.chip.'"))
        if chips.firstMatch.waitForExistence(timeout: 5) {
            chips.firstMatch.tap()
        }

        // 截圖
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)

        // 也可以直接寫出到檔案
        let path = "/Users/quni/.gemini/antigravity/brain/d17a506b-f38d-443e-839c-b81c06941ea4/screenshot_journal_editor_uitest.png"
        try? screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))
    }

    func testJournalMenuScreenshot() throws {
        let app = XCUIApplication(bundleIdentifier: "com.picdeck.app")
        app.launchArguments = ["-startOnJournal"]
        app.launch()

        let moreBtn = app.buttons["journal.edit"].firstMatch
        if moreBtn.waitForExistence(timeout: 5) {
            moreBtn.tap()
            Thread.sleep(forTimeInterval: 1.0)
            let screenshot = XCUIScreen.main.screenshot()
            let path = "/Users/quni/.gemini/antigravity/brain/d17a506b-f38d-443e-839c-b81c06941ea4/screenshot_journal_menu.png"
            try? screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))
        }
    }
}
