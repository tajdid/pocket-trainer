import XCTest
final class PocketUITests: XCTestCase {
    func testCarouselAndDetails() {
        let app = XCUIApplication(); app.launch()
        let cartridge = app.descendants(matching: .any)["cartridge"]
        XCTAssertTrue(cartridge.waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["intro.start"].exists)
        XCTAssertEqual(cartridge.value as? String, "1 of 3")
        for index in 0..<3 {
            app.buttons["theme.\(index)"].tap()
            cartridge.tap()
            let title = app.staticTexts["details.title"]
            XCTAssertTrue(title.waitForExistence(timeout: 3))
            XCTAssertEqual(title.label, "Pokémon \(["Red", "Blue", "Yellow"][index])")
            XCTAssertEqual(app.descendants(matching: .any)["details.cartridge"].value as? String, "Inspection")
            let shot = XCTAttachment(screenshot: app.screenshot())
            shot.name = "Details-\(index)"; shot.lifetime = .keepAlways; add(shot)
            app.buttons["details.flip"].tap()
            app.descendants(matching: .any)["details.cartridge"].swipeLeft()
            XCTAssertEqual(title.label, "Pokémon \(["Red", "Blue", "Yellow"][index])")
            app.scrollViews["details.content"].swipeUp()
            let sprite = app.images["details.mascotSprite"]
            XCTAssertTrue(sprite.waitForExistence(timeout: 3))
            XCTAssertEqual(sprite.label, ["Charizard", "Blastoise", "Pikachu"][index] + " pixel sprite")
            let mascotShot = XCTAttachment(screenshot: app.screenshot())
            mascotShot.name = "Mascot-\(index)"; mascotShot.lifetime = .keepAlways; add(mascotShot)
            app.buttons["details.close"].tap()
            XCTAssertTrue(app.buttons["theme.\(index)"].waitForExistence(timeout: 3))
            XCTAssertEqual(cartridge.value as? String, "\(index + 1) of 3")
        }
        cartridge.swipeLeft()
        XCTAssertEqual(cartridge.value as? String, "3 of 3")
        cartridge.swipeRight()
        XCTAssertTrue(app.staticTexts["Pokémon Blue"].waitForExistence(timeout: 3))
        cartridge.tap()
        app.scrollViews["details.content"].swipeUp()
        let back = app.buttons["details.back"]
        XCTAssertTrue(back.waitForExistence(timeout: 3)); back.tap()
        XCTAssertEqual(cartridge.value as? String, "2 of 3")
        app.buttons["theme.0"].tap(); cartridge.swipeRight()
        XCTAssertEqual(cartridge.value as? String, "1 of 3")
        cartridge.tap()
        let header = app.staticTexts["CARTRIDGE NO. 001"]
        XCTAssertTrue(header.waitForExistence(timeout: 3))
        header.swipeDown()
        XCTAssertTrue(app.buttons["theme.0"].waitForExistence(timeout: 3))
        XCTAssertEqual(cartridge.value as? String, "1 of 3")
    }
}
