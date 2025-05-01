import SwiftUI

struct ClientsHeaders: View {
    @Binding var isAscending: Bool
    @Binding var sortingKey: String
    @Binding var refreshList: Bool
    
    var displayedFilters: Set<String>
    
    var body: some View {
        HStack {
            if displayedFilters.contains("name") {
                headerView(title: "table_header_name", sortingKey: "name")
            }
            if displayedFilters.contains("email") {
                headerView(title: "table_header_email", sortingKey: "email")
            }
            if displayedFilters.contains("phone") {
                headerView(title: "table_header_phone", sortingKey: "phone")
            }
            if displayedFilters.contains("firstInformation") {
                headerView(title: "table_header_first_information", sortingKey: "firstInformation")
            }
            if displayedFilters.contains("secondInformation") {
                headerView(title: "table_header_second_information", sortingKey: "secondInformation")
            }
            if displayedFilters.contains("thirdInformation") {
                headerView(title: "table_header_third_information", sortingKey: "thirdInformation")
            }
            if displayedFilters.contains("fourthInformation") {
                headerView(title: "table_header_fourth_information", sortingKey: "fourthInformation")
            }
            if displayedFilters.contains("gender") {
                headerView(title: "table_header_gender", sortingKey: "gender")
            }
            if displayedFilters.contains("address") {
                headerView(title: "table_header_address", sortingKey: "address")
            }
        }
        .padding(.leading, 40)
        .padding(.trailing, 90)
    }
    
    private func headerView(title: String, sortingKey: String) -> some View {
        HStack {
            Text(LocalizedStringKey(title))
                .font(.headline)
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .foregroundColor(.gray)
                .frame(width: 10, height: 10)
                .padding(.leading, 3)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.set()
                    } else {
                        NSCursor.arrow.set()
                    }
                }
                .onTapGesture {
                    self.sortingKey = sortingKey
                    isAscending.toggle()
                    refreshList.toggle()
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
