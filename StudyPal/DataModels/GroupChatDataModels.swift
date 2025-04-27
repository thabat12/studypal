//
//  GroupChatDataModel.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/16/25.
//

/*
 This file will contain everything that is group chat related for data models. This includes:
    - Group chat info model
    - Group chat message model
 */

import Foundation
import FirebaseCore
import FirebaseFirestore

enum GroupChatDataModelErrors: Error {
    case failedToParseDocument
}

@MainActor
final class GroupDirectoryViewModel: ObservableObject {
    
    // states
    @Published private(set) var groups: [GroupChatInfoModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var nameCache: [String: String] = [:]
    private var nameFetchTask: Task<Void, Never>? = nil
    @Published var hasError = false
    
    
    func fetchAllGroups() async {
        isLoading = true
        do {
            groups = try await StudyPalAPI.queryAllGroups()
            nameFetchTask?.cancel()
                        nameFetchTask = Task {
                            let allUIDs = groups.flatMap { $0.members ?? [] }
                            let map = try? await StudyPalAPI.getDisplayNames(for: allUIDs)
                            await MainActor.run { self.nameCache = map ?? [:] }
                        }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            hasError = true
        }
        isLoading = false
    }
    
    func join(_ group: GroupChatInfoModel) async {
        do {
            try await StudyPalAPI.joinGroup(groupId: group.id) 
        } catch {
            errorMessage = error.localizedDescription
            hasError = true
        }
    }
    
    // Helper functions
    
    func filteredGroups(search: String) -> [GroupChatInfoModel] {
        guard !search.isEmpty else { return groups }
        return groups.filter { ($0.name ?? "")
            .localizedCaseInsensitiveContains(search) }
    }
    
    func names(for members: [String]) -> [String] {
        members.map { nameCache[$0] ?? $0 }
    }
}


