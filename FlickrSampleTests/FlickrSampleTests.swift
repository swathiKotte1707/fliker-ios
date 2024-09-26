//
//  FlickrSampleTests.swift
//  FlickrSampleTests
//
//  Created by Swathi Kotte 09/25/24.
//

import XCTest
import Combine
@testable import FlickrSample

class FlickrViewModelTests: XCTestCase {
    
    var viewModel: FlickrViewModel!
    var mockServiceManager: MockServiceManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockServiceManager = MockServiceManager()
        viewModel = FlickrViewModel(serviceDelegate: mockServiceManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockServiceManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchImagesSuccess() {
        // Given
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
                   """.data(using: .utf8)
        
        mockServiceManager.dataToReturn = jsonResponse // Provide mock data

        // When
        viewModel.fetchImages(for: "testTags")

        // Then
        let expectation = self.expectation(description: "Images fetched successfully")
        viewModel.$items
            .dropFirst() // Skip the initial empty array
            .sink { items in
                XCTAssertEqual(items.count, 1) // Check if the items count is as expected
                XCTAssertEqual(items[0].title, "Grumman Hellcat II KE209") // Check item title
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchImagesError() {
        // Given
        mockServiceManager.shouldReturnError = true // Indicate that an error should be returned

        // When
        viewModel.fetchImages(for: "testTags")

        // Then
        let expectation = self.expectation(description: "Fetch should fail")
        viewModel.$isLoading
            .dropFirst() // Skip initial value
            .sink { [self] isLoading in
                if !isLoading {
                    XCTAssertEqual(self.viewModel.items.count, 0)
                    XCTAssertFalse(isLoading)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testDateFormatting() {
        let dateString = "2024-07-09T00:00:00Z"
        let formattedDate = dateString.formattedDate()
        
        XCTAssertEqual(formattedDate, "9 Jul 2024")
    }
}

class MockServiceManager: ServiceManagerDelegate {

    var dataToReturn: Data?
    var shouldReturnError = false
    func getImagesFor(search text: String) -> AnyPublisher<Data, any Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        }
        
        guard let data = dataToReturn else {
            return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
        }
        
        return Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
