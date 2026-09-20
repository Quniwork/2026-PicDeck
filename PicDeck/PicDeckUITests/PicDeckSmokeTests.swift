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
        XCTAssertTrue(app.tabBars.buttons.element(boundBy: 0).exists, "切換後底部分頁列不見了")
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
            XCTAssertTrue(firstButton(in: app, labels: ["加到相冊", "Add to album"]).exists,
                          "長按選單沒有加到相冊")

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
            tapByCoordinate(app.buttons["scale.journal"])
            sleep(3)
            let sponsor = firstButton(in: app, labels: ["以 NT$99 贊助開發", "Sponsor for NT$99"])
            if sponsor.waitForExistence(timeout: 6) {
                attachScreenshot(app, name: "07f1-journal-paywall")
                tapByCoordinate(sponsor)
                sleep(2)
                tapByCoordinate(app.buttons["scale.journal"])
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
            XCTAssertTrue(longPressForMenu(firstPhoto, expecting: ["標籤", "Tags"], in: app),
                          "長按選單沒有標籤")
            let addTags = firstButton(in: app, labels: ["標籤", "Tags"])
            if true {
                tapByCoordinate(addTags)
                sleep(2)
                attachScreenshot(app, name: "07a-tag-picker")

                let nameField = app.textFields.firstMatch
                XCTAssertTrue(nameField.waitForExistence(timeout: 5), "標籤輸入欄沒有出現")
                nameField.tap()
                nameField.typeText("旅行")
                tapByCoordinate(firstButton(in: app, labels: ["新增", "Add"]))
                sleep(2)
                attachScreenshot(app, name: "07b-tag-created")
                tapByCoordinate(firstButton(in: app, labels: ["完成", "Done"]))
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
        XCTAssertTrue(app.buttons["batch.album"].exists, "多選沒有加入相冊")
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

        // 資料夾分頁。
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        attachScreenshot(app, name: "08-albums")

        // 整理分頁。
        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(4)
        attachScreenshot(app, name: "09-organize-list")

        // 免費可用的月份列，點進去開始審核。
        let monthRow = app.cells.element(boundBy: 3)
        guard monthRow.waitForExistence(timeout: 10) else {
            XCTFail("整理分頁沒有月份列")
            return
        }
        monthRow.tap()
        sleep(4)

        let keepButton = app.buttons["session.keep"]
        XCTAssertTrue(keepButton.waitForExistence(timeout: 15), "審核畫面沒有載入")
        attachScreenshot(app, name: "10-review")

        // 保留：標記成已整理。
        tapByCoordinate(keepButton)
        sleep(1)
        attachScreenshot(app, name: "11-after-keep")

        // 右滑回上一張，畫面必須留在審核頁。
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.45, dy: 0.42))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.42))
        start.press(forDuration: 0.05, thenDragTo: end)
        sleep(1)
        XCTAssertTrue(app.buttons["session.keep"].exists, "右滑把畫面退回上一層了")
        attachScreenshot(app, name: "12-after-swipe-right")

        // 幫助說明。
        tapByCoordinate(app.buttons["session.help"])
        sleep(2)
        attachScreenshot(app, name: "13-help")
        tapByCoordinate(app.buttons["help.close"])
        sleep(2)

        // 刪除一張後開待刪清單。
        let deleteButton = app.buttons["session.delete"]
        if deleteButton.exists {
            tapByCoordinate(deleteButton)
            sleep(1)
        }

        tapByCoordinate(app.buttons["session.trash"])
        sleep(2)
        attachScreenshot(app, name: "14-trash")
    }

    /// 只檢查標籤名稱不可重複這件事，不碰其他畫面。
    func testDuplicateTagNameIsRejected() throws {
        let app = XCUIApplication()
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
        XCTAssertTrue(longPressForMenu(firstPhoto, expecting: ["標籤", "Tags"], in: app),
                      "長按選單沒有標籤")
        tapByCoordinate(firstButton(in: app, labels: ["標籤", "Tags"]))
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
        tapByCoordinate(firstButton(in: app, labels: ["完成", "Done"]))
        sleep(1)
    }

    /// 只檢查紀念日標籤與重做後的日記排版，不跑其他流程。
    /// 啟動參數會先放一個 2020/8/5 起算、名叫「堯」的紀念日標籤。
    func testAnniversaryTagAndJournalLayout() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-seedAnniversaryTag"]
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
        let sponsor = firstButton(in: app, labels: ["以 NT$99 贊助開發", "Sponsor for NT$99"])
        if sponsor.waitForExistence(timeout: 4) {
            tapByCoordinate(sponsor)
            sleep(3)
            openTagFilter(in: app, named: "堯")
        }

        // 篩選到堯之後，每一天的標題下方要出現年月日。
        XCTAssertNotNil(waitFirst(chips), "篩選到紀念日標籤後沒有顯示年月日")
        let chipLabel = chips.firstMatch.label
        XCTAssertTrue(chipLabel.contains("堯"), "紀念日沒有顯示標籤名稱：\(chipLabel)")
        XCTAssertTrue(chipLabel.contains("天"), "紀念日沒有顯示天數：\(chipLabel)")
        attachScreenshot(app, name: "19-timeline-anniversary")

        // 日記分頁：重做後的卡片版面，而且要跟著篩選走。
        tapByCoordinate(app.buttons["scale.journal"])
        sleep(3)
        attachScreenshot(app, name: "20-journal-cards")

        let cards = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "journal.entry."))
        let filteredCount = cards.count
        if filteredCount == 0 {
            XCTAssertTrue(app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS %@", "沒有日記")).firstMatch.exists,
                          "篩選後沒有日記，卻沒有顯示空狀態")
        }

        // 取消篩選後，日記篇數只會變多或一樣，不可能變少。
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(2)
        tapByCoordinate(firstButton(in: app, labels: ["所有項目", "All Items"]))
        sleep(3)
        let totalCount = cards.count
        XCTAssertGreaterThanOrEqual(totalCount, filteredCount,
                                    "篩選後的日記篇數比全部還多")
        attachScreenshot(app, name: "20a-journal-unfiltered")

        // 再篩回堯，確認篇數回到篩選後的數量。
        openTagFilter(in: app, named: "堯")
        tapByCoordinate(app.buttons["scale.journal"])
        sleep(3)
        XCTAssertEqual(cards.count, filteredCount, "重新篩選後日記篇數對不上")

        // 換回所有項目，紀念日要跟著收起來。
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(2)
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(2)
        tapByCoordinate(firstButton(in: app, labels: ["所有項目", "All Items"]))
        sleep(3)
        XCTAssertEqual(chips.count, 0, "取消標籤篩選後仍然顯示紀念日")

        // 更多 → 標籤 → 堯，確認計算方式的五種換算。
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(2)
        tapByCoordinate(app.buttons["more.manage"])
        sleep(2)
        // 管理頁預設在相簿，切到標籤。
        tapByCoordinate(firstButton(in: app, labels: ["標籤", "Tags"]))
        sleep(2)
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
            XCTFail("組不出起算日")
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

    /// 按住把手拖到畫面高度的某個比例。
    private func dragScrubber(_ handle: XCUIElement,
                              in app: XCUIApplication,
                              to fraction: CGFloat) {
        let start = handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: fraction))
        start.press(forDuration: 0.4, thenDragTo: end)
        sleep(1)
    }

    /// 篩選選單 → 標籤那一層 → 指定的標籤。
    private func openTagFilter(in app: XCUIApplication, named name: String) {
        tapByCoordinate(app.buttons["photos.filter"])
        sleep(2)
        tapByCoordinate(firstButton(in: app, labels: ["標籤", "Tags"]))
        sleep(2)
        tapByCoordinate(menuButton(in: app, containing: name))
        sleep(3)
    }

    /// 選單裡標籤那列，名稱前面可能還有圖示，所以用包含比對。
    private func menuButton(in app: XCUIApplication, containing text: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
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
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")

        // 更多 → 管理相簿與標籤。
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(2)
        tapByCoordinate(app.buttons["more.manage"])
        sleep(2)
        attachScreenshot(app, name: "22-manage-albums")

        // 相簿：新增一個，確認出現在清單裡。
        let stamp = "\(Int(Date().timeIntervalSince1970) % 100000)"
        let albumName = "測試相簿\(stamp)"
        let albumField = app.textFields["album.name"]
        XCTAssertTrue(albumField.waitForExistence(timeout: 10), "沒有新增相簿的輸入欄")
        typeInto(albumField, albumName, in: app)
        sleep(1)
        XCTAssertTrue(app.buttons["album.add"].isEnabled, "輸入名稱後仍不能新增相簿")
        tapByCoordinate(app.buttons["album.add"])
        sleep(4)

        let albumRow = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", albumName))
        XCTAssertNotNil(waitFirst(albumRow, timeout: 15), "新增的相簿沒有出現")
        attachScreenshot(app, name: "23-manage-album-added")

        // 同名不能再新增一次。
        typeInto(albumField, albumName, in: app)
        sleep(1)
        XCTAssertFalse(app.buttons["album.add"].isEnabled, "同名相簿仍然可以新增")
        XCTAssertTrue(app.staticTexts["album.duplicate"].exists, "同名相簿沒有顯示提示")

        // 切到標籤頁。
        tapByCoordinate(firstButton(in: app, labels: ["標籤", "Tags"]))
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
        let iconTab = firstButton(in: app, labels: ["圖示", "Icons"])
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
        XCTAssertNotNil(waitFirst(tagRow, timeout: 10), "新增的標籤沒有出現")
        attachScreenshot(app, name: "27-manage-tag-added")

        // 點進去要看得到紀念日設定。
        guard let row = waitFirst(tagRow, timeout: 10) else {
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

    /// 只檢查右側的拖拉軸：把手在、拖動會捲動、拖動時顯示年份與日期區間。
    func testScrubber() throws {
        let app = XCUIApplication()
        app.launch()

        grantPhotoAccessIfNeeded(app)
        XCTAssertTrue(app.buttons["scale.all"].waitForExistence(timeout: 20), "首頁沒有載入")
        tapByCoordinate(app.buttons["scale.all"])
        sleep(4)

        let scrubber = app.descendants(matching: .any)
            .matching(identifier: "photos.scrubber").firstMatch
        XCTAssertTrue(scrubber.waitForExistence(timeout: 10), "全部沒有拖拉軸把手")
        attachScreenshot(app, name: "29-scrubber-idle")

        let years = app.descendants(matching: .any).matching(identifier: "scrubber.year")
        let pill = app.descendants(matching: .any)
            .matching(identifier: "scrubber.range").firstMatch

        // 拖到接近頂端。
        dragScrubber(scrubber, in: app, to: 0.16)
        XCTAssertGreaterThan(years.count, 0, "拖動時沒有顯示年份")
        XCTAssertTrue(pill.exists, "拖動時沒有顯示日期區間")
        let topRange = pill.label
        XCTAssertFalse(topRange.isEmpty, "日期區間是空的")
        attachScreenshot(app, name: "30-scrubber-dragging")

        // 拖到接近底部，區間要跟著換成比較早的日期。
        sleep(2)
        dragScrubber(scrubber, in: app, to: 0.86)
        let bottomRange = pill.label
        XCTAssertFalse(bottomRange.isEmpty, "拖到底部沒有日期區間")
        XCTAssertNotEqual(bottomRange, topRange, "拖到不同位置，日期區間卻一樣")
        attachScreenshot(app, name: "31-scrubber-bottom")

        // 時間軸也要有。
        tapByCoordinate(app.buttons["scale.timeline"])
        sleep(4)
        XCTAssertTrue(app.descendants(matching: .any)
            .matching(identifier: "photos.scrubber").firstMatch.waitForExistence(timeout: 10),
                      "時間軸沒有拖拉軸把手")
        attachScreenshot(app, name: "32-scrubber-timeline")
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
    private func attachScreenshot(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
