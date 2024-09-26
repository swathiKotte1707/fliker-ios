//
//  FlickrSampleUITests.swift
//  FlickrSampleUITests
//
//  Created by Swathi Kotte 09/25/24.
//

import XCTest

final class FlickrSampleUITests: XCTestCase {
    var app: XCUIApplication!

      override func setUp() {
          super.setUp()
          app = XCUIApplication()
          app.launch()
      }

      override func tearDown() {
          app = nil
          super.tearDown()
      }

      func testSearchFunctionality() {
          // Assuming the SearchBar placeholder text is "Search some thing like fruits"
          let searchBarPlaceholder = "Search some thing like fruits"
          
          // Verify that the search bar exists
          let searchBar = app.searchFields[searchBarPlaceholder]
          XCTAssertTrue(searchBar.exists, "Search bar should exist.")

          // Tap the search bar and type a search term
          searchBar.tap()
          searchBar.typeText("fruits")

          // Assuming there is a search button that gets triggered when the return key is pressed
          searchBar.typeText("\n") // Simulate pressing the return key
    
          
          // Wait for the loading to finish (you may need to adjust the sleep time based on your loading time)
          sleep(3) // Replace with appropriate expectation handling in real tests
          
          // Verify that images are displayed in the grid
          let firstImage = app.images.element(boundBy: 0) // Assuming images are shown as XCUIElementTypeImage
          XCTAssertTrue(firstImage.exists, "At least one image should be displayed after search.")
          
          // Optionally, tap the first image and verify that the detail view appears
          firstImage.tap()
          
      }
}
