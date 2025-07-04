//
//  EventViewUITests.swift
//  IAKOA
//
//  Created by Adrien V on 03/07/2025.
//


import XCTest

final class EventViewUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testCitySearchFieldExists() {
        let searchField = app.textFields["citySearchField"]
        XCTAssertTrue(searchField.exists, "Le champ de recherche de ville doit exister")
    }

    func testClearSearchButtonWorks() {
        let searchField = app.textFields["citySearchField"]
        searchField.tap()
        searchField.typeText("Paris")

        let clearButton = app.buttons["clearSearchButton"]
        XCTAssertTrue(clearButton.exists, "Le bouton pour effacer la recherche doit exister")
        clearButton.tap()
        
        XCTAssertEqual(searchField.value as? String, "", "Le champ doit être vidé après avoir appuyé sur le bouton clear")
    }

    func testCurrentLocationButtonExistsAndTaps() {
        let locationButton = app.buttons["currentLocationButton"]
        XCTAssertTrue(locationButton.exists, "Le bouton pour la position actuelle doit exister")
        locationButton.tap()
    }

    func testFilterToggleButtonExists() {
        let filterButton = app.buttons["filterToggleButton"]
        XCTAssertTrue(filterButton.exists, "Le bouton filtre doit exister")
    }

    func testLoadingIndicatorAppears() {
        let loading = app.otherElements["loadingIndicator"]
        XCTAssertTrue(loading.waitForExistence(timeout: 5), "Le loader doit apparaître pendant le chargement")
    }

    func testNoEventsMessageAppears() {
        let message = app.staticTexts["noEventsText"]
        XCTAssertTrue(message.waitForExistence(timeout: 10), "Le message 'Aucun événement' doit s'afficher si aucun événement n'est trouvé")
    }
}
