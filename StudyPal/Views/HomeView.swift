//
//  HomeView.swift
//  StudyPal
//
//  Created by Abhi Bichal on 3/15/25.
//

import SwiftUI

// From old repository
let taskData = [
    ("IOS Time", "ios group", true),
    ("Math Homework", "Algebra", false),
    ("Science Project", "Physics", false),
    ("Read Book", "Literature", true),
    ("Workout", "Gym", false),
    ("Prepare for Exam", "Study", true),
    ("Coding Practice", "Leetcode", false),
    ("Write Blog", "Personal", false),
    ("Grocery Shopping", "Errands", false),
    ("Meeting", "Work", true)
]

let notesData = [
    ("Note Entry", "2/14/25"),
    ("Note Entry", "2/14/25"),
    ("Note Entry", "2/14/25"),
    ("Note Entry", "2/14/25")
]

struct HomeView: View {
    
    @State private var allTasks: [TaskDataModel] = taskData.map { data in
        TaskDataModel(taskName: data.0, taskType: data.1, taskIsFinished: data.2)
    }
    
    @State private var allNotes: [NoteDataModel] = notesData.map { note in
        NoteDataModel(name: note.0, date: note.1)
    }
    
    var body: some View {
        ScrollView {
            // Credit: https://medium.com/evangelist-apps/create-a-list-in-swiftui-with-sticky-section-headers-373bab2f9e96
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                
                // MARK: Tasks for Today
                Section {
                    ForEach($allTasks) {
                        $task in
                        TaskItem(taskName: task.taskName, taskType: task.taskType, taskCompleted: $task.taskIsFinished)
                    }
                } header: {
                    
                    // Custom SwiftUI struct
                    HomeHeader {
                        HStack {
                            Text("Tasks for Today")
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                // MARK: Recent Notes
                Section {
                    ForEach(allNotes) {
                        note in
                        NoteItem(name: note.name, date: note.date)
                    }
                } header: {
                    HomeHeader {
                        HStack {
                            Text("Recent Notes")
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                // MARK: Quick Actions
                Section {
                    // GeometryReader allows you to access the geometry of parent elements for relationship with the child elements
                    GeometryReader {
                        geometry in
                        
                        VStack(alignment: .center) {
                            Button(action: {}) {
                                Text("Start a Study Session")
                                    .padding()
                                    .frame(width: geometry.size.width / 7 * 5)
                            }
                            
                            Button(action: {}) {
                                Text("Review my Notes")
                                    .padding()
                                    .frame(width: geometry.size.width / 7 * 5)
                            }
                            
                            Button(action: {}) {
                                Text("Record Lecture")
                                    .padding()
                                    .frame(width: geometry.size.width / 7 * 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                } header: {
                    
                    HomeHeader {
                        HStack {
                            Text("Quick Actions")
                                .font(.system(size: 20))
                            Spacer()
                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
            }
            .padding(.bottom, 400)
        }
    }
}

#Preview {
    HomeView()
}

/*
 Just know:
  - HStack, VStack, ZStack
  - modifiers:
    .frame, .padding, .resizable -> .aspectRatio (for images)
  - withAnimation will interpolate any values that are associated with it
 */

