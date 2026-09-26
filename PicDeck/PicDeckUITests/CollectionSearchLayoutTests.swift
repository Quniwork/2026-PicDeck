import XCTest

final class CollectionSearchLayoutTests: XCTestCase {
    func testSearchLayoutAndLiveQuery() throws {
        let app = XCUIApplication()
        app.launch()

        let collectionsTab = app.tabBars.buttons["選集"]
        XCTAssertTrue(collectionsTab.waitForExistence(timeout: 10))
        collectionsTab.tap()

        let collectionCard = app.descendants(matching: .any)["home.collection"].firstMatch
        XCTAssertTrue(collectionCard.waitForExistence(timeout: 10))
        collectionCard.tap()

        let modeButton = app.buttons["collection.toggleMode"]
        XCTAssertTrue(modeButton.waitForExistence(timeout: 10))
        if modeButton.label == "切換至柵欄檢視" { modeButton.tap() }
        sleep(1)
        let gridCapture = XCTAttachment(screenshot: app.screenshot())
        gridCapture.name = "collection-grid-header"
        gridCapture.lifetime = .keepAlways
        add(gridCapture)

        modeButton.tap()
        sleep(2)
        let tag = app.descendants(matching: .any)["collection.tag"].firstMatch
        let searchButton = app.buttons["collection.search"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 10))
        if tag.exists {
            XCTAssertLessThan(abs(tag.frame.midY - searchButton.frame.midY), 8)
        }

        let collectionCapture = XCTAttachment(screenshot: app.screenshot())
        collectionCapture.name = "collection-header-and-tag-alignment"
        collectionCapture.lifetime = .keepAlways
        add(collectionCapture)

        searchButton.tap()

        let title = app.staticTexts["搜尋"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["最新清單"].exists)
        XCTAssertFalse(app.staticTexts["標籤清單"].exists)
        XCTAssertGreaterThan(title.frame.minY, app.frame.height * 0.4)
        let field = app.textFields["search.field"]
        XCTAssertTrue(field.exists)
        XCTAssertTrue(app.buttons["search.close"].exists)
        let searchTag = app.buttons["search.chip"].firstMatch
        XCTAssertTrue(searchTag.exists)
        XCTAssertLessThan(searchTag.frame.maxY, field.frame.minY)
        XCTAssertTrue(app.buttons["search.result"].firstMatch.waitForExistence(timeout: 10))

        let otherTag = app.buttons.matching(
            NSPredicate(format: "identifier == %@ AND label ==[c] %@", "search.chip", "test")
        ).firstMatch
        if otherTag.exists {
            otherTag.tap()
            let hasTaggedPhoto = app.buttons["search.result"].firstMatch.waitForExistence(timeout: 2)
            XCTAssertTrue(hasTaggedPhoto || app.staticTexts["沒有符合的項目"].exists)
            otherTag.tap()
        }

        let layoutCapture = XCTAttachment(screenshot: app.screenshot())
        layoutCapture.name = "collection-search-layout"
        layoutCapture.lifetime = .keepAlways
        add(layoutCapture)

        field.tap()
        field.typeText("測試標籤64847")
        XCTAssertEqual(field.value as? String, "測試標籤64847")

        let resultCapture = XCTAttachment(screenshot: app.screenshot())
        resultCapture.name = "collection-search-highlight"
        resultCapture.lifetime = .keepAlways
        add(resultCapture)
    }
}
