import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to StudyPal"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "your personal study assistant"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let studyIconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 100, weight: .regular)
        imageView.image = UIImage(systemName: "book.circle", withConfiguration: config)
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let googleSignInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue with Google", for: .normal)
        button.setImage(UIImage(named: "google")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emailLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in with Email", for: .normal)
        button.setImage(UIImage(systemName: "envelope.fill"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "New to StudyPal?"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up for free", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Email login form elements (hidden initially)
    private let emailFormView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email Address"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 8
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 8
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backToOptionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBlue
        
        // Add main container and elements
        view.addSubview(containerView)
        
        [titleLabel, subtitleLabel, studyIconImageView, 
         googleSignInButton, emailLoginButton, 
         signUpLabel, signUpButton].forEach { containerView.addSubview($0) }
        
        // Add email form elements
        containerView.addSubview(emailFormView)
        [emailTextField, passwordTextField, loginButton, 
         forgotPasswordButton, backToOptionsButton].forEach { emailFormView.addSubview($0) }
        
        // Set constraints for main container
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Main content
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            studyIconImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            studyIconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            studyIconImageView.widthAnchor.constraint(equalToConstant: 120),
            studyIconImageView.heightAnchor.constraint(equalToConstant: 120),
            
            googleSignInButton.topAnchor.constraint(equalTo: studyIconImageView.bottomAnchor, constant: 60),
            googleSignInButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            googleSignInButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            googleSignInButton.heightAnchor.constraint(equalToConstant: 55),
            
            emailLoginButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 16),
            emailLoginButton.leadingAnchor.constraint(equalTo: googleSignInButton.leadingAnchor),
            emailLoginButton.trailingAnchor.constraint(equalTo: googleSignInButton.trailingAnchor),
            emailLoginButton.heightAnchor.constraint(equalToConstant: 55),
            
            signUpLabel.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signUpLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor),
            signUpLabel.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -4),
            
            signUpButton.centerYAnchor.constraint(equalTo: signUpLabel.centerYAnchor),
            signUpButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 4),
            signUpButton.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor),
            
            // Email form view
            emailFormView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emailFormView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            emailFormView.topAnchor.constraint(equalTo: containerView.topAnchor),
            emailFormView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: studyIconImageView.bottomAnchor, constant: 60),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            emailTextField.heightAnchor.constraint(equalToConstant: 55),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 55),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 55),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            backToOptionsButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 30),
            backToOptionsButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        // Enable login button when fields are not empty
        [emailTextField, passwordTextField].forEach { field in
            field.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }
    
    private func setupActions() {
        emailLoginButton.addTarget(self, action: #selector(showEmailLogin), for: .touchUpInside)
        backToOptionsButton.addTarget(self, action: #selector(showLoginOptions), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func showEmailLogin() {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.emailFormView.isHidden = false
            self.titleLabel.isHidden = true
            self.subtitleLabel.isHidden = true
            self.googleSignInButton.isHidden = true
            self.emailLoginButton.isHidden = true
            self.signUpLabel.isHidden = true
            self.signUpButton.isHidden = true
        }
    }
    
    @objc private func showLoginOptions() {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve) {
            self.emailFormView.isHidden = true
            self.titleLabel.isHidden = false
            self.subtitleLabel.isHidden = false
            self.googleSignInButton.isHidden = false
            self.emailLoginButton.isHidden = false
            self.signUpLabel.isHidden = false
            self.signUpButton.isHidden = false
            self.studyIconImageView.isHidden = false
        }
    }
    
    @objc private func textFieldDidChange() {
        let isEnabled = !(emailTextField.text?.isEmpty ?? true) && !(passwordTextField.text?.isEmpty ?? true)
        loginButton.alpha = isEnabled ? 1.0 : 0.6
        loginButton.isEnabled = isEnabled
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter both email and password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(_bridgedNSError: error) {
                    switch errorCode.code {
                    case .wrongPassword:
                        self?.showError("Incorrect password. Please try again.")
                    case .userNotFound:
                        self?.showError("No account exists with this email. Please sign up first.")
                    case .invalidEmail:
                        self?.showError("Please enter a valid email address.")
                    case .userDisabled:
                        self?.showError("This account has been disabled. Please contact support.")
                    case .networkError:
                        self?.showError("Network error. Please check your internet connection.")
                    case .tooManyRequests:
                        self?.showError("Too many failed attempts. Please try again later.")
                    default:
                        self?.showError("Login failed. Please check your email and password.")
                    }
                } else {
                    self?.showError("Login failed. Please check your email and password.")
                }
                return
            }
            self?.handleSuccessfulLogin()
        }
    }
    
    @objc private func forgotPasswordTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Please enter your email address")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error as NSError? {
                let errorCode = error.code
                
                switch errorCode {
                case 17011: // User not found
                    self?.showError("No account exists with this email address.")
                case 17008: // Invalid email
                    self?.showError("Please enter a valid email address.")
                case 17010: // Network error
                    self?.showError("Network error. Please check your internet connection.")
                default:
                    self?.showError("Failed to send password reset email: \(error.localizedDescription)")
                }
                return
            }
            self?.showSuccessMessage("Password reset email has been sent")
        }
    }
    
    @objc private func googleSignInTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                self?.showError("Google Sign In Error: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self?.showError("Failed to get ID token.")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            self?.authenticateWithFirebase(credential: credential)
        }
    }
    
    @objc private func signUpTapped() {
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .fullScreen
        present(signUpVC, animated: true)
    }
    
    private func authenticateWithFirebase(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                self?.showError("Authentication failed: \(error.localizedDescription)")
                return
            }
            self?.handleSuccessfulLogin()
        }
    }
    
    private func handleSuccessfulLogin() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.setupMainInterface()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 