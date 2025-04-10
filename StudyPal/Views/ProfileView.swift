import SwiftUI
import UIKit



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
    @State private var name = "First Last"
    @State private var major = "major..."
    @State private var courses = "courses..."
    @State private var isEditing = false
    
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    
    // Body
    var body: some View {
        NavigationView {
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
    
    func saveProfile() {
        let profile = profiles.first ?? Profile(context: viewContext)
        profile.name = name
        profile.major = major
        profile.courses = courses
        if let image = profileImage {
            profile.imageData = image.jpegData(compressionQuality: 0.8)
        }
        do {
            try viewContext.save()
            print("Profile saved to Core Data")
        } catch {
            print("Failed to save: \(error.localizedDescription)")
        }
        print("Saved Profile:")
        print("Name: \(name)")
        print("Major: \(major)")
        print("Courses: \(courses)")
    }
}
#Preview {
    ProfileView()
}


