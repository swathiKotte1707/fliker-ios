//
//  FlickrSampleTests.swift
//  FlickrSampleTests
//
//  Created by Swathi Kotte on 7/12/24.
//

import XCTest
import Combine
@testable import FlickrSample

final class FlickrSampleTests: XCTestCase {
    var viewModel: FlickrViewModel!
    var cancellables: Set<AnyCancellable>!
    var urlSession: URLSession!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        
        // Set up URLProtocol to intercept network requests
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        
        viewModel = FlickrViewModel(urlSession: urlSession)
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        MockURLProtocol.mockData = nil
        MockURLProtocol.error = nil
        super.tearDown()
    }
    
    func testFetchImagesSuccess() {
        let expectation = self.expectation(description: "Fetching images")
        let jsonResponse = """
            {
                "title": "Recent Uploads tagged hellcat",
                "link": "https://www.flickr.com/photos/tags/hellcat/",
                "description": "",
                "modified": "2024-07-09T21:44:08Z",
                "generator": "https://www.flickr.com",
                "items": [
                    {
                        "title": "Grumman Hellcat II KE209",
                        "link": "https://www.flickr.com/photos/100201028@N08/53845575152/",
                        "media": {"m":"https://live.staticflickr.com/65535/53845575152_b6f8b79aec_m.jpg"},
                        "date_taken": "2023-08-10T12:21:28-08:00",
                        "description": " <p><a href=\\"https://www.flickr.com/people/100201028@N08/\\">gbadger1</a> posted a photo:</p> <p><a href=\\"https://www.flickr.com/photos/100201028@N08/53845575152/\\" title=\\"Grumman Hellcat II KE209\\"><img src=\\"https://live.staticflickr.com/65535/53845575152_b6f8b79aec_m.jpg\\" width=\\"240\\" height=\\"160\\" alt=\\"Grumman Hellcat II KE209\\" /></a></p> ",
                        "published": "2024-07-09T21:44:08Z",
                        "author": "nobody@flickr.com (\\"gbadger1\\")",
                        "author_id": "100201028@N08",
                        "tags": "fleet air arm museum yeovilton somerset england uk united kingdom 2023 10 august grumman hellcat ii ke209"
                    }
                ]
            }
            """
        MockURLProtocol.mockData = jsonResponse.data(using: .utf8)
        
        viewModel.$items
            .sink(receiveValue: { items in
                if !items.isEmpty {
                    XCTAssertEqual(items.first?.title, "Grumman Hellcat II KE209")
                    XCTAssertEqual(items.first?.author, "nobody@flickr.com (\"gbadger1\")")
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)
        
        viewModel.fetchImages(for: "hellcat")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchImagesFailure() {
        let expectation = self.expectation(description: "Fetching images failure")
        MockURLProtocol.error = NSError(domain: "test", code: 1, userInfo: nil)
        
        viewModel.$items
            .sink(receiveValue: { items in
                XCTAssertTrue(items.isEmpty)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.fetchImages(for: "hellcat")
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}

class DateFormattingTests: XCTestCase {
    func testDateFormatting() {
        let dateString = "2024-07-09T21:44:08Z"
        let formattedDate = dateString.formattedDate()
        
        XCTAssertEqual(formattedDate, "Jul 9, 2024")
    }
}

