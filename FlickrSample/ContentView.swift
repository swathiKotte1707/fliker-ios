//
//  ContentView.swift
//  FlickrSample
//
//  Created by Swathi Kotte 09/25/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = FlickrViewModel(serviceDelegate: ServiceManager())
    @State private var searchText = ""
   
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Search for images...") {
                    viewModel.fetchImages(for: searchText)
                }.padding()
                VStack {
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                            .padding()
                    }
                    GridView(items: viewModel.items).opacity(viewModel.isLoading ? 0.1 : 1)
                }
            }
            .navigationTitle("Flickr Search")
        }
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onSearchButtonClicked: (() -> Void)?
    
    @FocusState private var isInputFocused: Bool
    
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        var onSearchButtonClicked: (() -> Void)?
        
        init(text: Binding<String>, onSearchButtonClicked: (() -> Void)?) {
            _text = text
            self.onSearchButtonClicked = onSearchButtonClicked
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            onSearchButtonClicked?()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, onSearchButtonClicked: onSearchButtonClicked)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func dismissKeyboard() {
        isInputFocused = false
    }
}
struct GridView: View {
    let items: [Item]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 10) {
                ForEach(items) { item in
                    NavigationLink(destination: DetailView(item: item)) {
                        AsyncImage(url: URL(string: item.media.m)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 110, height: 110)
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
    @State private var scaleEffect = 0.5
    @State private var opacity = 0.0
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: item.media.m)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } placeholder: {
                Color.gray
            }
            
            Text("Title: \(item.title)")
                .font(.headline)
                .padding(.top)
            
            Text("Author By: \(item.author)")
                .font(.headline)
                .padding(.top, 2)
            
            Text("Description: \(item.description)")
                .font(.headline)
                .padding(.top, 2)
            
            Text("Published: \(item.published.formattedDate())")
                .font(.headline)
                .padding(.top, 2)
            Spacer()
        }
        .padding()
        .scaleEffect(scaleEffect)
               .opacity(opacity)
               .onAppear {
                   withAnimation(.easeInOut(duration: 0.5)) {
                       scaleEffect = 1.0
                       opacity = 1.0
                   }
               }
               .onDisappear {
                   scaleEffect = 0.5
                   opacity = 0.0
               }
               
        .navigationTitle("Image Detail")
    }
}
