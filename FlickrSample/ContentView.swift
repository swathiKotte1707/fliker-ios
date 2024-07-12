//
//  ContentView.swift
//  FlickrSample
//
//  Created by Swathi Kotte on 7/12/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = FlickrViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: {
                    viewModel.fetchImages(for: searchText)
                })
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    GridView(items: viewModel.items)
                }
            }
            .navigationTitle("Flickr Search")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search", text: $text, onCommit: {
                onSearchButtonClicked()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.leading, 8)
            
            Button(action: {
                onSearchButtonClicked()
            }) {
                Text("Search")
            }
            .padding(.trailing, 8)
        }
        .padding()
    }
}

struct GridView: View {
    let items: [Item]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(items) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        AsyncImage(url: URL(string: item.media.m)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 100, height: 100)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
    }
}

struct DetailView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: item.media.m)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } placeholder: {
                Color.gray
            }
            
            Text(item.title)
                .font(.headline)
                .padding(.top)
            
            Text("By: \(item.author)")
                .font(.subheadline)
                .padding(.top, 2)
            
            Text(item.description)
                .font(.body)
                .padding(.top, 2)
            
            Text("Published: \(item.published.formattedDate())")
                .font(.footnote)
                .padding(.top, 2)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Image Detail")
    }
}
