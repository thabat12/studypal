import SwiftUI
import UIKit
import FirebaseAuth



// ImagePicker Utility

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {

        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker

    }

    

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[.editedImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Profile.entity(),
        sortDescriptors: []
    ) private var profiles: FetchedResults<Profile>

    // State
    @State private var name = "Loading..."
    @State private var affiliation = "affiliation..."
    @State private var major = "major..."
    @State private var courses = "courses..."
    @State private var isEditing = false
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerPresented = false

    // Body
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image + Name + Affiliation
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
                            Text(name)
                                .font(.headline)
                            TextField("affiliation...", text: $affiliation)
                                .disabled(!isEditing)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .background(isEditing ? Color.white: Color(UIColor.systemGray6))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    // Major Field
                    HStack {
                        Text("Major:")
                        TextField("major...", text: $major)
                            .disabled(!isEditing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .background(isEditing ? Color.white : Color(UIColor.systemGray6))
                    }

                    // Courses Field
                    HStack {
                        Text("Courses:")
                        
                        TextField("courses...", text: $courses)
                            .disabled(!isEditing)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .background(isEditing ? Color.white : Color(UIColor.systemGray6))
                    }


                    // Integrations
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
                    .padding(.top, 30)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $profileImage)
            }
            .onAppear {
                if let existingProfile = profiles.first {
                    name = existingProfile.name ?? "First Last"
                    major = existingProfile.major ?? "major..."
                    courses = existingProfile.courses ?? "courses..."
                    
                    if let data = existingProfile.imageData {
                        profileImage = UIImage(data: data)
                    }
                }
                
                name = StudyPalAPI.currentUserDisplayName() ?? "Unknown"
                
                Task {
                    do {
                        let data = try await StudyPalAPI.fetchPublicProfileFields()
                        affiliation = data["affiliation"] as? String ?? affiliation
                        major       = data["major"]       as? String ?? major
                        if let arr  = data["courses"]     as? [String] {
                            courses = arr.joined(separator: ", ")
                        }
                        
                        if profileImage == nil,
                                   let urlString = data["imageURL"] as? String,
                                   let url = URL(string: urlString) {

                                    let (d, _) = try await URLSession.shared.data(from: url)
                                    if let img = UIImage(data: d) {
                                        await MainActor.run {
                                            profileImage = img
                                        }
                                    }
                                }
                    } catch {
                        print("Failed to fetch profile fields: \(error)")
                    }
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
    

    // Actions
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

    @MainActor
    private func saveProfile() {

        let uid = Auth.auth().currentUser?.uid ?? "local"
        let profile = profiles.first ?? {
            let p = Profile(context: viewContext)
            p.id = uid
            return p
        }()

        // 2.  Update local fields
        profile.major   = major
        profile.courses = courses
        if let uiImage = profileImage {
            profile.imageData = uiImage.jpegData(compressionQuality: 0.8)
        }

        try? viewContext.save()

        Task {
            do {
                var remoteURL: String? = nil

                if let uiImage = profileImage {
                    remoteURL = try await StudyPalAPI.uploadProfileImage(uiImage)
                }

                let courseArray = courses
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

                try await StudyPalAPI.updatePublicProfileFields(
                    major      : major,
                    courses    : courseArray,
                    affiliation: affiliation,
                    imageURL   : remoteURL
                )
                print("profile saved + uploaded")
            } catch {
                print("saveProfile error: \(error)")
            }
        }
    }








}

#Preview {

    ProfileView()

}

