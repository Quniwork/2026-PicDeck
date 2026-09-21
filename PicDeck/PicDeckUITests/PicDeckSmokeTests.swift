import XCTest

/// 冒煙測試：跑過新架構的核心流程。
/// 在桌機執行：
///   xcrun simctl privacy booted reset photos com.picdeck.app
///   xcodebuild test -scheme PicDeck -destination 'platform=iOS Simulator,name=iPhone 16'
final class PicDeckSmokeTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// 首頁直接顯示照片 → 切子分頁 → 整理分頁 → 逐張審核（保留、右滑、刪除）→ 待刪清單。
    func testCoreFlow() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)

        // 首頁應該直接顯示照片，預設停在「日」。
        let allScale = app.buttons["scale.all"]
        XCTAssertTrue(allScale.waitForExistence(timeout: 20), "首頁沒有直接顯示照片")
        sleep(4)
        attachScreenshot(app, name: "01-photos-home")

        // 日子分頁：週一到週日的月曆格狀。
        app.buttons["scale.day"].tap()
        sleep(4)
        attachScreenshot(app, name: "01a-day-calendar")

        // 全部子分頁：純格狀。
        allScale.tap()
        sleep(3)
        attachScreenshot(app, name: "01c-all-grid")

        // 月子分頁：每個月一張卡片，下方是小月曆。
        app.buttons["scale.month"].tap()
        sleep(4)
        attachScreenshot(app, name: "01b-month-calendar")

        // 年 → 點年份 → 自動切到月並捲到該年；分頁列要一直都在。
        app.buttons["scale.year"].tap()
        sleep(3)
        attachScreenshot(app, name: "02-year")

        let firstYear = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'bucket.y'")).firstMatch
        XCTAssertTrue(firstYear.waitForExistence(timeout: 10), "年檢視沒有年份卡片")
        firstYear.tap()
        sleep(4)
        XCTAssertTrue(app.buttons["scale.day"].exists, "切換後子分頁列不見了")
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).exists, "切換後底部分頁列不見了")
        attachScreenshot(app, name: "03-year-to-month")

        // 月 → 點月份 → 自動切到日並捲到該月，格式與日子分頁相同。
        let monthQuery = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'bucket.m'"))
        guard let firstMonth = waitFirst(monthQuery, timeout: 25) else {
            XCTFail("點年份後沒有顯示月份")
            return
        }
        firstMonth.tap()
        sleep(4)
        XCTAssertTrue(app.buttons["scale.timeline"].exists, "切換後子分頁列不見了")
        attachScreenshot(app, name: "04-month-to-day")

        // 日 → 點某天 → 自動切到時間軸並捲到那天。
        let firstDayCell = app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'daycell.'")).firstMatch
        if firstDayCell.waitForExistence(timeout: 10) {
            firstDayCell.tap()
            sleep(4)
            attachScreenshot(app, name: "05-day-to-timeline")
        }

        // 時間軸子分頁。
        app.buttons["scale.timeline"].tap()
        sleep(3)
        attachScreenshot(app, name: "06-timeline")

        // 切回全部後重啟 App，應該記住停在全部。
        sleep(2)
        XCTAssertTrue(allScale.waitForExistence(timeout: 10), "子分頁列不見了")
        tapByCoordinate(allScale)
        sleep(2)
        app.terminate()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        sleep(4)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 15), "重啟後沒有回到照片分頁")
        attachScreenshot(app, name: "07-remembered-scale")

        // 標籤：長按照片建立標籤（免費），再用標籤篩選（付費，未解鎖會導到付費頁）。
        tapByCoordinate(allScale)
        sleep(3)
        let firstPhoto = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'")).firstMatch
        XCTAssertTrue(firstPhoto.waitForExistence(timeout: 15), "格狀沒有縮圖")
        if true {
            XCTAssertTrue(longPressForMenu(firstPhoto,
                                           expecting: ["寫日記", "Write journal"],
                                           in: app),
                          "長按選單沒有寫日記")
            attachScreenshot(app, name: "07-actions-menu")
            XCTAssertTrue(firstButton(in: app, labels: ["加到相簿", "Add to album"]).exists,
                          "長按選單沒有加到相簿")

            // 先寫一篇日記，日曆上要出現心情表情。
            tapByCoordinate(firstButton(in: app, labels: ["寫日記", "Write journal"]))
            sleep(2)
            attachScreenshot(app, name: "07d-journal-editor")
            // 心情改用共用的圖示選擇器。
            if app.buttons["journal.mood"].waitForExistence(timeout: 5) {
                tapByCoordinate(app.buttons["journal.mood"])
                sleep(2)
                let cells = app.buttons.matching(NSPredicate(format: "label == %@", "🎉"))
                if let happy = waitFirst(cells, timeout: 8) {
                    tapByCoordinate(happy)
                } else {
                    tapByCoordinate(app.buttons["icon.shuffle"])
                }
                sleep(2)
            }
            // 挑幾張當天的照片附到這篇日記。
            let pickable = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
            let pickCount = min(pickable.count, 5)
            for index in 0..<pickCount {
                let cell = pickable.element(boundBy: index)
                if cell.exists { cell.tap() }
            }
            sleep(1)
            attachScreenshot(app, name: "07d2-journal-photo-picker")
            tapByCoordinate(app.buttons["journal.save"])
            sleep(2)

            // 日記是付費功能，先解鎖再看。
            app.tabBars.buttons.element(boundBy: 0).tap()
            sleep(3)
            let sponsor = firstButton(in: app, labels: ["訂閱（開發期間免費）", "Subscribe (free during development)"])
            if sponsor.waitForExistence(timeout: 6) {
                attachScreenshot(app, name: "07f1-journal-paywall")
                tapByCoordinate(sponsor)
                sleep(2)
                app.tabBars.buttons.element(boundBy: 0).tap()
                sleep(3)
            }

            // 日記分頁應該只列出有寫日記的日子。
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "2026")).firstMatch
                            .waitForExistence(timeout: 10), "日記分頁沒有列出日記")
            attachScreenshot(app, name: "07f-journal-collapsed")

            // 點第四張要展開顯示全部，而不是進入編輯。
            let expandCell = app.images["journal.expand"]
            if expandCell.waitForExistence(timeout: 6) {
                expandCell.tap()
                sleep(2)
                XCTAssertFalse(app.buttons["journal.save"].exists, "點第四張變成編輯了")
                XCTAssertFalse(app.images["journal.expand"].exists, "展開後第四張還留著展開標記")
                attachScreenshot(app, name: "07g-journal-expanded")

                // 展開後再點同一格應該是放大。
                let fourth = app.images["journal.photo.3"]
                if fourth.exists {
                    fourth.tap()
                    sleep(2)
                    attachScreenshot(app, name: "07h-journal-zoom")
                    app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.08)).tap()
                    sleep(1)
                }
            }

            // 寫完日記後，日曆該天右上角要出現心情表情。
            tapByCoordinate(app.buttons["scale.day"])
            sleep(4)
            attachScreenshot(app, name: "07e-day-with-mood")
            tapByCoordinate(allScale)
            sleep(3)

            // 再長按一次去加標籤。
            XCTAssertTrue(longPressForMenu(firstPhoto, expecting: ["加入標籤", "Add tag"], in: app),
                          "長按選單沒有標籤")
            let addTags = firstButton(in: app, labels: ["加入標籤", "Add tag"])
            if true {
                tapByCoordinate(addTags)
                sleep(2)
                attachScreenshot(app, name: "07a-tag-picker")

                // 建立標籤是一顆按鈕，點開才是圖示、名稱與紀念日的表單。
                tapByCoordinate(app.buttons["tag.create"])
                sleep(2)
                let nameField = app.textFields["tag.name"]
                XCTAssertTrue(nameField.waitForExistence(timeout: 8), "標籤輸入欄沒有出現")
                typeInto(nameField, "旅行", in: app)
                // 標籤已存在時建立會是停用的，先取消再繼續。
                if app.buttons["tag.save"].isEnabled {
                    tapByCoordinate(app.buttons["tag.save"])
                } else {
                    tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
                }
                sleep(2)
                attachScreenshot(app, name: "07b-tag-created")
                tapByCoordinate(app.buttons["tagpicker.done"])
                sleep(2)
            }
        }

        // 篩選選單裡應該看得到剛建立的標籤。
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(2)
        attachScreenshot(app, name: "07c-filter-with-tags")
        // 點選單外面關掉它，不要去抓任意按鈕。
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.88)).tap()
        sleep(1)

        // 多選：全部與時間軸右上角的選擇按鈕。
        let selectButton = app.buttons["photos.select"]
        XCTAssertTrue(selectButton.waitForExistence(timeout: 10), "全部沒有選擇按鈕")
        tapByCoordinate(selectButton)
        sleep(1)

        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        XCTAssertGreaterThan(thumbs.count, 0, "格狀畫面沒有照片")

        // 選第一張，底部操作列出現。
        tapByCoordinate(thumbs.element(boundBy: 0))
        sleep(1)
        attachScreenshot(app, name: "07i-select-one")

        XCTAssertTrue(app.buttons["batch.tags"].waitForExistence(timeout: 5), "多選沒有標籤")
        XCTAssertTrue(app.buttons["batch.favorite"].exists, "多選沒有加入喜愛")
        XCTAssertTrue(app.buttons["batch.album"].exists, "多選沒有加入相簿")
        // 單張一定同一天，寫日記要顯示。
        XCTAssertTrue(app.buttons["batch.journal"].exists, "單張選取沒有寫日記")

        // 再選一張，數量要累加。
        if thumbs.count > 1 {
            tapByCoordinate(thumbs.element(boundBy: 1))
            sleep(1)
            attachScreenshot(app, name: "07j-select-two")
        }

        // 加入喜愛：已經是喜愛的會被跳過，結束後離開多選。
        tapByCoordinate(app.buttons["batch.favorite"])
        sleep(3)
        XCTAssertFalse(app.buttons["batch.favorite"].exists, "加入喜愛後沒有離開多選")
        attachScreenshot(app, name: "07k-after-batch-favorite")

        // 多選寫日記：預設要帶入勾選的照片。
        tapByCoordinate(selectButton)
        sleep(1)
        tapByCoordinate(thumbs.element(boundBy: 0))
        sleep(1)
        tapByCoordinate(app.buttons["batch.journal"])
        sleep(3)
        XCTAssertTrue(app.buttons["journal.save"].waitForExistence(timeout: 10),
                      "多選寫日記沒有開啟編輯畫面")
        // 照片區標題會顯示已選張數，帶進來的照片要先勾好，所以不會是 0。
        let zeroHeader = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "(0)"))
        XCTAssertEqual(zeroHeader.count, 0, "多選寫日記沒有預設勾選照片")
        attachScreenshot(app, name: "07l-journal-preselected")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
        sleep(2)

        // 首頁。
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        attachScreenshot(app, name: "08-home")

        // 整理分頁。
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(4)
        attachScreenshot(app, name: "09-organize-list")

        // 免費可用的月份列，點進去開始審核。前四列是固定入口，月份從第五列開始。
        let monthRow = app.cells.element(boundBy: 4)
        guard monthRow.waitForExistence(timeout: 10) else {
            XCTFail("整理分頁沒有月份列")
            return
        }
        monthRow.tap()
        sleep(4)

        let deleteButton = app.buttons["session.delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 15), "審核畫面沒有載入")
        attachScreenshot(app, name: "10-review")

        // 保留只用手勢：左滑。
        swipeReviewCard(app, from: (0.85, 0.42), to: (0.12, 0.42))
        sleep(1)
        attachScreenshot(app, name: "11-after-keep")

        // 右滑回上一張，畫面必須留在審核頁。
        swipeReviewCard(app, from: (0.45, 0.42), to: (0.92, 0.42))
        sleep(1)
        XCTAssertTrue(app.buttons["session.delete"].exists, "右滑把畫面退回上一層了")
        attachScreenshot(app, name: "12-after-swipe-right")

        // 刪除一張後開待刪清單。
        tapByCoordinate(deleteButton)
        sleep(1)
        tapByCoordinate(app.buttons["session.trash"])
        sleep(2)
        attachScreenshot(app, name: "14-trash")
    }

    /// 只檢查標籤名稱不可重複這件事，不碰其他畫面。
    func testDuplicateTagNameIsRejected() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)

        // 長按第一張照片開標籤畫面。
        guard let firstPhoto = waitFirst(app.images.matching(
            NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))) else {
            XCTFail("格狀畫面沒有照片")
            return
        }
        XCTAssertTrue(longPressForMenu(firstPhoto, expecting: ["加入標籤", "Add tag"], in: app),
                      "長按選單沒有標籤")
        tapByCoordinate(firstButton(in: app, labels: ["加入標籤", "Add tag"]))
        sleep(2)

        // 建立標籤是一顆按鈕，點開才是圖示、名稱與紀念日的表單。
        XCTAssertTrue(app.buttons["tag.create"].waitForExistence(timeout: 10), "加標籤沒有建立標籤")
        tapByCoordinate(app.buttons["tag.create"])
        sleep(2)

        let nameField = app.textFields["tag.name"]
        let addButton = app.buttons["tag.save"]
        let warning = app.staticTexts["tag.duplicate"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 10), "標籤輸入欄沒有出現")

        // 同一張表單裡就有紀念日。
        XCTAssertTrue(app.switches["tag.anniversary.toggle"].exists, "建立標籤沒有紀念日")
        attachScreenshot(app, name: "15a-tag-form")

        // 先確保有一個叫 Trip 的標籤。已經存在時建立會是停用的。
        typeInto(nameField, "Trip", in: app)
        sleep(1)
        if addButton.isEnabled {
            XCTAssertFalse(warning.exists, "第一次輸入就誤判成重複")
            tapByCoordinate(addButton)
            sleep(3)
            attachScreenshot(app, name: "15-tag-created")
            tapByCoordinate(app.buttons["tag.create"])
            sleep(2)
            typeInto(nameField, "Trip", in: app)
            sleep(1)
        }

        // 同名：不能建立，而且要顯示提示。
        XCTAssertFalse(addButton.isEnabled, "同名標籤仍然可以新增")
        XCTAssertTrue(warning.waitForExistence(timeout: 5), "同名沒有顯示提示")
        attachScreenshot(app, name: "16-tag-duplicate")

        // 只有大小寫不同也算重複。
        nameField.typeText(XCUIKeyboardKey.delete.rawValue + "p")
        sleep(1)
        XCTAssertFalse(addButton.isEnabled, "只差大小寫的標籤仍然可以新增")
        XCTAssertTrue(warning.exists, "只差大小寫沒有顯示提示")
        attachScreenshot(app, name: "17-tag-duplicate-case")

        // 換一個沒用過的名字，就要能建立。
        nameField.typeText("-\(Int(Date().timeIntervalSince1970))")
        sleep(1)
        XCTAssertTrue(addButton.isEnabled, "不同名的標籤卻不能新增")
        XCTAssertFalse(warning.exists, "不同名卻顯示重複提示")
        attachScreenshot(app, name: "18-tag-unique-ok")

        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
        sleep(2)
        tapByCoordinate(app.buttons["tagpicker.done"])
        sleep(1)
    }

    /// 只檢查紀念日標籤與重做後的日記排版，不跑其他流程。
    /// 啟動參數會先放一個 2020/8/5 起算、名叫「堯」的紀念日標籤。
    func testAnniversaryTagAndJournalLayout() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag"]
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.timeline"].waitForExistence(timeout: 20), "首頁沒有載入")

        // 沒有篩選標籤時，日期標題維持乾淨，不顯示紀念日。
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(4)
        let chips = app.descendants(matching: .any).matching(identifier: "anniversary.chip")
        XCTAssertEqual(chips.count, 0, "沒篩選標籤時不該顯示紀念日")
        attachScreenshot(app, name: "19a-timeline-plain")

        // 依標籤篩選是付費功能，先解鎖。
        openTagFilter(in: app, named: "堯")
        let sponsor = firstButton(in: app, labels: ["訂閱（開發期間免費）", "Subscribe (free during development)"])
        if sponsor.waitForExistence(timeout: 4) {
            tapByCoordinate(sponsor)
            sleep(3)
            openTagFilter(in: app, named: "堯")
        }

        // 篩選到堯之後，每一天的標題下方要出現年月日。
        XCTAssertNotNil(waitFirst(chips), "篩選到紀念日標籤後沒有顯示年月日")
        let chipLabel = chips.firstMatch.label
        XCTAssertFalse(chipLabel.contains("堯"), "標題不該重複標籤名稱：\(chipLabel)")
        XCTAssertTrue(chipLabel.contains("天"), "紀念日沒有顯示天數：\(chipLabel)")
        attachScreenshot(app, name: "19-timeline-anniversary")

        // 日記分頁（獨立的分頁）：卡片版面，右上角用標籤篩選。
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(3)
        let cards = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "journal.entry."))
        let totalBefore = cards.count
        XCTAssertGreaterThan(totalBefore, 0, "日記分頁沒有日記")

        func journalFilter(_ name: String) {
            tapByCoordinate(app.buttons["journal.filter"])
            sleep(1)
            let item = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", name)).firstMatch
            XCTAssertTrue(item.waitForExistence(timeout: 5), "日記篩選選單沒有 \(name)")
            tapByCoordinate(item)
            sleep(3)
        }
        journalFilter("堯")
        attachScreenshot(app, name: "20-journal-cards")
        let filteredCount = cards.count
        if filteredCount == 0 {
            XCTAssertTrue(app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "沒有日記")).firstMatch.exists,
                          "篩選後沒有日記，卻沒有顯示空狀態")
        }

        // 取消篩選後還看得到日記。
        journalFilter("所有項目")
        XCTAssertGreaterThan(cards.count, 0, "取消篩選後日記不見了")
        attachScreenshot(app, name: "20a-journal-unfiltered")

        // 再篩回堯，確認篇數回到篩選後的數量。
        journalFilter("堯")
        XCTAssertEqual(cards.count, filteredCount, "重新篩選後日記篇數對不上")
        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(2)

        // 換回所有項目，紀念日要跟著收起來。
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(2)
        chooseAllItems(in: app)
        XCTAssertEqual(chips.count, 0, "取消標籤篩選後仍然顯示紀念日")

        // 更多 → 標籤 → 堯，確認計算方式的五種換算。
        openOrganize("tags", in: app)
        guard let tagRow = waitFirst(app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "堯")), timeout: 10) else {
            XCTFail("標籤清單裡沒有堯")
            return
        }
        attachScreenshot(app, name: "21a-manage-tag-list")
        tagRow.tap()
        sleep(3)
        attachScreenshot(app, name: "21b-tag-editor-opened")

        for style in ["dday", "days", "weeks", "months", "yearMonthDay"] {
            XCTAssertTrue(app.buttons["tag.style.\(style)"].waitForExistence(timeout: 8),
                          "計算方式少了 \(style)")
        }
        attachScreenshot(app, name: "21-tag-anniversary-editor")

        // 用測試自己算一次，跟畫面上的數字對。
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        guard let start = calendar.date(from: DateComponents(year: 2020, month: 8, day: 5)) else {
            XCTFail("組不出日期")
            return
        }
        let today = calendar.startOfDay(for: Date())
        let elapsed = calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: today).day ?? 0
        let ymd = calendar.dateComponents([.year, .month, .day],
                                          from: calendar.startOfDay(for: start), to: today)
        let inclusive = elapsed + 1

        expect(app.buttons["tag.style.dday"], contains: "D+\(elapsed)")
        expect(app.buttons["tag.style.days"], contains: "\(inclusive)天")
        expect(app.buttons["tag.style.weeks"], contains: "\(inclusive / 7)週\(inclusive % 7)天")
        expect(app.buttons["tag.style.yearMonthDay"],
               contains: "\(ymd.year ?? 0)年\(ymd.month ?? 0)個月\(ymd.day ?? 0)天")

        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
        sleep(1)
    }

    /// 在審核畫面的照片上滑動。座標是螢幕寬高的比例。
    private func swipeReviewCard(_ app: XCUIApplication,
                                 from: (CGFloat, CGFloat),
                                 to: (CGFloat, CGFloat)) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: from.0, dy: from.1))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: to.0, dy: to.1))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    /// 整理分頁 → 指定的子層：photos、tags、albums。
    /// 第一次切到整理分頁時偶爾還沒換過去，找不到子層按鈕就再點一次分頁。
    private func openOrganize(_ section: String, in app: XCUIApplication) {
        let button = app.buttons["organize.section.\(section)"]
        for _ in 0..<3 {
            app.tabBars.buttons.element(boundBy: 3).tap()
            if button.waitForExistence(timeout: 6) { break }
        }
        if !button.exists { attachScreenshot(app, name: "organize-section-missing") }
        tapByCoordinate(button)
        sleep(2)
    }

    /// 點進輸入欄再打字。點一次不一定拿得到鍵盤焦點，所以會重試。
    private func typeInto(_ field: XCUIElement, _ text: String, in app: XCUIApplication) {
        XCTAssertTrue(field.waitForExistence(timeout: 10), "找不到輸入欄：\(field)")
        for _ in 0..<4 {
            field.tap()
            usleep(700_000)
            if app.keyboards.element.exists { break }
        }
        field.typeText(text)
    }

    /// 清單是延遲載入的，還沒捲到的列不在畫面階層裡，所以一邊往下捲一邊找。
    private func scrollUntilFound(_ query: XCUIElementQuery,
                                  in app: XCUIApplication,
                                  maxSwipes: Int = 6) -> XCUIElement? {
        for _ in 0..<maxSwipes {
            if query.firstMatch.exists { return query.firstMatch }
            app.swipeUp()
            usleep(600_000)
        }
        return query.firstMatch.exists ? query.firstMatch : nil
    }

    /// 按住把手拖到畫面高度的某個比例。
    private func dragScrubber(_ handle: XCUIElement,
                              in app: XCUIApplication,
                              to fraction: CGFloat) {
        let start = handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: fraction))
        start.press(forDuration: 0.4, thenDragTo: end)
    }

    /// 點標題打開選單 → 指定的標籤。標籤切換現在在標題，不在右上角的篩選。
    /// iOS 27 的選單項目不一定是「按鈕」這種元素類型，所以不限類型，用文字找。
    private func openTagFilter(in app: XCUIApplication, named name: String) {
        tapByCoordinate(app.descendants(matching: .any).matching(identifier: "photos.title").firstMatch)
        sleep(2)
        tapByCoordinate(menuButton(in: app, containing: name))
        sleep(3)
    }

    /// 點標題打開選單 → 所有項目。
    private func chooseAllItems(in app: XCUIApplication) {
        tapByCoordinate(app.descendants(matching: .any).matching(identifier: "photos.title").firstMatch)
        sleep(2)
        tapByCoordinate(app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@ OR label == %@", "所有項目", "All Items")).firstMatch)
        sleep(3)
    }

    /// 選單裡標籤那列，名稱前面可能還有圖示，所以用包含比對，也不限元素類型。
    private func menuButton(in app: XCUIApplication, containing text: String) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }


    /// 這個元素的文字要包含指定內容。
    private func expect(_ element: XCUIElement, contains text: String,
                        file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.exists, "找不到元素", file: file, line: line)
        let label = element.label
        XCTAssertTrue(label.contains(text),
                      "算出來的是「\(label)」，預期要包含「\(text)」",
                      file: file, line: line)
    }

    /// 只檢查新的圖示選擇器與「管理相簿與標籤」這一頁。
    func testIconPickerAndLibraryManager() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")

        // 更多 → 管理相簿與標籤。
        openOrganize("albums", in: app)
        attachScreenshot(app, name: "22-manage-albums")

        // 相簿：新增一個，確認出現在清單裡。
        let stamp = "\(Int(Date().timeIntervalSince1970) % 100000)"
        let albumName = "測試相簿\(stamp)"
        // 跟標籤一樣，用「建立相簿或資料夾」按鈕，不再有行內輸入欄。
        XCTAssertTrue(app.buttons["album.create"].waitForExistence(timeout: 10), "沒有建立相簿或資料夾")
        XCTAssertFalse(app.textFields["album.name"].exists, "不該再有行內的相簿輸入欄")
        tapByCoordinate(app.buttons["album.create"])
        sleep(2)
        typeInto(app.textFields["albumform.name"], albumName, in: app)
        sleep(1)
        XCTAssertTrue(app.buttons["albumform.save"].isEnabled, "輸入名稱後仍不能建立相簿")
        tapByCoordinate(app.buttons["albumform.save"])
        sleep(4)

        let albumRow = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", albumName))
        XCTAssertNotNil(scrollUntilFound(albumRow, in: app), "新增的相簿沒有出現")
        attachScreenshot(app, name: "23-manage-album-added")

        // 同名不能再建立一次。
        tapByCoordinate(app.buttons["album.create"])
        sleep(2)
        typeInto(app.textFields["albumform.name"], albumName, in: app)
        sleep(1)
        XCTAssertFalse(app.buttons["albumform.save"].isEnabled, "同名相簿仍然可以建立")
        XCTAssertTrue(app.staticTexts["albumform.duplicate"].exists, "同名相簿沒有顯示提示")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
        sleep(2)

        // 切到標籤子層。
        tapByCoordinate(app.buttons["organize.section.tags"])
        sleep(2)
        attachScreenshot(app, name: "24-manage-tags")

        // 管理頁的建立標籤，裡面才是圖示、名稱與紀念日。
        XCTAssertTrue(app.buttons["manage.tag.create"].waitForExistence(timeout: 10),
                      "管理頁沒有建立標籤")
        tapByCoordinate(app.buttons["manage.tag.create"])
        sleep(2)
        XCTAssertTrue(app.switches["tag.anniversary.toggle"].waitForExistence(timeout: 8),
                      "建立標籤沒有紀念日")

        // 圖示選擇器：兩頁、搜尋、顏色、隨機、移除。
        tapByCoordinate(app.buttons["tag.icon"])
        sleep(2)
        XCTAssertTrue(app.buttons["icon.shuffle"].waitForExistence(timeout: 10), "選擇器沒有隨機")
        XCTAssertTrue(app.buttons["icon.remove"].exists, "選擇器沒有移除")
        XCTAssertFalse(app.buttons["icon.color"].exists, "表情符號那頁不該有顏色")
        attachScreenshot(app, name: "25-icon-picker-emoji")

        // 換到圖示頁，這時才有顏色可以挑。
        let iconTab = firstButton(in: app, labels: ["圖標", "Icons"])
        XCTAssertTrue(iconTab.waitForExistence(timeout: 8), "選擇器沒有圖示頁")
        tapByCoordinate(iconTab)
        sleep(2)
        XCTAssertTrue(app.buttons["icon.color"].waitForExistence(timeout: 8), "圖示那頁沒有顏色")
        tapByCoordinate(app.buttons["icon.color"])
        sleep(2)

        // 配色盤顯示的是色點，不是文字。
        let swatches = app.buttons.matching(identifier: "icon.swatch")
        XCTAssertGreaterThan(swatches.count, 5, "配色盤沒有色點")
        XCTAssertTrue(app.descendants(matching: .any)
            .matching(identifier: "icon.color.useCustom").firstMatch.exists,
                      "配色盤沒有自訂顏色")
        attachScreenshot(app, name: "26a-icon-color-palette")

        let red = swatches.matching(NSPredicate(format: "label == %@", "red")).firstMatch
        XCTAssertTrue(red.waitForExistence(timeout: 5), "配色盤沒有紅色")
        tapByCoordinate(red)
        sleep(2)

        // 搜尋後挑一個圖示。
        let search = app.textFields["icon.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 8), "選擇器沒有搜尋欄")
        typeInto(search, "heart", in: app)
        sleep(2)
        attachScreenshot(app, name: "26-icon-picker-symbols")
        let hits = app.buttons.matching(identifier: "icon.item")
        guard let hit = waitFirst(hits, timeout: 8) else {
            XCTFail("搜尋 heart 沒有結果")
            return
        }
        XCTAssertTrue(hit.label.contains("heart"), "搜尋結果不是 heart：\(hit.label)")
        tapByCoordinate(hit)
        sleep(2)

        // 回到表單，填名字建立。
        let tagField = app.textFields["tag.name"]
        XCTAssertTrue(tagField.waitForExistence(timeout: 10), "沒有回到建立標籤表單")
        let tagName = "測試標籤\(stamp)"
        typeInto(tagField, tagName, in: app)
        sleep(1)
        tapByCoordinate(app.buttons["tag.save"])
        sleep(3)

        let tagRow = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", tagName))
        XCTAssertNotNil(scrollUntilFound(tagRow, in: app), "新增的標籤沒有出現")
        attachScreenshot(app, name: "27-manage-tag-added")

        // 點進去要看得到紀念日設定。
        guard let row = scrollUntilFound(tagRow, in: app) else {
            XCTFail("找不到新增的標籤")
            return
        }
        row.tap()
        sleep(3)
        XCTAssertTrue(app.buttons["tag.save"].waitForExistence(timeout: 10),
                      "沒有開啟標籤編輯表單")
        XCTAssertTrue(app.switches["tag.anniversary.toggle"].exists,
                      "標籤編輯頁沒有紀念日開關")
        attachScreenshot(app, name: "28-tag-editor-from-manager")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
        sleep(1)
    }

    /// 只檢查右側的拖拉軸：捲動時才出現、拖動會捲、拖動時顯示年月、年份與日期區間。
    func testScrubber() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")

        let scrubber = app.descendants(matching: .any)
            .matching(identifier: "photos.scrubber").firstMatch

        // 一開始、以及切換每一個子分頁之後，把手都不該冒出來。
        // 把手出現後會停留 2.5 秒，所以切換後馬上檢查，不能等。
        XCTAssertFalse(scrubber.exists, "一開始把手就出現了")
        for scale in ["scale.all", "scale.timeline", "scale.day", "scale.month", "scale.year", "scale.timeline", "scale.all"] {
            tapByCoordinate(app.buttons[scale])
            usleep(700_000)
            XCTAssertFalse(scrubber.exists, "切到 \(scale) 之後把手就出現了")
        }
        sleep(3)

        // 往上捲一下，把手才出現。
        app.swipeUp(velocity: .slow)
        XCTAssertTrue(scrubber.waitForExistence(timeout: 5), "捲動之後沒有出現把手")

        let years = app.descendants(matching: .any).matching(identifier: "scrubber.year")
        let month = app.descendants(matching: .any)
            .matching(identifier: "scrubber.month").firstMatch
        let pill = app.descendants(matching: .any)
            .matching(identifier: "scrubber.range").firstMatch

        // 拖到接近頂端。
        dragScrubber(scrubber, in: app, to: 0.16)
        attachScreenshot(app, name: "30-scrubber-dragging")
        XCTAssertGreaterThan(years.count, 0, "拖動時沒有顯示年份")
        XCTAssertTrue(month.exists, "拖動時把手旁邊沒有年月")
        XCTAssertTrue(pill.exists, "拖動時沒有顯示日期區間")
        XCTAssertFalse(pill.label.isEmpty, "日期區間是空的")

        // 把手要跟著手指走，就算照片很少、內容一屏放得下捲不動也一樣。
        let topY = scrubber.frame.midY

        // 拖到接近底部，年月與區間都要換成比較早的。
        // 放開一陣子後把手會淡出，要先用手指捲一下讓它再出現。
        app.swipeUp(velocity: .slow)
        XCTAssertTrue(scrubber.waitForExistence(timeout: 5), "捲動後把手沒有再出現")
        dragScrubber(app.descendants(matching: .any)
            .matching(identifier: "photos.scrubber").firstMatch, in: app, to: 0.86)
        XCTAssertTrue(month.exists, "拖到底部把手旁邊沒有年月")
        let bottomY = app.descendants(matching: .any)
            .matching(identifier: "photos.scrubber").firstMatch.frame.midY
        XCTAssertGreaterThan(bottomY, topY + 150, "往下拖，把手沒有跟著往下：\(topY) → \(bottomY)")
        // 照片很少、一屏放得下時，區間本來就是全部，所以只檢查有顯示，不比較是否不同。
        XCTAssertFalse(pill.label.isEmpty, "拖到底部沒有日期區間")
        attachScreenshot(app, name: "31-scrubber-bottom")

        // 放開一陣子後，年月與區間要收起來。
        sleep(5)
        XCTAssertFalse(month.exists, "放開之後年月沒有收起來")

        // 時間軸也要有。
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(3)
        app.swipeUp(velocity: .slow)
        XCTAssertTrue(app.descendants(matching: .any)
            .matching(identifier: "photos.scrubber").firstMatch.waitForExistence(timeout: 5),
                      "時間軸捲動後沒有出現把手")
        attachScreenshot(app, name: "32-scrubber-timeline")
    }

    /// 只檢查標籤排序。
    func testTagOrder() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag"]
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")

        // 先到管理頁把第一個標籤往下搬一格。
        openOrganize("tags", in: app)

        let rows = app.buttons.matching(identifier: "manage.tag.row")
        guard rows.count >= 2 else {
            XCTFail("標籤不夠兩個，沒辦法測排序")
            return
        }
        // 編輯模式下每一列的標籤前面會多一個「移除、」，比對前先去掉。
        func plain(_ label: String) -> String {
            label.replacingOccurrences(of: "移除、", with: "")
        }
        let firstBefore = plain(rows.element(boundBy: 0).label)
        let secondBefore = plain(rows.element(boundBy: 1).label)

        let edit = app.buttons["manage.tag.edit"]
        XCTAssertTrue(edit.waitForExistence(timeout: 8), "標籤清單沒有編輯")
        tapByCoordinate(edit)
        sleep(2)
        attachScreenshot(app, name: "33-tag-reorder-edit")

        // 把第一列拖到第二列下面。
        let source = rows.element(boundBy: 0)
        let target = rows.element(boundBy: 1)
        source.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5))
            .press(forDuration: 0.9,
                   thenDragTo: target.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 1.2)))
        sleep(3)

        let firstAfter = plain(rows.element(boundBy: 0).label)
        XCTAssertEqual(firstAfter, secondBefore, "拖曳後第一列不是原本的第二列")
        XCTAssertNotEqual(firstAfter, firstBefore, "順序沒有改變")
        attachScreenshot(app, name: "34-tag-reordered")

        tapByCoordinate(app.buttons["tagpicker.done"])
        sleep(2)
    }

    /// 只檢查標題選單與時間軸：標籤切換在標題、時間軸標題以天數為主、不重複標籤名稱。
    func testTitleMenuAndTimelineHeader() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag"]
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.timeline"].waitForExistence(timeout: 20), "首頁沒有載入")
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(3)

        // 上方不再有標籤列。
        XCTAssertEqual(app.buttons.matching(identifier: "tagbar.tag").count, 0, "上方不該再有標籤列")

        // 沒篩選：標題只有日期與星期，沒有紀念日天數。
        let chips = app.descendants(matching: .any).matching(identifier: "anniversary.chip")
        attachScreenshot(app, name: "37-timeline-plain")
        XCTAssertEqual(chips.count, 0,
                       "沒篩選卻顯示紀念日：\(chips.allElementsBoundByIndex.map(\.label))")

        // 點標題打開選單，裡面有所有項目與標籤。左邊不再有按鈕，也沒有側邊欄。
        XCTAssertFalse(app.buttons["photos.sidebar"].exists, "左邊的側邊欄按鈕應該拿掉了")
        let title = app.descendants(matching: .any).matching(identifier: "photos.title").firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 8), "沒有可以點的標題")
        tapByCoordinate(title)
        sleep(2)
        attachScreenshot(app, name: "38-title-menu")
        let tagItem = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label CONTAINS %@", "堯")).firstMatch
        XCTAssertTrue(tagItem.waitForExistence(timeout: 5), "標題選單沒有堯")

        // 選堯。標籤篩選是付費功能，先解鎖。
        tapByCoordinate(tagItem)
        sleep(2)
        let sponsor = firstButton(in: app, labels: ["訂閱（開發期間免費）", "Subscribe (free during development)"])
        if sponsor.waitForExistence(timeout: 4) {
            tapByCoordinate(sponsor)
            sleep(3)
            openTagFilter(in: app, named: "堯")
        }

        // 右上角的篩選只剩媒體類型，不再有標籤。
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(2)
        XCTAssertFalse(app.menuItems.matching(NSPredicate(format: "label CONTAINS %@", "堯")).firstMatch.exists,
                       "右上角的篩選不該再列標籤")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5)).tap()
        sleep(1)

        // 篩選後每一天的標題以天數為主，而且不重複標籤名稱。
        guard let chip = waitFirst(chips, timeout: 10) else {
            XCTFail("篩選到紀念日標籤後標題沒有天數")
            return
        }
        XCTAssertFalse(chip.label.contains("堯"), "標題不該重複標籤名稱：\(chip.label)")
        XCTAssertTrue(["年", "D", "天", "週", "月"].contains { chip.label.contains($0) },
                      "標題不是天數：\(chip.label)")
        attachScreenshot(app, name: "39-timeline-anniversary")

        // 回到所有項目，天數收起來。
        chooseAllItems(in: app)
        XCTAssertEqual(chips.count, 0, "回到所有項目後仍顯示紀念日")
    }

    /// 只檢查表情符號的變體：點有膚色的表情符號會跳出選單，沒有變體的直接選。
    func testEmojiVariants() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")
        openOrganize("tags", in: app)
        tapByCoordinate(app.buttons["manage.tag.create"])
        sleep(2)
        tapByCoordinate(app.buttons["tag.icon"])
        sleep(2)

        // 右上角不再有膚色與髮色按鈕。
        XCTAssertFalse(app.buttons["icon.skin"].exists, "不該再有右上角的膚色按鈕")
        XCTAssertFalse(app.buttons["icon.hair"].exists, "不該再有右上角的髮色按鈕")

        // 點一隻手，要跳出膚色選單。目錄現在是完整的，👋 在很後面，先用英文名稱搜尋。
        let search = app.textFields["icon.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 8), "選擇器沒有搜尋欄")
        search.tap()
        search.typeText("waving hand")
        sleep(1)
        let hand = app.buttons.matching(identifier: "icon.item")
            .matching(NSPredicate(format: "label == %@", "👋")).firstMatch
        XCTAssertTrue(hand.waitForExistence(timeout: 8), "找不到 👋")
        tapByCoordinate(hand)
        sleep(2)
        let variants = app.buttons.matching(identifier: "icon.variant")
        XCTAssertGreaterThanOrEqual(variants.count, 6, "點手之後沒有跳出膚色")
        attachScreenshot(app, name: "40-emoji-variants-skin")

        // 選第三個膚色，選單收起來，選擇器也關掉回到表單。
        let picked = variants.element(boundBy: 2).label
        tapByCoordinate(variants.element(boundBy: 2))
        sleep(2)
        XCTAssertEqual(variants.count, 0, "選完之後選單沒有收起來")
        XCTAssertTrue(app.textFields["tag.name"].waitForExistence(timeout: 8), "選完沒有回到表單")
        XCTAssertNotEqual(picked, "👋", "選到的還是原本沒有膚色的")

        // 成人人物還有髮色，選單裡格子比較多。
        tapByCoordinate(app.buttons["tag.icon"])
        sleep(2)
        // 用搜尋把 👩 排到最上面，比捲動穩。
        typeInto(app.textFields["icon.search"], "woman", in: app)
        sleep(2)
        let woman = app.buttons.matching(identifier: "icon.item")
            .matching(NSPredicate(format: "label == %@", "👩")).firstMatch
        XCTAssertTrue(woman.waitForExistence(timeout: 8), "找不到 👩")
        XCTAssertTrue(woman.isHittable, "👩 點不到")
        woman.tap()
        sleep(2)
        attachScreenshot(app, name: "41-emoji-variants-hair")
        XCTAssertGreaterThan(variants.count, 6,
                             "成人人物沒有髮色變體：\(variants.allElementsBoundByIndex.map(\.label))")
        tapByCoordinate(variants.element(boundBy: 7))
        sleep(2)

        // 沒有變體的表情符號，點了直接選。
        tapByCoordinate(app.buttons["tag.icon"])
        sleep(2)
        let smile = app.buttons.matching(identifier: "icon.item")
            .matching(NSPredicate(format: "label == %@", "😀")).firstMatch
        XCTAssertTrue(smile.waitForExistence(timeout: 8), "找不到 😀")
        tapByCoordinate(smile)
        sleep(2)
        XCTAssertEqual(variants.count, 0, "沒有變體的表情符號不該跳出選單")
        XCTAssertTrue(app.textFields["tag.name"].waitForExistence(timeout: 8), "選完沒有回到表單")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
    }

    /// 只檢查選取列（五個動作、含刪除）與長按選單（加到相簿一定在、喜愛狀態會更新）。
    func testSelectionBarAndPhotoMenu() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)

        // 選取列：寫日記（單張一定同一天）、標籤、喜愛、加到相簿、刪除。
        tapByCoordinate(app.buttons["photos.select"])
        sleep(1)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        guard let firstThumb = waitFirst(thumbs, timeout: 10) else {
            XCTFail("格狀畫面沒有照片")
            return
        }
        tapByCoordinate(firstThumb)
        sleep(1)
        attachScreenshot(app, name: "42a-after-first-tap")
        for id in ["batch.journal", "batch.note", "batch.tags", "batch.album", "batch.favorite", "batch.delete"] {
            XCTAssertTrue(app.buttons[id].waitForExistence(timeout: 5), "選取列少了 \(id)")
        }
        attachScreenshot(app, name: "42-selection-bar")
        // 備註：開啟多選寫備註，取消不留資料。
        tapByCoordinate(app.buttons["batch.note"])
        XCTAssertTrue(app.textViews["batchnote.text"].waitForExistence(timeout: 8)
                      || app.textFields["batchnote.text"].waitForExistence(timeout: 2), "多選備註沒有輸入欄")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
        sleep(1)
        // 小圖示加文字：文字要跟圖示在同一顆按鈕裡。
        XCTAssertTrue(app.buttons["batch.delete"].label.contains("刪除")
                      || app.buttons["batch.delete"].label.lowercased().contains("delete"),
                      "刪除沒有文字：\(app.buttons["batch.delete"].label)")
        tapByCoordinate(app.buttons["photos.select"])
        sleep(1)

        // 長按選單：加到相簿一定要在，就算目前沒有任何相簿。
        XCTAssertTrue(longPressForMenu(thumbs.firstMatch,
                                       expecting: ["寫日記", "Write journal"], in: app),
                      "長按沒有選單")
        XCTAssertTrue(firstButton(in: app, labels: ["加到相簿", "Add to album"]).exists,
                      "長按選單沒有加到相簿")
        attachScreenshot(app, name: "43-photo-menu")

        // 喜愛：點一下，再叫出選單，字要變成相反的。
        let addFavorite = ["加入喜愛", "Add to favorites"]
        let removeFavorite = ["移出喜愛", "Remove from favorites"]
        let wasFavorite = firstButton(in: app, labels: removeFavorite).exists
        tapByCoordinate(firstButton(in: app, labels: wasFavorite ? removeFavorite : addFavorite))
        sleep(4)

        XCTAssertTrue(longPressForMenu(thumbs.firstMatch,
                                       expecting: ["寫日記", "Write journal"], in: app),
                      "第二次長按沒有選單")
        let expected = wasFavorite ? addFavorite : removeFavorite
        XCTAssertTrue(firstButton(in: app, labels: expected).exists,
                      "改了喜愛之後，選單沒有變成 \(expected)")
        attachScreenshot(app, name: "44-photo-menu-after-favorite")

        // 還原，不要動到使用者的照片狀態。
        tapByCoordinate(firstButton(in: app, labels: expected))
        sleep(3)
    }

    /// 只檢查加到相簿：可以建立資料夾、在資料夾底下建立相簿、顯示階層、勾選加入與移出。
    func testAlbumPickerWithFolders() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)

        let stamp = "\(Int(Date().timeIntervalSince1970) % 100000)"
        let folderName = "測試資料夾\(stamp)"
        let albumName = "測試相簿\(stamp)"

        // 長按第一張 → 加到相簿，開的是跟標籤一樣的表單。
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        XCTAssertNotNil(waitFirst(thumbs, timeout: 10), "格狀畫面沒有照片")
        XCTAssertTrue(longPressForMenu(thumbs.firstMatch,
                                       expecting: ["加到相簿", "Add to album"], in: app),
                      "長按沒有選單")
        tapByCoordinate(firstButton(in: app, labels: ["加到相簿", "Add to album"]))
        sleep(2)
        XCTAssertTrue(app.buttons["album.create"].waitForExistence(timeout: 8), "沒有建立按鈕")
        attachScreenshot(app, name: "45-album-picker")

        // 先建一個資料夾。
        tapByCoordinate(app.buttons["album.create"])
        sleep(2)
        let kind = app.segmentedControls["albumform.kind"]
        XCTAssertTrue(kind.waitForExistence(timeout: 8), "表單沒有相簿與資料夾切換")
        kind.buttons["資料夾"].tap()
        typeInto(app.textFields["albumform.name"], folderName, in: app)
        XCTAssertTrue(app.buttons["albumform.save"].isEnabled, "填了名稱卻不能建立")
        attachScreenshot(app, name: "46-folder-form")
        tapByCoordinate(app.buttons["albumform.save"])
        sleep(4)

        let folder = app.buttons.matching(identifier: "albumpicker.folder")
            .matching(NSPredicate(format: "label == %@", folderName)).firstMatch
        XCTAssertTrue(folder.waitForExistence(timeout: 10), "資料夾沒有出現在清單")

        // 再在資料夾底下建一個相簿，照片會順便加進去。
        tapByCoordinate(app.buttons["album.create"])
        sleep(2)
        typeInto(app.textFields["albumform.name"], albumName, in: app)
        tapByCoordinate(app.buttons["albumform.location"])
        sleep(2)
        let choice = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", folderName)).firstMatch
        XCTAssertTrue(choice.waitForExistence(timeout: 8), "位置清單裡沒有剛建的資料夾")
        choice.tap()
        sleep(2)
        attachScreenshot(app, name: "47-album-in-folder-form")
        tapByCoordinate(app.buttons["albumform.save"])
        sleep(4)

        // 資料夾展開時，底下要看到剛建的相簿，而且照片已經在裡面。
        let album = app.buttons.matching(identifier: "albumpicker.row")
            .matching(NSPredicate(format: "label == %@", albumName)).firstMatch
        XCTAssertTrue(album.waitForExistence(timeout: 10), "資料夾底下沒有看到相簿")
        XCTAssertEqual(album.value as? String, "checked", "建立相簿時照片沒有一起加進去")
        attachScreenshot(app, name: "48-album-tree")

        // 點一下移出，再點一下加入。
        tapByCoordinate(album)
        sleep(3)
        XCTAssertNotEqual(album.value as? String, "checked", "點了之後沒有移出")
        tapByCoordinate(album)
        sleep(3)
        XCTAssertEqual(album.value as? String, "checked", "再點一下沒有加回來")

        // 資料夾可以收合，收起來相簿就不列。
        tapByCoordinate(folder)
        sleep(1)
        XCTAssertFalse(album.exists, "收合資料夾後相簿還在")
        tapByCoordinate(app.buttons["albumpicker.done"])
    }

    /// 只檢查整理的審核畫面：功能列、手勢、垃圾桶數字、快速分類列。
    /// 過程中做過的保留、喜愛、刪除都會撤回，不動使用者的照片狀態。
    func testReviewSession() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(3)

        // 整理清單：四個固定入口，全部白底、沒有底色分組。
        // 照片多的時候整理清單要載入一陣子，所以等到出現為止。
        for title in ["所有未整理", "未整理照片", "未整理影片", "未整理截圖"] {
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", title))
                .firstMatch.waitForExistence(timeout: 30), "整理清單少了 \(title)")
        }
        attachScreenshot(app, name: "49-organize-list")

        // 用固定的舊月份（2025 年 11 月），不受今天新拍的照片影響。
        let monthRow = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "2025年11月")).firstMatch
        XCTAssertTrue(monthRow.waitForExistence(timeout: 10), "整理分頁沒有月份列")
        tapByCoordinate(monthRow)
        sleep(4)
        attachScreenshot(app, name: "49b-review-opened")

        // 功能列：標籤、相簿、喜愛、保留、刪除。沒有寫日記、也沒有幫助。
        for id in ["session.tags", "session.albums", "session.favorite", "session.keep", "session.delete"] {
            XCTAssertTrue(app.buttons[id].waitForExistence(timeout: 15), "功能列少了 \(id)")
        }
        XCTAssertFalse(app.buttons["session.journal"].exists, "整理畫面不該有寫日記")
        XCTAssertFalse(app.buttons["session.help"].exists, "幫助應該拿掉")
        attachScreenshot(app, name: "50-review-bar")

        // 左滑保留，下一張；右滑回來會撤銷。
        let counter = { app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", " / ")).firstMatch }
        XCTAssertTrue(counter().label.hasPrefix("1 /"), "一開始不是第一張：\(counter().label)")
        swipeReviewCard(app, from: (0.85, 0.42), to: (0.12, 0.42))
        sleep(1)
        XCTAssertTrue(counter().label.hasPrefix("2 /"), "左滑之後沒有到下一張：\(counter().label)")
        swipeReviewCard(app, from: (0.45, 0.42), to: (0.92, 0.42))
        sleep(1)
        XCTAssertTrue(counter().label.hasPrefix("1 /"), "右滑之後沒有回上一張：\(counter().label)")

        // 下滑：加入喜愛，不換張；再下滑一次就是移出喜愛。
        let badge = app.descendants(matching: .any).matching(identifier: "session.favorite.badge").firstMatch
        let wasFavorite = badge.exists
        swipeReviewCard(app, from: (0.5, 0.25), to: (0.5, 0.7))
        sleep(2)
        XCTAssertTrue(counter().label.hasPrefix("1 /"), "下滑喜愛不該換張：\(counter().label)")
        XCTAssertNotEqual(badge.exists, wasFavorite, "下滑之後喜愛狀態沒有變")
        attachScreenshot(app, name: "51-favorite-toggled")
        swipeReviewCard(app, from: (0.5, 0.25), to: (0.5, 0.7))
        sleep(2)
        XCTAssertEqual(badge.exists, wasFavorite, "再下滑一次沒有還原喜愛狀態")

        // 上滑：加入待刪，垃圾桶出現紅色數字；右滑撤銷之後數字消失。
        let countBadge = app.descendants(matching: .any).matching(identifier: "session.trash.count").firstMatch
        let before = countBadge.exists ? countBadge.label : ""
        swipeReviewCard(app, from: (0.5, 0.7), to: (0.5, 0.15))
        sleep(2)
        XCTAssertTrue(countBadge.waitForExistence(timeout: 5), "上滑之後垃圾桶沒有出現數字")
        attachScreenshot(app, name: "52-trash-count")
        swipeReviewCard(app, from: (0.45, 0.42), to: (0.92, 0.42))
        sleep(2)
        XCTAssertEqual(countBadge.exists ? countBadge.label : "", before, "撤銷後待刪數字沒有還原")

        // 整理畫面不寫日記，但有保留鈕。
        XCTAssertFalse(app.buttons["session.journal"].exists, "整理畫面不該有寫日記")
        XCTAssertTrue(app.buttons["session.keep"].exists, "整理畫面沒有保留鈕")
        let advanced = 0
        for _ in 0..<advanced {
            swipeReviewCard(app, from: (0.45, 0.42), to: (0.92, 0.42))
            sleep(1)
        }

        // 點標籤、相簿：最底下變成快速分類列，第四格是「更多」。
        tapByCoordinate(app.buttons["session.tags"])
        sleep(1)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "session.tagrow").firstMatch
            .waitForExistence(timeout: 5), "點標籤後沒有分類到標籤列")
        XCTAssertTrue(app.staticTexts["分類到標籤…"].exists, "標籤列沒有標題")
        attachScreenshot(app, name: "53-quick-tags")

        tapByCoordinate(app.buttons["session.albums"])
        sleep(1)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "session.albumrow").firstMatch
            .waitForExistence(timeout: 5), "點相簿後沒有分類到相簿列")
        XCTAssertTrue(app.staticTexts["分類到相簿…"].exists, "相簿列沒有標題")
        attachScreenshot(app, name: "54-quick-albums")
        XCTAssertTrue(app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", "更多相簿")).firstMatch.exists,
                      "第四格不是更多相簿")
    }

    /// 介面檢查用：走過每一個主要畫面，淺色與深色各截一輪圖，只截圖，不驗功能。
    func testUIAuditTour() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "首頁沒有載入")

        // 解鎖，好讓付費的畫面也拍得到。
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(2)
        let sponsor = firstButton(in: app, labels: ["訂閱（開發期間免費）", "Subscribe (free during development)"])
        if sponsor.waitForExistence(timeout: 4) {
            tapByCoordinate(sponsor)
            sleep(3)
        }

        func tour(_ mode: String) {
            // 照片分頁的六個子分頁
            for scale in ["year", "month", "day", "journal", "timeline", "all"] {
                tapByCoordinate(app.buttons["scale.\(scale)"])
                sleep(3)
                attachScreenshot(app, name: "A-\(mode)-photos-\(scale)")
            }

            // 標題選單
            tapByCoordinate(app.descendants(matching: .any).matching(identifier: "photos.title").firstMatch)
            sleep(2)
            attachScreenshot(app, name: "A-\(mode)-title-menu")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5)).tap()
            sleep(1)

            // 篩選選單
            tapByCoordinate(app.buttons["photos.filter"])
            sleep(2)
            attachScreenshot(app, name: "A-\(mode)-filter-menu")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5)).tap()
            sleep(1)

            // 選取模式
            tapByCoordinate(app.buttons["photos.select"])
            sleep(1)
            let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
            if let first = waitFirst(thumbs, timeout: 8) { tapByCoordinate(first) }
            sleep(1)
            attachScreenshot(app, name: "A-\(mode)-selecting")
            tapByCoordinate(app.buttons["photos.select"])
            sleep(1)

            // 首頁
            app.tabBars.buttons.element(boundBy: 1).tap()
            sleep(3)
            attachScreenshot(app, name: "A-\(mode)-home")

            // 整理分頁的三個子層與審核畫面
            for section in ["photos", "tags", "albums"] {
                openOrganize(section, in: app)
                attachScreenshot(app, name: "A-\(mode)-organize-\(section)")
            }
            openOrganize("photos", in: app)
            let monthRow = app.cells.element(boundBy: 4)
            if monthRow.waitForExistence(timeout: 20) {
                monthRow.tap()
                sleep(4)
                attachScreenshot(app, name: "A-\(mode)-review")
                if app.buttons["session.tags"].exists {
                    tapByCoordinate(app.buttons["session.tags"])
                    sleep(1)
                    attachScreenshot(app, name: "A-\(mode)-review-quick")
                }
                if app.buttons["session.close"].exists { tapByCoordinate(app.buttons["session.close"]) }
                sleep(2)
            }

            // 更多分頁
            app.tabBars.buttons.element(boundBy: 4).tap()
            sleep(2)
            attachScreenshot(app, name: "A-\(mode)-more")

            // 回到照片分頁
            app.tabBars.buttons.element(boundBy: 2).tap()
            sleep(2)
        }

        tour("light")

        // 切到深色再走一輪
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        let dark = app.segmentedControls["more.appearance"].buttons["深色"]
        XCTAssertTrue(dark.waitForExistence(timeout: 8), "更多裡沒有深色選項")
        dark.tap()
        sleep(2)
        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(2)
        tour("dark")

        // 還原成自動，不改使用者的設定。
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        app.segmentedControls["more.appearance"].buttons["自動"].tap()
    }

    /// 介面檢查的精簡版：只拍側邊欄、多選、資料夾、整理清單、審核畫面，淺色與深色各一輪，約一分鐘。
    func testUIAuditQuick() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "首頁沒有載入")

        func shots(_ mode: String) {
            app.tabBars.buttons.element(boundBy: 2).tap()
            sleep(2)
            XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "\(mode) 一開始找不到子分類列")
            tapByCoordinate(app.buttons["scale.all"])
            sleep(2)
            tapByCoordinate(app.descendants(matching: .any).matching(identifier: "photos.title").firstMatch)
            sleep(2)
            attachScreenshot(app, name: "Q-\(mode)-title-menu")
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5)).tap()
            sleep(1)

            tapByCoordinate(app.buttons["photos.select"])
            sleep(1)
            let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
            if let first = waitFirst(thumbs, timeout: 8) { tapByCoordinate(first) }
            sleep(1)
            attachScreenshot(app, name: "Q-\(mode)-selecting")
            tapByCoordinate(app.buttons["photos.select"])
            sleep(1)

            app.tabBars.buttons.element(boundBy: 1).tap()
            sleep(3)
            attachScreenshot(app, name: "Q-\(mode)-home")

            openOrganize("photos", in: app)
            attachScreenshot(app, name: "Q-\(mode)-organize")
            let monthRow = app.cells.element(boundBy: 4)
            if monthRow.waitForExistence(timeout: 20) {
                monthRow.tap()
                sleep(4)
                attachScreenshot(app, name: "Q-\(mode)-review")
                if app.buttons["session.close"].exists { tapByCoordinate(app.buttons["session.close"]) }
                sleep(2)
            }
            app.tabBars.buttons.element(boundBy: 2).tap()
            sleep(2)
        }

        shots("light")

        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        let dark = app.segmentedControls["more.appearance"].buttons["深色"]
        XCTAssertTrue(dark.waitForExistence(timeout: 8), "更多裡沒有深色選項")
        dark.tap()
        sleep(2)
        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(2)
        shots("dark")

        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        app.segmentedControls["more.appearance"].buttons["自動"].tap()
    }

    /// 把介面外觀設回「自動」。其他測試中斷時可能把模擬器留在深色，用這個還原。
    func testResetAppearanceToAutomatic() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "首頁沒有載入")
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        let automatic = app.segmentedControls["more.appearance"].buttons["自動"]
        XCTAssertTrue(automatic.waitForExistence(timeout: 8), "更多裡沒有自動選項")
        automatic.tap()
        sleep(1)
    }

    /// 只檢查首頁：日子卡片、點卡片跳到照片並套用標籤。
    func testHome() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag"]
        app.launch()

        grantPhotoAccessIfNeeded(app)

        // 預設開在日記；底下五個分頁：日記、選集、照片、整理、更多。
        XCTAssertEqual(app.tabBars.buttons.count, 5, "底部分頁不是五個")
        XCTAssertTrue(app.buttons["journal.add"].waitForExistence(timeout: 20), "預設沒有開在日記")
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.tabBars.buttons["選集"].exists || app.tabBars.buttons["Collections"].exists, "沒有選集分頁")
        XCTAssertFalse(app.tabBars.buttons["資料夾"].exists, "資料夾分頁應該拿掉了")

        // 日子卡片：設了日期的標籤，卡片上有名字與過了多久。
        let card = app.descendants(matching: .any).matching(identifier: "home.anniversary").firstMatch
        if !card.waitForExistence(timeout: 20) { attachScreenshot(app, name: "56z-home-no-card") }
        XCTAssertTrue(card.exists, "首頁沒有紀念日卡片")
        XCTAssertTrue(card.label.contains("堯"), "卡片上沒有標籤名稱：\(card.label)")
        XCTAssertTrue(["年", "天", "週", "月", "D"].contains { card.label.contains($0) },
                      "卡片上沒有過了多久：\(card.label)")
        attachScreenshot(app, name: "56-home")

        XCTAssertFalse(app.descendants(matching: .any).matching(identifier: "home.note").firstMatch.exists, "首頁不該再顯示備註")

        // 點紀念日卡片：跳到照片分頁，標題變成那個標籤。
        for _ in 0..<3 where !card.isHittable { app.swipeDown() }
        tapByCoordinate(card)
        sleep(2)
        let sponsor = firstButton(in: app, labels: ["訂閱（開發期間免費）", "Subscribe (free during development)"])
        if sponsor.waitForExistence(timeout: 4) {
            tapByCoordinate(sponsor)
            sleep(3)
            app.tabBars.buttons.element(boundBy: 1).tap()
            sleep(2)
            attachScreenshot(app, name: "56b-home-after-unlock")
            tapByCoordinate(card)
            sleep(3)
        }
        let title = app.descendants(matching: .any).matching(identifier: "photos.title").firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 10), "點卡片後沒有跳到照片分頁")
        XCTAssertTrue(title.label.contains("堯"), "照片分頁沒有套用標籤：\(title.label)")
        attachScreenshot(app, name: "59-home-to-photos")
    }

    /// 分頁來回切換之後，照片分頁的內容還在不在。
    func testTabSwitchKeepsPhotos() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "一開始就沒有照片分頁")
        attachScreenshot(app, name: "T1-photos-first")

        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)
        attachScreenshot(app, name: "T2-home")

        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(5)
        attachScreenshot(app, name: "T3-photos-again")
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 10), "切回來之後照片分頁是空的")
    }

    /// 從首頁開始，第一次進每個分頁時內容有沒有畫出來。
    /// 曾經因為照片分頁掛了七個獨立的 .sheet，在「首頁之後才第一次建立」時整頁空白，這個測試就是防止再發生。
    func testFirstVisitOfEachTab() throws {
        let app = XCUIApplication()
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30), "沒有分頁列")
        sleep(3)
        try? FileManager.default.createDirectory(atPath: "/tmp/picdeck-shots", withIntermediateDirectories: true)

        for (index, name) in [(4, "more"), (3, "organize"), (2, "photos"), (0, "journal")] {
            app.tabBars.buttons.element(boundBy: index).tap()
            sleep(6)
            let count = app.descendants(matching: .any).allElementsBoundByIndex.count
            let buttons = app.buttons.count
            try? "tab \(name): elements=\(count) buttons=\(buttons)\n".appendToFile("/tmp/picdeck-shots/first-visit.txt")
            // 分頁列本身有 5 顆按鈕，內容有畫出來的話一定比這多。
            XCTAssertGreaterThan(buttons, 5, "\(name) 分頁第一次進去是空的")
            attachScreenshot(app, name: "F-\(name)")
        }
    }

    /// 只檢查：相簿瀏覽併進整理之後，從「整理 → 資料夾及相簿」點相簿能看到裡面的照片。
    func testOpenAlbumFromOrganize() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "首頁沒有載入")

        openOrganize("albums", in: app)
        let album = app.descendants(matching: .any).matching(identifier: "album.row").firstMatch
        XCTAssertTrue(album.waitForExistence(timeout: 10), "整理的資料夾及相簿裡沒有相簿")
        tapByCoordinate(album)
        sleep(3)
        attachScreenshot(app, name: "60-album-from-organize")
        XCTAssertGreaterThan(app.navigationBars.buttons.count, 0, "點相簿之後沒有進到相簿內容（沒有返回鈕）")
        XCTAssertFalse(app.buttons["album.create"].exists, "還停在相簿清單，沒有進到相簿內容")
    }

    /// 刪掉名稱含「測試」的標籤（在整理 → 標籤）。上一次測試中途失敗時會留下，同名就存不進去。
    private func deleteTestTags(in app: XCUIApplication) {
        openOrganize("tags", in: app)
        for _ in 0..<4 {
            let row = app.buttons.matching(identifier: "manage.tag.row")
                .matching(NSPredicate(format: "label CONTAINS %@", "測試")).firstMatch
            guard row.waitForExistence(timeout: 5) else { break }
            tapByCoordinate(row)
            if app.buttons["tag.delete"].waitForExistence(timeout: 5) {
                tapByCoordinate(app.buttons["tag.delete"])
                sleep(1)
            }
        }
    }

    /// 收藏流程：截圖一間餐廳 → 標 #美食 #燒肉、寫備註 → 美食釘在首頁 → 點進去用 #燒肉 二次篩選。
    func testPinnedCollection() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        deleteTestTags(in: app)
        app.tabBars.buttons.element(boundBy: 2).tap()
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        guard let first = waitFirst(thumbs, timeout: 10) else { XCTFail("格狀畫面沒有照片"); return }
        XCTAssertTrue(longPressForMenu(first, expecting: ["寫備註", "Write note"], in: app), "長按選單沒有備註")
        attachScreenshot(app, name: "64-photo-menu")
        tapByCoordinate(firstButton(in: app, labels: ["寫備註", "Write note"]))
        sleep(2)

        let noteField = app.textViews["note.text"].exists ? app.textViews["note.text"] : app.textFields["note.text"]
        XCTAssertTrue(noteField.waitForExistence(timeout: 8), "備註沒有輸入欄")
        noteField.tap()
        noteField.typeText("好吃燒肉店 週二公休")

        // 建立兩個標籤並套到這張照片：美食（釘在首頁）、燒肉。
        tapByCoordinate(app.buttons["note.tags"])
        for (name, pin) in [("測試美食", true), ("測試燒肉", false)] {
            XCTAssertTrue(app.buttons["tag.create"].waitForExistence(timeout: 8), "加標籤沒有建立標籤")
            tapByCoordinate(app.buttons["tag.create"])
            let field = app.textFields["tag.name"]
            XCTAssertTrue(field.waitForExistence(timeout: 8), "沒有標籤名稱欄")
            field.tap()
            field.typeText(name)
            if pin {
                XCTAssertTrue(app.switches["tag.pinHome"].exists, "標籤表單沒有釘選在首頁")
                // 開關在整列的最右邊，點中間只會點到文字。
                app.switches["tag.pinHome"].coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
                XCTAssertEqual(app.switches["tag.pinHome"].value as? String, "1", "釘選在首頁沒有打開")
            }
            sleep(1)
            tapByCoordinate(app.buttons["tag.save"])
            sleep(2)
            if app.textFields["tag.name"].exists {
                // 第一下只用來收起鍵盤或沒點到，再按一次。
                tapByCoordinate(app.buttons["tag.save"])
                sleep(2)
            }
            XCTAssertFalse(app.textFields["tag.name"].exists, "標籤表單沒有關閉：\(name)")
        }
        tapByCoordinate(app.buttons["tagpicker.done"])
        sleep(1)
        attachScreenshot(app, name: "61-note-with-tags")
        tapByCoordinate(app.buttons["note.save"])
        sleep(3)
        attachScreenshot(app, name: "61a-after-save")

        // 首頁多了「釘選的收藏」，只有美食在，燒肉沒有釘。
        app.tabBars.buttons.element(boundBy: 1).tap()
        // 使用者的模擬器裡可能本來就有釘選的標籤，只認這次建的「測試美食」。
        let collection = app.descendants(matching: .any).matching(identifier: "home.collection")
            .matching(NSPredicate(format: "label CONTAINS %@", "測試美食"))
        sleep(2)
        attachScreenshot(app, name: "62a-home-before-scroll")
        for _ in 0..<4 where !collection.firstMatch.waitForExistence(timeout: 3) { app.swipeUp() }
        attachScreenshot(app, name: "62-home-collection")
        XCTAssertTrue(collection.firstMatch.exists, "首頁沒有釘選的收藏")
        XCTAssertEqual(collection.count, 1, "測試美食應該只出現一次")
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "home.collection")
            .matching(NSPredicate(format: "label CONTAINS %@", "測試燒肉")).count, 0, "沒釘選的標籤不該出現在首頁")
        attachScreenshot(app, name: "62-home-collection")

        // 點進去：有備註的項目，上面有二次篩選的 #燒肉。
        tapByCoordinate(collection.firstMatch)
        // 顯示方式會記住，上次測試若停在柵欄，先切回單張。
        let optionsFirst = app.descendants(matching: .any)["collection.options"]
        XCTAssertTrue(optionsFirst.waitForExistence(timeout: 10), "收藏沒有右上角選單")
        tapByCoordinate(optionsFirst)
        sleep(1)
        tapByCoordinate(app.buttons["單張顯示"])
        sleep(2)
        let item = app.descendants(matching: .any).matching(identifier: "collection.item").firstMatch
        sleep(2)
        attachScreenshot(app, name: "62b-collection")
        XCTAssertTrue(item.waitForExistence(timeout: 10), "收藏裡沒有項目")
        XCTAssertTrue(item.label.contains("好吃燒肉店"), "收藏項目沒有顯示備註：\(item.label)")
        let chip = app.descendants(matching: .any).matching(identifier: "collection.chip").firstMatch
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "收藏沒有二次篩選")
        tapByCoordinate(chip)
        sleep(1)
        XCTAssertTrue(item.exists, "用 #燒肉 篩選後這張應該還在")
        attachScreenshot(app, name: "63-collection-filtered")

        // 切到柵欄：縮圖格狀，點一張彈出窗口，可以左右滑；再切回單張。
        let optionsButton = app.descendants(matching: .any)["collection.options"]
        XCTAssertTrue(optionsButton.waitForExistence(timeout: 5), "收藏沒有右上角選單")
        tapByCoordinate(optionsButton)
        sleep(1)
        attachScreenshot(app, name: "64c-collection-menu")
        tapByCoordinate(app.buttons["柵欄顯示"])
        sleep(2)
        let cell = app.descendants(matching: .any).matching(identifier: "collection.cell").firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 8), "柵欄模式沒有縮圖")
        attachScreenshot(app, name: "64a-collection-grid")
        tapByCoordinate(cell)
        XCTAssertTrue(app.descendants(matching: .any)["collection.pager.close"].waitForExistence(timeout: 8), "點縮圖沒有彈出視窗")
        sleep(2)
        attachScreenshot(app, name: "64b-collection-pager")
        tapByCoordinate(app.descendants(matching: .any)["collection.pager.close"])
        sleep(1)
        tapByCoordinate(optionsButton)
        sleep(1)
        tapByCoordinate(app.buttons["單張顯示"])
        sleep(2)

        // 清掉測試資料：備註（點項目進編輯刪除）與兩個標籤。
        tapByCoordinate(item)
        if app.buttons["note.delete"].waitForExistence(timeout: 8) {
            tapByCoordinate(app.buttons["note.delete"])
            sleep(2)
        }
        app.navigationBars.buttons.element(boundBy: 0).tap()
        openOrganize("tags", in: app)
        deleteTestTags(in: app)
    }

    /// 右上角篩選選單：過濾條件、媒體類型、顯示方式選項。
    func testFilterMenuLikeSystemPhotos() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(2)
        attachScreenshot(app, name: "70-filter-menu")
        for label in ["已編輯", "不在相簿中", "媒體類型", "顯示方式選項"] {
            XCTAssertTrue(app.buttons[label].waitForExistence(timeout: 5), "篩選選單沒有 \(label)")
        }
        tapByCoordinate(app.buttons["媒體類型"])
        sleep(1)
        attachScreenshot(app, name: "71-filter-media")
        XCTAssertTrue(app.buttons["影片"].exists, "媒體類型裡沒有影片")
    }

    /// 多選後點喜愛：留在選取模式、沒有跳出視窗；再點一次（都已是喜愛）就移出喜愛，不留測試痕跡。
    func testBatchFavoriteStaysInSelection() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        tapByCoordinate(app.buttons["photos.select"])
        sleep(1)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        XCTAssertGreaterThan(thumbs.count, 2, "格狀畫面照片不夠")
        tapByCoordinate(thumbs.element(boundBy: 1))
        tapByCoordinate(thumbs.element(boundBy: 2))
        sleep(1)
        let before = app.buttons["batch.favorite"].label
        tapByCoordinate(app.buttons["batch.favorite"])
        sleep(4)
        attachScreenshot(app, name: "72-after-batch-favorite")
        XCTAssertTrue(app.buttons["batch.favorite"].exists, "點喜愛之後跳出了選取模式")
        XCTAssertTrue(app.buttons["photos.select"].exists, "點喜愛之後工具列不見了")
        XCTAssertNotEqual(app.buttons["batch.favorite"].label, before, "都已加入喜愛後，按鈕沒有變成移出喜愛")
        // 還原：再點一次，全部移出喜愛。
        tapByCoordinate(app.buttons["batch.favorite"])
        sleep(4)
        XCTAssertEqual(app.buttons["batch.favorite"].label, before, "移出喜愛後按鈕沒有變回來")
        tapByCoordinate(app.buttons["photos.select"])
    }

    /// 日記頁：篩選右邊有 +，點了開日記編輯畫面。
    func testJournalAddButton() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(2)
        if app.buttons["journal.unlock"].waitForExistence(timeout: 3) {
            tapByCoordinate(app.buttons["journal.unlock"])
            let sponsor = firstButton(in: app, labels: ["訂閱（開發期間免費）", "Subscribe (free during development)"])
            if sponsor.waitForExistence(timeout: 4) {
                tapByCoordinate(sponsor)
                sleep(3)
            }
        }
        XCTAssertTrue(app.buttons["journal.add"].waitForExistence(timeout: 8), "日記頁沒有 +")
        attachScreenshot(app, name: "73-journal-toolbar")
        tapByCoordinate(app.buttons["journal.add"])
        sleep(2)
        attachScreenshot(app, name: "74-journal-new")
        XCTAssertTrue(app.buttons["journal.save"].waitForExistence(timeout: 8)
                      || app.textViews.firstMatch.waitForExistence(timeout: 2), "點 + 沒有開日記編輯")

        // 從 + 新增可以改日期。
        XCTAssertTrue(app.datePickers["journal.date"].exists || app.buttons["journal.date"].exists
                      || app.descendants(matching: .any)["journal.date"].exists, "新增日記沒有日期欄")

        // 今天沒有照片：按鈕是「加入照片」，點開是整個相簿的彈窗，可以挑不是當天的照片。
        let add = app.buttons["journal.addPhotos"]
        XCTAssertTrue(add.waitForExistence(timeout: 8), "沒有加入照片按鈕")
        XCTAssertTrue(add.label.contains("加入照片") && !add.label.contains("更多"), "今天沒照片，按鈕該是加入照片：\(add.label)")
        tapByCoordinate(add)
        sleep(3)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        guard let first = waitFirst(thumbs, timeout: 10) else { XCTFail("挑選彈窗沒有照片"); return }
        tapByCoordinate(first)
        sleep(1)
        attachScreenshot(app, name: "75-journal-photo-picker")
        // 挑選彈窗可以切時間軸、右上角可以篩選。
        XCTAssertTrue(app.buttons["journal.picker.filter"].exists, "挑選彈窗沒有篩選")
        let timelineButton = app.buttons["journal.picker.mode.timeline"]
        XCTAssertTrue(timelineButton.exists, "挑選彈窗頁尾沒有時間軸／全部切換")
        tapByCoordinate(timelineButton)
        sleep(3)
        attachScreenshot(app, name: "75a-journal-picker-timeline")
        tapByCoordinate(app.buttons["journal.picker.filter"])
        sleep(1)
        attachScreenshot(app, name: "75b-journal-picker-filter")
        XCTAssertTrue(app.buttons["喜好項目"].waitForExistence(timeout: 3), "篩選選單沒有喜好項目")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.6)).tap()
        sleep(1)
        tapByCoordinate(app.buttons["journal.picker.done"])
        sleep(2)
        attachScreenshot(app, name: "76-journal-after-pick")
        XCTAssertTrue(app.buttons["journal.addPhotos"].waitForExistence(timeout: 5), "挑完之後編輯畫面不見了")
        // 不儲存，不留下測試資料。
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
    }

    /// 多選不同天的照片寫日記：日期用最早那張，不再要求同一天。
    func testMultiSelectJournalUsesEarliestDay() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        tapByCoordinate(app.buttons["photos.select"])
        sleep(1)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        XCTAssertGreaterThan(thumbs.count, 6, "格狀畫面照片不夠")
        // 第一張是今天，往後幾張是更早的日期。
        tapByCoordinate(thumbs.element(boundBy: 0))
        tapByCoordinate(thumbs.element(boundBy: 5))
        sleep(1)
        XCTAssertTrue(app.buttons["batch.journal"].waitForExistence(timeout: 5), "選了不同天的照片，沒有寫日記")
        tapByCoordinate(app.buttons["batch.journal"])
        sleep(2)
        attachScreenshot(app, name: "77-multi-day-journal")
        XCTAssertTrue(app.buttons["journal.addPhotos"].waitForExistence(timeout: 8), "沒有開日記編輯")
        let title = app.navigationBars.staticTexts.firstMatch.label
        XCTAssertFalse(title.contains("2026"), "日期應該是最早那張，不是今天：\(title)")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
    }

    /// 顯示方式選項：全部、時間軸各自設定，年月日沒有。
    func testViewOptionsPerScale() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))

        func firstThumbWidth() -> CGFloat {
            waitFirst(thumbs, timeout: 10)?.frame.width ?? 0
        }
        func openViewOptions() -> Bool {
            tapByCoordinate(app.buttons["photos.filter"])
            sleep(1)
            let item = app.buttons["顯示方式選項"]
            guard item.waitForExistence(timeout: 3) else {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.6)).tap()
                return false
            }
            tapByCoordinate(item)
            sleep(1)
            return true
        }

        // 年：沒有顯示方式選項。
        tapByCoordinate(app.buttons["scale.year"])
        sleep(2)
        XCTAssertFalse(openViewOptions(), "年不該有顯示方式選項")
        sleep(1)

        // 全部的寬度先記下來。
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        let allBefore = firstThumbWidth()
        XCTAssertGreaterThan(allBefore, 0)

        // 時間軸放大一次。
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(3)
        let timelineBefore = firstThumbWidth()
        XCTAssertTrue(openViewOptions(), "時間軸沒有顯示方式選項")
        tapByCoordinate(app.buttons["放大"])
        sleep(3)
        attachScreenshot(app, name: "78-timeline-zoomed")
        XCTAssertGreaterThan(firstThumbWidth(), timelineBefore + 5, "時間軸放大後照片沒有變大")

        // 全部沒有被影響。
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        XCTAssertEqual(firstThumbWidth(), allBefore, accuracy: 2, "時間軸的設定不該影響全部")

        // 還原時間軸。
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(3)
        if openViewOptions() { tapByCoordinate(app.buttons["縮小"]) }
    }

    /// 備註欄要能貼上文字（使用者回報貼不上去）。
    func testNotePaste() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        guard let first = waitFirst(thumbs, timeout: 10) else { XCTFail("沒有照片"); return }
        XCTAssertTrue(longPressForMenu(first, expecting: ["寫備註", "Write note"], in: app), "長按沒有備註")
        tapByCoordinate(firstButton(in: app, labels: ["寫備註", "Write note"]))
        sleep(2)
        let field = app.textViews["note.text"].exists ? app.textViews["note.text"] : app.textFields["note.text"]
        XCTAssertTrue(field.waitForExistence(timeout: 8), "備註沒有輸入欄")

        UIPasteboard.general.string = "貼上的餐廳 營業時間 11:00"
        field.tap()
        field.press(forDuration: 1.2)
        sleep(1)
        attachScreenshot(app, name: "80-paste-menu")
        let paste = app.menuItems["貼上"].exists ? app.menuItems["貼上"] : app.menuItems["Paste"]
        XCTAssertTrue(paste.waitForExistence(timeout: 5), "長按輸入欄沒有貼上選項")
        paste.tap()
        sleep(1)
        // 系統可能問要不要允許貼上。
        let allow = firstButton(in: app, labels: ["允許貼上", "Allow Paste"])
        if allow.waitForExistence(timeout: 3) { allow.tap() }
        sleep(1)
        attachScreenshot(app, name: "81-after-paste")
        let value = (field.value as? String) ?? ""
        XCTAssertTrue(value.contains("貼上的餐廳"), "貼上之後欄位沒有文字：\(value)")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
    }

    /// 日記篩選選單有時間排序（由新到舊／由舊到新），切換後第一篇會換成另一端。
    func testJournalSortOrder() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(3)
        let cards = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "journal.entry."))
        guard cards.count >= 2 else { return }
        let firstBefore = cards.firstMatch.identifier
        tapByCoordinate(app.buttons["journal.filter"])
        sleep(1)
        attachScreenshot(app, name: "79-journal-sort-menu")
        let sort = app.buttons["按照時間排序"]
        XCTAssertTrue(sort.waitForExistence(timeout: 5), "日記篩選選單沒有按照時間排序")
        tapByCoordinate(sort)
        sleep(3)
        XCTAssertNotEqual(cards.firstMatch.identifier, firstBefore, "切成由舊到新後，第一篇沒有變")
        // 還原。
        tapByCoordinate(app.buttons["journal.filter"])
        sleep(1)
        tapByCoordinate(app.buttons["按照時間排序"])
        sleep(3)
        XCTAssertEqual(cards.firstMatch.identifier, firstBefore, "再點一次後，第一篇沒有變回來")
    }

    /// 圖標選擇器可以用中文搜尋：表情符號與圖標兩頁都試。
    func testIconPickerChineseSearch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        openOrganize("tags", in: app)
        tapByCoordinate(app.buttons["manage.tag.create"])
        sleep(2)
        tapByCoordinate(app.buttons["tag.icon"])
        sleep(2)
        let search = app.textFields["icon.search"]
        XCTAssertTrue(search.waitForExistence(timeout: 8), "沒有搜尋欄")
        search.tap()
        search.typeText("飛機")
        sleep(2)
        attachScreenshot(app, name: "82-emoji-zh-search")
        let items = app.buttons.matching(identifier: "icon.item")
        XCTAssertGreaterThan(items.count, 0, "表情符號用中文搜尋「飛機」沒有結果")
        tapByCoordinate(firstButton(in: app, labels: ["圖標", "Icons"]))
        sleep(2)
        XCTAssertGreaterThan(items.count, 0, "圖標用中文搜尋「飛機」沒有結果")
        attachScreenshot(app, name: "83-symbol-zh-search")
    }

    /// 點時間軸／全部的照片會彈出全螢幕檢視：日期時間標題、關閉、待刪除、六個功能。
    func testPhotoDetail() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))

        for scale in ["scale.all", "scale.timeline"] {
            tapByCoordinate(app.buttons[scale])
            sleep(3)
            guard let first = waitFirst(thumbs, timeout: 10) else { XCTFail("沒有照片"); return }
            tapByCoordinate(first)
            if !app.descendants(matching: .any)["detail.close"].waitForExistence(timeout: 8) { attachScreenshot(app, name: "84z-no-detail-\(scale)") }
            XCTAssertTrue(app.descendants(matching: .any)["detail.close"].exists, "\(scale) 點照片沒有彈出檢視")
            sleep(2)
            attachScreenshot(app, name: "84-detail-\(scale)")
            for id in ["detail.trash", "detail.journal", "detail.note", "detail.tags", "detail.album", "detail.favorite", "detail.delete"] {
                XCTAssertTrue(app.descendants(matching: .any)[id].exists, "檢視少了 \(id)")
            }
            XCTAssertTrue(app.staticTexts["detail.title"].exists, "檢視沒有日期時間標題")
            if scale == "scale.all" {
                // 日記與備註都是開編輯畫面。
                tapByCoordinate(app.descendants(matching: .any)["detail.note"])
                XCTAssertTrue(app.buttons["note.save"].waitForExistence(timeout: 8), "備註沒有打開")
                tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
                sleep(1)
                tapByCoordinate(app.descendants(matching: .any)["detail.journal"])
                XCTAssertTrue(app.buttons["journal.save"].waitForExistence(timeout: 8), "日記沒有打開")
                tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
                sleep(1)
            }
            tapByCoordinate(app.descendants(matching: .any)["detail.close"])
            sleep(2)
        }
    }

    /// 日記裡點一張照片：同樣的全螢幕檢視，功能列沒有日記。
    func testJournalPhotoOpensDetail() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(3)
        let photo = app.descendants(matching: .any).matching(identifier: "journal.photo.0").firstMatch
        XCTAssertTrue(photo.waitForExistence(timeout: 10), "日記裡沒有照片")
        tapByCoordinate(photo)
        XCTAssertTrue(app.descendants(matching: .any)["detail.close"].waitForExistence(timeout: 8), "點日記照片沒有彈出檢視")
        sleep(2)
        attachScreenshot(app, name: "85-journal-photo-detail")
        XCTAssertFalse(app.descendants(matching: .any)["detail.journal"].exists, "從日記進來不該有日記")
        for id in ["detail.note", "detail.tags", "detail.album", "detail.favorite", "detail.delete"] {
            XCTAssertTrue(app.descendants(matching: .any)[id].exists, "檢視少了 \(id)")
        }
        tapByCoordinate(app.descendants(matching: .any)["detail.close"])
    }

    /// 英文介面下的功能列（文字比中文長很多），給小螢幕確認會不會擠爆。
    func testEnglishBars() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        // 多選底列
        tapByCoordinate(app.buttons["photos.select"])
        sleep(1)
        tapByCoordinate(thumbs.element(boundBy: 1))
        sleep(1)
        attachScreenshot(app, name: "90-en-selection")
        tapByCoordinate(app.buttons["photos.select"])
        sleep(1)
        // 單張檢視
        tapByCoordinate(thumbs.element(boundBy: 1))
        sleep(2)
        attachScreenshot(app, name: "91-en-detail")
    }

    /// 兩指張開放大、捏合縮小：全部與時間軸的格狀畫面。
    func testPinchZoomGrid() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))

        for scale in ["scale.all", "scale.timeline"] {
            if !app.buttons[scale].waitForExistence(timeout: 15) { attachScreenshot(app, name: "86-pinch-missing-\(scale)") }
            XCTAssertTrue(app.buttons[scale].exists, "找不到 \(scale)")
            tapByCoordinate(app.buttons[scale])
            sleep(3)
            guard let first = waitFirst(thumbs, timeout: 10) else { XCTFail("沒有照片"); return }
            // 設定會記住，先縮小幾次回到中間，才不會一開始就在最大或最小。
            waitFirst(thumbs, timeout: 5)?.pinch(withScale: 0.4, velocity: -3)
            sleep(2)
            attachScreenshot(app, name: "86-after-pinch-out-\(scale)")
            let before = waitFirst(thumbs, timeout: 5)?.frame.width ?? 0
            waitFirst(thumbs, timeout: 5)?.pinch(withScale: 2.5, velocity: 3)
            sleep(2)
            attachScreenshot(app, name: "87-after-pinch-in-\(scale)")
            let bigger = waitFirst(thumbs, timeout: 5)?.frame.width ?? 0
            XCTAssertGreaterThan(bigger, before + 5, "\(scale) 兩指張開後照片沒有變大")
            waitFirst(thumbs, timeout: 5)?.pinch(withScale: 0.4, velocity: -3)
            sleep(2)
            let restored = waitFirst(thumbs, timeout: 5)?.frame.width ?? 0
            XCTAssertLessThan(restored, bigger - 5, "\(scale) 捏合後照片沒有變小")
        }
    }

    /// 日記裡照片的兩指縮放：張開後每張變大，捏合後變小。
    func testPinchZoomJournal() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(3)
        let photo = { app.descendants(matching: .any).matching(identifier: "journal.photo.0").firstMatch }
        XCTAssertTrue(photo().waitForExistence(timeout: 10), "日記裡沒有照片")

        // 設定會記住，先捏合縮小，才不會一開始就在最大或最小。
        photo().pinch(withScale: 0.4, velocity: -3)
        sleep(2)
        let before = photo().frame.width
        photo().pinch(withScale: 2.5, velocity: 3)
        sleep(2)
        attachScreenshot(app, name: "88-journal-pinch-in")
        let bigger = photo().frame.width
        XCTAssertGreaterThan(bigger, before + 5, "日記兩指張開後照片沒有變大")
        photo().pinch(withScale: 0.4, velocity: -3)
        sleep(2)
        XCTAssertLessThan(photo().frame.width, bigger - 5, "日記捏合後照片沒有變小")
    }

    /// 單張檢視刪除後出現「復原」，按了照片回來、待刪除數字跟著回去。
    func testDetailDeleteUndo() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        guard let first = waitFirst(thumbs, timeout: 10) else { XCTFail("沒有照片"); return }
        tapByCoordinate(first)
        let any = { (id: String) in app.descendants(matching: .any)[id] }
        XCTAssertTrue(any("detail.delete").waitForExistence(timeout: 8), "沒有檢視")
        let titleBefore = any("detail.title").label
        tapByCoordinate(any("detail.delete"))
        XCTAssertTrue(any("detail.undo").waitForExistence(timeout: 5), "刪除後沒有復原")
        attachScreenshot(app, name: "89-detail-undo")
        XCTAssertNotEqual(any("detail.title").label, titleBefore, "刪除後沒有換到下一張")
        tapByCoordinate(any("detail.undo"))
        sleep(2)
        XCTAssertFalse(any("detail.undo").exists, "復原後提示還在")
        XCTAssertEqual(any("detail.title").label, titleBefore, "復原後沒有回到原本那張")
        tapByCoordinate(any("detail.close"))
    }

    /// 系統把文字調很大時，App 也跟著變大（永遠比系統小兩級），畫面沒有爆掉。
    func testLargeSystemText() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXL"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        attachScreenshot(app, name: "92-large-text-photos")
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(3)
        attachScreenshot(app, name: "93-large-text-organize")
    }

    /// 年、月、日三個子分頁的版面截圖（檢查左右邊距與標題對齊）。
    func testYearMonthDayLayoutShots() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        for scale in ["year", "month", "day"] {
            tapByCoordinate(app.buttons["scale.\(scale)"])
            sleep(3)
            attachScreenshot(app, name: "94-\(scale)")
        }
    }

    /// 回到主畫面截圖，看 App 圖示實際的樣子（淺色／深色各跑一次）。
    func testHomeScreenIconShot() throws {
        let app = XCUIApplication()
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCUIDevice.shared.press(.home)
        sleep(2)
        // 圖示可能在主畫面的後面幾頁，往左滑到看得到 PicDeck 為止。
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for _ in 0..<4 where !springboard.icons["PicDeck"].exists {
            springboard.swipeLeft()
            sleep(1)
        }
        attachScreenshot(app, name: "95-home-screen")
    }

    /// 付費頁：開發期間只有每月訂閱（NT$0），買斷與試用先隱藏；訂閱後解鎖。
    func testPaywallMonthlyOnly() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos", "-resetUnlock"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        tapByCoordinate(app.buttons["photos.title"])
        sleep(1)
        let tagItem = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "堯")).firstMatch
        if tagItem.waitForExistence(timeout: 4) { tapByCoordinate(tagItem) }
        let buy = app.descendants(matching: .any)["paywall.buy"]
        XCTAssertTrue(buy.waitForExistence(timeout: 8), "沒有出現付費頁")
        XCTAssertTrue(app.descendants(matching: .any)["paywall.plan.monthly"].exists, "沒有每月訂閱")
        XCTAssertFalse(app.descendants(matching: .any)["paywall.plan.lifetime"].exists, "買斷應該先隱藏")
        XCTAssertFalse(app.descendants(matching: .any)["paywall.trial"].exists, "免費試用應該先隱藏")
        attachScreenshot(app, name: "96-paywall")
        tapByCoordinate(buy)
        sleep(2)
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@ OR label CONTAINS %@", "訂閱制", "Monthly subscription")).firstMatch.exists, "訂閱後沒有解鎖")
    }

    /// 把 App 設成已訂閱。改過付費狀態的測試之後跑一次，還原使用者的模擬器。
    func testRestoreSubscribedState() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-subscribeForTesting", "-resetHomeSections"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30), "沒有分頁列")
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(2)
        XCTAssertTrue(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@ OR label CONTAINS %@", "訂閱制", "Monthly subscription")).firstMatch.exists, "沒有變成已訂閱")
    }

    /// 日記空狀態：提示文字，新增在右上角的＋。沒有日記時才看得到，有的話略過。
    func testJournalEmptyState() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(3)
        XCTAssertTrue(app.buttons["journal.add"].waitForExistence(timeout: 8), "右上角沒有＋")
        // 篩選到沒有日記的標籤才會出現空狀態。
        tapByCoordinate(app.buttons["journal.filter"])
        sleep(1)
        let tag = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "想去")).firstMatch
        guard tag.waitForExistence(timeout: 3) else { app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.6)).tap(); return }
        tapByCoordinate(tag)
        sleep(2)
        attachScreenshot(app, name: "98-journal-empty")
    }

    /// 免費版日記每天新增 1 則：第一則可以存，第二次按＋跳出付費頁。測完刪掉自己寫的那則。
    func testFreeJournalOnePerDay() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos", "-resetUnlock"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(3)
        let any = { (id: String) in app.descendants(matching: .any)[id] }
        XCTAssertFalse(any("journal.unlock").exists, "免費版日記不該整頁被鎖")

        tapByCoordinate(any("journal.add"))
        let text = app.textViews["journal.text"].exists ? app.textViews["journal.text"] : app.textFields["journal.text"]
        XCTAssertTrue(text.waitForExistence(timeout: 8), "沒有開日記編輯")
        text.tap()
        text.typeText("免費日記測試")
        tapByCoordinate(any("journal.save"))
        sleep(2)

        // 第二次新增：免費額度用完，直接跳出付費頁。
        tapByCoordinate(any("journal.add"))
        XCTAssertTrue(any("paywall.buy").waitForExistence(timeout: 8), "第二則沒有被擋下並顯示付費頁")
        attachScreenshot(app, name: "99-journal-limit")
        tapByCoordinate(firstButton(in: app, labels: ["關閉", "Close"]))
        sleep(1)

        // 刪掉剛寫的那則。
        let edit = any("journal.edit").firstMatch
        if edit.waitForExistence(timeout: 3) {
            tapByCoordinate(edit)
            tapByCoordinate(firstButton(in: app, labels: ["刪除", "Delete"]))
            sleep(1)
            let confirm = app.buttons["刪除日記"]
            if confirm.waitForExistence(timeout: 3) { tapByCoordinate(confirm) }
        }
    }

    /// 免費版只能有 1 個日子標籤：已經有一個時，新標籤打開「日子」會被擋下並提示訂閱。
    func testFreeOneAnniversaryTag() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos", "-resetUnlock", "-seedAnniversaryTag"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30), "照片分頁沒有載入")
        openOrganize("tags", in: app)
        tapByCoordinate(app.buttons["manage.tag.create"])
        let toggle = app.switches["tag.anniversary.toggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 8), "新標籤沒有日子開關")
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
        sleep(1)
        attachScreenshot(app, name: "100-anniversary-limit")
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "已經有日子標籤，第二個沒有被擋下")
        XCTAssertTrue(alert.buttons["解鎖 PicDeck"].exists || alert.buttons["Unlock PicDeck"].exists, "提示沒有解鎖鈕")
        alert.buttons.matching(NSPredicate(format: "label == %@ OR label == %@", "取消", "Cancel")).firstMatch.tap()
        XCTAssertEqual(app.switches["tag.anniversary.toggle"].value as? String, "0", "被擋下後日子開關應該保持關閉")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
    }

    /// 桌面小工具的連結（picdeck://tag/…）：訂閱者直接到「照片 → 時間軸」並套用標籤；
    /// 免費版只跳付費頁，關掉之後看不到那個標籤的內容。
    func testWidgetLink() throws {
        for subscribed in [true, false] {
            let app = XCUIApplication()
            app.launchArguments += [subscribed ? "-subscribeForTesting" : "-resetUnlock", "-seedAnniversaryTag"]
            app.launch()
            grantPhotoAccessIfNeeded(app)
            XCTAssertTrue(app.tabBars.buttons.element(boundBy: 0).waitForExistence(timeout: 30))
            // 從標籤管理抓「堯」的 id 太麻煩，直接用標題選單確認結果；連結用假 id 會沒反應，所以先取得真的 id。
            guard let id = tagID(named: "堯") else { XCTFail("找不到堯的 id"); return }
            let link = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            app.terminate()
            XCUIDevice.shared.system.open(URL(string: "picdeck://tag/\(id)")!)
            let open = link.buttons["打開"]
            if open.waitForExistence(timeout: 6) { open.tap() }
            sleep(4)
            attachScreenshot(app, name: subscribed ? "110-widget-link-subscribed" : "110-widget-link-free")
            if subscribed {
                XCTAssertTrue(app.buttons["scale.timeline"].waitForExistence(timeout: 10), "沒有到照片分頁")
                XCTAssertTrue(app.buttons["photos.title"].label.contains("堯"), "標題沒有套用標籤：\(app.buttons["photos.title"].label)")
            } else {
                XCTAssertTrue(app.descendants(matching: .any)["paywall.buy"].waitForExistence(timeout: 8), "免費版沒有跳付費頁")
                tapByCoordinate(firstButton(in: app, labels: ["關閉", "Close"]))
                sleep(2)
                XCTAssertFalse(app.buttons["photos.title"].label.contains("堯"), "關掉付費頁之後不該看到標籤的內容")
            }
            app.terminate()
        }
    }

    private func tagID(named name: String) -> String? {
        let fm = FileManager.default
        // UI 測試跑在另一個程序，讀不到 App 的資料夾；這裡靠模擬器共用路徑找 tags.json。
        let root = NSHomeDirectory().components(separatedBy: "/Containers/").first.map { $0 + "/Containers/Data/Application" }
        guard let root, let dirs = try? fm.contentsOfDirectory(atPath: root) else { return nil }
        for dir in dirs {
            let path = "\(root)/\(dir)/Documents/tags.json"
            guard let data = fm.contents(atPath: path),
                  let json = try? JSONSerialization.jsonObject(with: data) else { continue }
            let tags = (json as? [String: Any])?["tags"] as? [[String: Any]] ?? (json as? [[String: Any]]) ?? []
            if let match = tags.first(where: { ($0["name"] as? String) == name }) { return match["id"] as? String }
        }
        return nil
    }

    /// 選集內直接編輯標籤：進編輯模式點日子卡片、或長按卡片選「編輯標籤」，都會開標籤表單。
    func testEditTagsInCollections() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30))
        app.tabBars.buttons.element(boundBy: 1).tap()
        let any = { (id: String) in app.descendants(matching: .any)[id] }
        let card = app.descendants(matching: .any).matching(identifier: "home.anniversary").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 20), "沒有日子卡片")

        // 編輯模式：點卡片開標籤表單。
        tapByCoordinate(any("home.cardSettings"))
        tapByCoordinate(any("home.editTags"))
        sleep(1)
        attachScreenshot(app, name: "140-edit-mode")
        tapByCoordinate(card)
        XCTAssertTrue(app.textFields["tag.name"].waitForExistence(timeout: 8), "編輯模式點卡片沒有開標籤表單")
        attachScreenshot(app, name: "141-edit-form")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
        sleep(1)
        // 關掉編輯模式。
        tapByCoordinate(any("home.cardSettings"))
        tapByCoordinate(any("home.editTags"))
        sleep(1)

        // 長按：直接選「編輯標籤」。
        card.press(forDuration: 1.2)
        let edit = app.buttons["編輯標籤"].exists ? app.buttons["編輯標籤"] : app.buttons["Edit tag"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "長按卡片沒有編輯標籤")
        edit.tap()
        XCTAssertTrue(app.textFields["tag.name"].waitForExistence(timeout: 8), "長按編輯沒有開標籤表單")
        tapByCoordinate(firstButton(in: app, labels: ["取消", "Cancel"]))
    }

    /// 卡片樣式：文字位置與樣式（大小在每個區塊裡設定）；測完還原成預設。
    func testCardSettings() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag", "-resetHomeSections"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30))
        app.tabBars.buttons.element(boundBy: 1).tap()
        let any = { (id: String) in app.descendants(matching: .any)[id] }
        let card = app.descendants(matching: .any).matching(identifier: "home.anniversary").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 20), "選集沒有日子卡片")
        attachScreenshot(app, name: "120-cards-default")

        tapByCoordinate(any("home.cardSettings"))
        tapByCoordinate(any("home.cardStyle"))
        XCTAssertTrue(any("cards.position").waitForExistence(timeout: 8), "沒有卡片樣式設定")
        attachScreenshot(app, name: "121-card-settings")
        app.segmentedControls["cards.position"].buttons.element(boundBy: 0).tap()   // 上
        tapByCoordinate(any("cards.style.plate"))
        tapByCoordinate(any("cards.done"))
        sleep(2)
        attachScreenshot(app, name: "123-cards-top-plate")

        // 還原。
        tapByCoordinate(any("home.cardSettings"))
        tapByCoordinate(any("home.cardStyle"))
        XCTAssertTrue(any("cards.position").waitForExistence(timeout: 8))
        app.segmentedControls["cards.position"].buttons.element(boundBy: 2).tap()
        tapByCoordinate(any("cards.style.shadow"))
        tapByCoordinate(any("cards.done"))
    }

    /// 區塊：建立月曆區塊、取標題、加標籤，選集出現月曆與標題；再刪掉還原。
    func testCalendarBlock() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag", "-resetHomeSections"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30))
        app.tabBars.buttons.element(boundBy: 1).tap()
        let any = { (id: String) in app.descendants(matching: .any)[id] }
        XCTAssertTrue(any("home.cardSettings").waitForExistence(timeout: 20))
        tapByCoordinate(any("home.cardSettings"))
        tapByCoordinate(any("home.arrange"))
        tapByCoordinate(any("arrange.new"))
        XCTAssertTrue(any("add.mode.monthCalendar").waitForExistence(timeout: 8), "沒有選種類的彈窗")
        attachScreenshot(app, name: "150-add-block")
        tapByCoordinate(any("add.mode.monthCalendar"))

        // 直接進到區塊設定：取標題、加標籤。
        let title = app.textFields["block.title"]
        XCTAssertTrue(title.waitForExistence(timeout: 8), "建立後沒有進到區塊設定")
        title.tap()
        title.typeText("測試月曆")
        tapByCoordinate(any("block.addTag"))
        let pick = app.buttons.matching(identifier: "add.tag").matching(NSPredicate(format: "label CONTAINS %@", "堯")).firstMatch
        XCTAssertTrue(pick.waitForExistence(timeout: 8), "選標籤畫面沒有堯（月曆區塊要能選到有日子的標籤）")
        attachScreenshot(app, name: "151-block-tag-picker")
        pick.tap()
        sleep(1)
        attachScreenshot(app, name: "152-block-editor")
        // 回排列清單，完成。
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        tapByCoordinate(any("arrange.done"))
        sleep(2)
        let period = app.descendants(matching: .any).matching(identifier: "home.period").firstMatch
        for _ in 0..<5 where !period.exists { app.swipeUp() }
        XCTAssertTrue(period.exists, "選集沒有出現月曆")
        XCTAssertTrue(app.staticTexts["測試月曆"].exists, "選集沒有顯示區塊標題")
        attachScreenshot(app, name: "153-home-calendar-block")
    }

    /// 標籤區塊：新增標籤、切換卡片／列表，取消釘選時標籤不會被刪掉；並確認建立瞬間沒有重複名稱提示。
    func testTagsBlockNewTagAndLayout() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag", "-resetHomeSections"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30))
        deleteTestTags(in: app)
        app.tabBars.buttons.element(boundBy: 1).tap()
        let any = { (id: String) in app.descendants(matching: .any)[id] }
        XCTAssertTrue(any("home.cardSettings").waitForExistence(timeout: 20))
        tapByCoordinate(any("home.cardSettings"))
        tapByCoordinate(any("home.arrange"))
        tapByCoordinate(any("arrange.new"))
        tapByCoordinate(any("add.mode.tags"))
        XCTAssertTrue(any("block.addTag").waitForExistence(timeout: 8), "沒有進到標籤區塊設定")
        tapByCoordinate(any("block.addTag"))
        tapByCoordinate(any("add.newTag"))
        let field = app.textFields["tag.name"]
        XCTAssertTrue(field.waitForExistence(timeout: 8), "沒有標籤表單")
        field.tap()
        field.typeText("測試卡片")
        sleep(1)
        tapByCoordinate(app.buttons["tag.save"])
        XCTAssertFalse(app.staticTexts["tag.duplicate"].exists, "建立瞬間閃出重複名稱提示")
        sleep(3)
        attachScreenshot(app, name: "160-tags-block")
        // 切成列表。
        XCTAssertTrue(app.segmentedControls["block.layout"].waitForExistence(timeout: 8), "沒有卡片／列表切換")
        app.segmentedControls["block.layout"].buttons.element(boundBy: 1).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(1)
        tapByCoordinate(any("arrange.done"))
        sleep(2)
        attachScreenshot(app, name: "161-home-tags-list")
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "home.collection").firstMatch.waitForExistence(timeout: 8), "選集沒有標籤列表")
        deleteTestTags(in: app)
    }

    /// 日子區塊的排法：橫向捲動與自動換行，各種大小；拍截圖檢查（最後還原）。
    func testBlockLayouts() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag", "-resetHomeSections"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30))
        app.tabBars.buttons.element(boundBy: 1).tap()
        let any = { (id: String) in app.descendants(matching: .any)[id] }
        XCTAssertTrue(any("home.cardSettings").waitForExistence(timeout: 20))
        sleep(2)
        attachScreenshot(app, name: "170-nowrap-small")

        func apply(wrap: Int, size: Int, name: String) {
            tapByCoordinate(any("home.cardSettings"))
            tapByCoordinate(any("home.arrange"))
            tapByCoordinate(app.descendants(matching: .any).matching(identifier: "arrange.edit").firstMatch)
            XCTAssertTrue(app.segmentedControls["block.wrap"].waitForExistence(timeout: 8), "沒有排列方式")
            app.segmentedControls["block.wrap"].buttons.element(boundBy: wrap).tap()
            app.segmentedControls["block.size"].buttons.element(boundBy: size).tap()
            sleep(1)
            if name == "171-nowrap-large" { attachScreenshot(app, name: "170b-block-editor") }
            app.navigationBars.buttons.element(boundBy: 0).tap()
            sleep(1)
            tapByCoordinate(any("arrange.done"))
            sleep(2)
            attachScreenshot(app, name: name)
        }
        apply(wrap: 0, size: 2, name: "171-nowrap-large")
        apply(wrap: 1, size: 0, name: "172-wrap-small")
        apply(wrap: 1, size: 1, name: "173-wrap-medium")
        apply(wrap: 1, size: 2, name: "174-wrap-large")
        apply(wrap: 0, size: 0, name: "175-restored")
    }

    /// 整理審核：頁首選單可以切換其他未整理集合（0 張的不列）；待刪數字兩位數不會被截掉；影片可以播放。
    func testReviewSourceSwitchAndVideo() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-subscribeForTesting", "-fakeTrash", "21"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 0).waitForExistence(timeout: 30))
        openOrganize("photos", in: app)
        let allRow = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "所有未整理")).firstMatch
        XCTAssertTrue(allRow.waitForExistence(timeout: 15), "整理沒有所有未整理")
        tapByCoordinate(allRow)
        let source = app.descendants(matching: .any)["session.source"]
        XCTAssertTrue(source.waitForExistence(timeout: 15), "審核頁首沒有來源選單")
        sleep(2)
        attachScreenshot(app, name: "180-review-header")
        // 待刪數字 21 完整顯示（截圖看；這裡確認徽章存在）。
        XCTAssertTrue(app.descendants(matching: .any)["session.trash.count"].exists, "沒有待刪數字")
        tapByCoordinate(source)
        sleep(1)
        attachScreenshot(app, name: "181-source-menu")
        // 選影片：切過去，畫面出現影片播放器。
        let video = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "未整理影片")).firstMatch
        XCTAssertTrue(video.waitForExistence(timeout: 4), "選單沒有未整理影片（測試影片沒加進去？）")
        video.tap()
        sleep(3)
        let player = app.descendants(matching: .any)["video.player"]
        XCTAssertTrue(player.waitForExistence(timeout: 10), "影片沒有播放器")
        attachScreenshot(app, name: "182-video-before")
        player.tap()
        sleep(2)
        attachScreenshot(app, name: "183-video-playing")
        // 再打開選單，0 張的集合不該出現。
        tapByCoordinate(source)
        sleep(1)
        attachScreenshot(app, name: "184-source-menu-video")
    }

    /// 篩選鈕：套用篩選出現紅點，快速點兩下恢復預設。
    func testFilterDotAndDoubleTapReset() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos", "-subscribeForTesting"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["photos.filter"].waitForExistence(timeout: 30))
        attachScreenshot(app, name: "190-filter-default")
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(1)
        tapByCoordinate(app.buttons["媒體類型"])
        sleep(1)
        tapByCoordinate(app.buttons["影片"])
        sleep(2)
        attachScreenshot(app, name: "191-filter-video")
        // 選單最上面的「恢復預設篩選」。
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(1)
        tapByCoordinate(app.descendants(matching: .any)["filter.reset"])
        sleep(2)
        attachScreenshot(app, name: "192-filter-reset")
    }

    /// 選集：字級與月曆標題（看截圖）。
    func testCollectionsVisuals() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag", "-resetHomeSections"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 1).waitForExistence(timeout: 30))
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)
        attachScreenshot(app, name: "195-collections")
    }

    /// 單張檢視往下滑就關閉。
    func testDetailSwipeDownCloses() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-startOnPhotos"]
        app.launch()
        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 30))
        tapByCoordinate(app.buttons["scale.all"])
        sleep(3)
        let thumbs = app.images.matching(NSPredicate(format: "identifier BEGINSWITH 'thumb.'"))
        guard let first = waitFirst(thumbs, timeout: 10) else { XCTFail("沒有照片"); return }
        tapByCoordinate(first)
        let close = app.descendants(matching: .any)["detail.close"]
        XCTAssertTrue(close.waitForExistence(timeout: 8), "沒有打開檢視")
        sleep(2)
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.35))
        start.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8)))
        sleep(2)
        XCTAssertFalse(close.exists, "往下滑之後檢視沒有關閉")
    }

    // MARK: - 工具

    private func grantPhotoAccessIfNeeded(_ app: XCUIApplication) {
        let allowButton = firstButton(in: app, labels: ["允許取用照片", "Allow Photo Access"])
        guard allowButton.waitForExistence(timeout: 6) else { return }
        allowButton.tap()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for label in ["允許完整取用", "Allow Full Access", "允許取用全部照片", "OK", "好"] {
            let button = springboard.buttons[label]
            if button.waitForExistence(timeout: 4) {
                button.tap()
                break
            }
        }
        sleep(3)
    }

    /// 等某個查詢出現第一個元素，逾時回傳 nil。
    private func waitFirst(_ query: XCUIElementQuery, timeout: TimeInterval = 20) -> XCUIElement? {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let element = query.firstMatch
            if element.exists { return element }
            usleep(400_000)
        }
        return nil
    }

    /// 長按叫出選單。選單沒出現就再長按一次，避開畫面還在載入時的落空。
    @discardableResult
    private func longPressForMenu(_ element: XCUIElement,
                                  expecting labels: [String],
                                  in app: XCUIApplication,
                                  attempts: Int = 3) -> Bool {
        for _ in 0..<attempts {
            guard element.waitForExistence(timeout: 10) else { continue }
            element.press(forDuration: 1.2)
            sleep(2)
            if firstButton(in: app, labels: labels).waitForExistence(timeout: 5) { return true }
            // 選單可能半開，點掉再試。
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05)).tap()
            sleep(1)
        }
        return false
    }

    /// 用座標點擊。XCUITest 的一般 tap 會先嘗試捲動到可見，
    /// 在忙碌的畫面上這個動作偶爾會失敗，座標點擊可以繞過。
    private func tapByCoordinate(_ element: XCUIElement, timeout: TimeInterval = 15) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "找不到元素：\(element)")
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    private func firstButton(in app: XCUIApplication, labels: [String]) -> XCUIElement {
        for label in labels {
            let button = app.buttons[label]
            if button.exists { return button }
        }
        return app.buttons[labels[0]]
    }

    /// 用整個螢幕截圖，這樣長按選單這類系統層級的浮層也拍得到。
    /// 同時寫一份到 /tmp/picdeck-shots，因為測試結果包收尾很慢，直接讀檔比較快。
    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let folder = URL(fileURLWithPath: "/tmp/picdeck-shots", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent("\(name).png"))
    }
}


private extension String {
    func appendToFile(_ path: String) throws {
        let url = URL(fileURLWithPath: path)
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(Data(self.utf8))
            try handle.close()
        } else {
            try write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
