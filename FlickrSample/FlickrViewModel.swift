//
//  FlickrViewModel.swift
//  FlickrSample
//
//  Created by Swathi Kotte on 7/12/24.
//

import Foundation
import Combine

class FlickrViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let cache = NSCache<NSString, NSArray>()
    private var urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetchImages(for tags: String) {
        if let cachedItems = cache.object(forKey: tags as NSString) as? [Item] {
            self.items = cachedItems
            return
        }
        
        isLoading = true
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(tags)"
        
        guard let url = URL(string: urlString) else { return }
        
        let decoder = JSONDecoder()
        // decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full) // Not needed for strings
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Welcome.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching images: \(error)")
                case .finished:
                    break
                }
                self.isLoading = false
            }, receiveValue: { welcome in
                self.items = welcome.items
                self.cache.setObject(welcome.items as NSArray, forKey: tags as NSString)
            })
            .store(in: &cancellables)
    }
}



extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter.iso8601Full
        return formatter.date(from: self)
    }
    
    func formattedDate() -> String {
        guard let date = self.toDate() else { return self }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

