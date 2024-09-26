//
//  FlickrViewModel.swift
//  FlickrSample
//
//  Created by Swathi Kotte 09/25/24.
//

import Foundation
import Combine

class FlickrViewModel: ObservableObject {
   
    
    @Published var items: [Item] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let cache = NSCache<NSString, NSArray>()
    var serviceDelegate: ServiceManagerDelegate
    
    init(serviceDelegate: ServiceManagerDelegate) {
        self.serviceDelegate = serviceDelegate
    }
    
    func fetchImages(for tags: String) {
        isLoading = true
        if let cachedItems = cache.object(forKey: tags as NSString) as? [Item] {
            self.items = cachedItems
            return
        }
        let decoder = JSONDecoder()
        serviceDelegate.getImagesFor(search: tags)
            .receive(on: DispatchQueue.main) // Ensure you're receiving the result on the main thread
            .decode(type: Welcome.self, decoder: decoder)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .finished:
                    print("Successfully received image data.")
                case .failure(let error):
                    print("Error fetching image: \(error)")
                }
               
            }, receiveValue: { data in
                self.items = data.items
               self.cache.setObject(data.items as NSArray, forKey: tags as NSString)
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
        formatter.dateFormat = "d MMM yyyy" // Ensure UTC time zone
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC time zone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

