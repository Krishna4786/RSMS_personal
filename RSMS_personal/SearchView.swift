import SwiftUI

// MARK: - Search View
struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            if searchText.isEmpty {
                ContentUnavailableView(
                    "Search Products",
                    systemImage: "magnifyingglass",
                    description: Text("Enter a product name or category to search")
                )
            } else {
                // TODO: Implement search results
                ContentUnavailableView.search(text: searchText)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Search products...")
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SearchView()
    }
}
