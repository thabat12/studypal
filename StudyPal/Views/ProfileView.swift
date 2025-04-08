import SwiftUI

import UIKit

struct ProfileView: View {

    

    // MARK: - State

    @State private var name = "First Last"

    @State private var major = "major..."

    @State private var courses = "courses..."

    @State private var isEditing = false

    

    @State private var profileImage: UIImage? = nil

    @State private var isImagePickerPresented = false

    // MARK: - Body

    var body: some View {

        NavigationView {

            VStack {

                ScrollView {

                    VStack(spacing: 20) {

                        // MARK: - Profile Image + Name + Affiliation

                        HStack(alignment: .center, spacing: 16) {

                            ZStack {

                                if let image = profileImage {

                                    Image(uiImage: image)

                                        .resizable()

                                        .scaledToFill()

                                        .frame(width: 70, height: 70)

                                        .clipShape(Circle())

                                } else {

                                    Circle()

                                        .fill(Color.gray.opacity(0.3))

                                        .frame(width: 70, height: 70)

                                        .overlay(

                                            Text("+")

                                                .font(.system(size: 32, weight: .bold))

                                                .foregroundColor(.black)

                                        )

                                }

                            }

                            .onTapGesture {

                                if isEditing {

                                    isImagePickerPresented = true

                                }

                            }

                            VStack(alignment: .leading, spacing: 4) {

                                TextField("Enter Name", text: $name)

                                    .disabled(!isEditing)

                                    .textFieldStyle(RoundedBorderTextFieldStyle())

                                    .background(isEditing ? Color.white : Color(UIColor.systemGray6))

                                Text("Affiliation")

                                    .font(.caption)

                                    .foregroundColor(.gray)

                            }

                            Spacer()

                        }

                        .padding(.horizontal)

                        .padding(.top, -20)

                        // MARK: - Major Field

                        HStack {

                            Text("Major:")

                            TextField("major...", text: $major)

                                .disabled(!isEditing)

                                .textFieldStyle(RoundedBorderTextFieldStyle())

                                .background(isEditing ? Color.white : Color(UIColor.systemGray6))

                        }

                        .padding(.horizontal)

                        

                        // MARK: - Courses Field

                        HStack {

                            Text("Courses:")

                            TextField("courses...", text: $courses)

                                .disabled(!isEditing)

                                .textFieldStyle(RoundedBorderTextFieldStyle())

                                .background(isEditing ? Color.white : Color(UIColor.systemGray6))

                        }

                        .padding(.horizontal)

                        

                        // MARK: - Integrations

                        VStack(alignment: .leading, spacing: 15) {

                            Text("Integrations:")

                                .font(.headline)

                            

                            // Apple Calendar

                            HStack {

                                Text("Apple Calendar")

                                Spacer()

                                Button(action: openAppleCalendar) {

                                    Text("Integrate")

                                        .font(.system(size: 14))

                                        .padding(.vertical, 6)

                                        .padding(.horizontal, 12)

                                }

                                .buttonStyle(.bordered)

                            }

                            // Google Calendar

                            HStack {

                                Text("Google Calendar")

                                Spacer()

                                Button(action: openGoogleCalendar) {

                                    Text("Integrate")

                                        .font(.system(size: 14))

                                        .padding(.vertical, 6)

                                        .padding(.horizontal, 12)

                                }

                                .buttonStyle(.bordered)

                            }

                        }

                        .padding(.horizontal)

                        .padding(.top, 30)

                        

                        Spacer()

                    }

                    .padding(.bottom, 10)

                }

                .sheet(isPresented: $isImagePickerPresented) {

                    ImagePicker(selectedImage: $profileImage)

                }

            }

            .navigationTitle("Profile")

            .toolbar {

                ToolbarItem(placement: .navigationBarTrailing) {

                    Button(action: {

                        if isEditing { saveProfile() }

                        isEditing.toggle()

                    }) {

                        Text(isEditing ? "Done" : "Edit")

                            .font(.system(size: 14))

                            .padding(.vertical, 6)

                            .padding(.horizontal, 12)

                    }

                }

            }

        }

    }

    

    // MARK: - Actions

    func openAppleCalendar() {

        if let url = URL(string: "calshow://"), UIApplication.shared.canOpenURL(url) {

            UIApplication.shared.open(url)

        }

    }

    func openGoogleCalendar() {

        if let url = URL(string: "https://calendar.google.com") {

            UIApplication.shared.open(url)

        }

    }

    func saveProfile() {

        print("Saved Profile:")

        print("Name: \(name)")

        print("Major: \(major)")

        print("Courses: \(courses)")

    }

}

#Preview {

    ProfileView()

}

