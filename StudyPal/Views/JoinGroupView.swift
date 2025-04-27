//
//  JoinGroupView.swift
//  StudyPal
//

import SwiftUI
import FirebaseFirestore

struct JoinGroupView: View {
    
    // Search text
    @State private var searchText = ""
    
    // View-model
    @StateObject private var vm = GroupDirectoryViewModel()
    
    var body: some View {
        List {
            if vm.isLoading {
                ProgressView()
            } else {
                ForEach(vm.filteredGroups(search: searchText)) { group in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(group.name ?? "Untitled Group")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                Task { await vm.join(group) }
                            }) {
                                Text("Join")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                        }
                        if let members = group.members {
                            let names = vm.names(for: members).joined(separator: ", ")
                            Text("Members: \(names)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Join Group")
        .searchable(text: $searchText, placement: .navigationBarDrawer)
        .onAppear { Task { await vm.fetchAllGroups() } }
        .alert(isPresented: $vm.hasError) {
            Alert(
                title:   Text("Error"),
                message: Text(vm.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {

    JoinGroupView()

}
