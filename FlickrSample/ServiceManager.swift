//
//  ServiceManager.swift
//  FlickrSample
//
//  Created by Swathi Kotte on 26/09/24.
//

import Foundation
import Combine

protocol ServiceManagerDelegate {
    func getImagesFor(search text: String) -> AnyPublisher<Data, Error>
}

class ServiceManager: ServiceManagerDelegate {
    func getImagesFor(search text: String) -> AnyPublisher<Data, any Error> {
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(text)"
        
        guard let url = URL(string: urlString) else {
            // Return a failed publisher if the URL is invalid
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
}
