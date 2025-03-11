import UIKit
import EventKit
import EventKitUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let profileImageButton = UIButton(type: .system)
    let nameTextField = UITextField()
    let affiliationLabel = UILabel()
    let majorLabel = UILabel()
    let majorTextField = UITextField()
    let coursesLabel = UILabel()
    let coursesTextField = UITextField()
    let calendarLabel = UILabel()
    let calendarButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)
    let eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        setupUI()
    }

    func setupUI() {
        view.backgroundColor = .white

        // Profile Image Button
        profileImageButton.setTitle("+", for: .normal)
        profileImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        profileImageButton.setTitleColor(.black, for: .normal)
        profileImageButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        profileImageButton.layer.cornerRadius = 40
        profileImageButton.clipsToBounds = true
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.addTarget(self, action: #selector(selectProfileImage), for: .touchUpInside)
        view.addSubview(profileImageButton)

        // First & Last Name TextField
        nameTextField.placeholder = "Enter First and Last Name"
        nameTextField.font = UIFont.systemFont(ofSize: 18)
        nameTextField.borderStyle = .roundedRect
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTextField)

        // Affiliation Label
        affiliationLabel.text = "Affiliation"
        affiliationLabel.font = UIFont.systemFont(ofSize: 14)
        affiliationLabel.textColor = .gray
        affiliationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(affiliationLabel)

        // Major Label & TextField
        majorLabel.text = "Major:"
        majorLabel.font = UIFont.systemFont(ofSize: 16)
        majorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(majorLabel)

        majorTextField.placeholder = "major...."
        majorTextField.borderStyle = .roundedRect
        majorTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(majorTextField)

        // Courses Label & TextField
        coursesLabel.text = "Courses:"
        coursesLabel.font = UIFont.systemFont(ofSize: 16)
        coursesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coursesLabel)

        coursesTextField.placeholder = "courses.."
        coursesTextField.borderStyle = .roundedRect
        coursesTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coursesTextField)

        // Apple Calendar Label
        calendarLabel.text = "Apple Calendar"
        calendarLabel.font = UIFont.systemFont(ofSize: 16)
        calendarLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarLabel)

        // Apple Calendar Button
        calendarButton.setTitle("integrate", for: .normal)
        calendarButton.setTitleColor(.black, for: .normal)
        calendarButton.layer.borderWidth = 1
        calendarButton.layer.cornerRadius = 8
        calendarButton.translatesAutoresizingMaskIntoConstraints = false
        calendarButton.addTarget(self, action: #selector(integrateWithAppleCalendar), for: .touchUpInside)
        view.addSubview(calendarButton)

        // Save Button
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.borderWidth = 1
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        // Constraints
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            profileImageButton.widthAnchor.constraint(equalToConstant: 80),
            profileImageButton.heightAnchor.constraint(equalToConstant: 80),

            nameTextField.leadingAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nameTextField.topAnchor.constraint(equalTo: profileImageButton.topAnchor, constant: 10),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),

            affiliationLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            affiliationLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 5),

            majorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            majorLabel.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: 40),

            majorTextField.leadingAnchor.constraint(equalTo: majorLabel.trailingAnchor, constant: 10),
            majorTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            majorTextField.centerYAnchor.constraint(equalTo: majorLabel.centerYAnchor),
            majorTextField.widthAnchor.constraint(equalToConstant: 180),

            coursesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            coursesLabel.topAnchor.constraint(equalTo: majorLabel.bottomAnchor, constant: 20),

            coursesTextField.leadingAnchor.constraint(equalTo: coursesLabel.trailingAnchor, constant: 10),
            coursesTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            coursesTextField.centerYAnchor.constraint(equalTo: coursesLabel.centerYAnchor),
            coursesTextField.widthAnchor.constraint(equalToConstant: 180),

            calendarLabel.leadingAnchor.constraint(equalTo: majorLabel.leadingAnchor),
            calendarLabel.centerYAnchor.constraint(equalTo: calendarButton.centerYAnchor),

            calendarButton.leadingAnchor.constraint(equalTo: majorTextField.leadingAnchor),
            calendarButton.trailingAnchor.constraint(equalTo: majorTextField.trailingAnchor),
            calendarButton.topAnchor.constraint(equalTo: coursesTextField.bottomAnchor, constant: 20),
            calendarButton.heightAnchor.constraint(equalToConstant: 35),

            saveButton.topAnchor.constraint(equalTo: calendarButton.bottomAnchor, constant: 80),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    // Image Picker Functionality
    @objc func selectProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            profileImageButton.setTitle("", for: .normal)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    // Open Apple Calendar
    @objc func integrateWithAppleCalendar() {
        if let url = URL(string: "calshow://") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}


