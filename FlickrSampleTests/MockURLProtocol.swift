//
//  MockURLProtocol.swift
//  FlickrSampleTests
//
//  Created by Swathi Kotte on 7/12/24.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var error: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        } else if let data = MockURLProtocol.mockData {
            self.client?.urlProtocol(self, didLoad: data)
        }
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
