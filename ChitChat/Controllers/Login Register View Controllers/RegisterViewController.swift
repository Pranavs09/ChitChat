//
//  RegisterViewController.swift
//  ChitChat
//
//  Created by Pranav Sharma on 2024-12-29.
//

import FirebaseAuth
import UIKit

class RegisterViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "person.circle")
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.tintColor = .gray
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        return profileImageView
    }()

    private let firstNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "First Name...."
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()

    private let lastNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Last Name...."
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email Address...."
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password...."
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()

    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Register"

        emailField.delegate = self
        passwordField.delegate = self

        //add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)

        profileImageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true

        registerButton.addTarget(
            self, action: #selector(registerButtonTapped), for: .touchUpInside)

        let gesture = UITapGestureRecognizer(
            target: self, action: #selector(didTapChangeProfilePicture))

        profileImageView.addGestureRecognizer(gesture)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        imageView.frame = CGRect(
            x: (scrollView.width - size) / 2, y: -30, width: size, height: size)
        profileImageView.frame = CGRect(
            x: (scrollView.width - size) / 2, y: imageView.bottom - 10,
            width: scrollView.width / 3, height: size)
        profileImageView.layer.cornerRadius = size / 2
        firstNameField.frame = CGRect(
            x: 30, y: profileImageView.bottom + 10,
            width: scrollView.width - 60,
            height: 52)
        lastNameField.frame = CGRect(
            x: 30, y: firstNameField.bottom + 10, width: scrollView.width - 60,
            height: 52)
        emailField.frame = CGRect(
            x: 30, y: lastNameField.bottom + 10,
            width: scrollView.width - 60, height: 52)
        passwordField.frame = CGRect(
            x: 30, y: emailField.bottom + 10, width: scrollView.width - 60,
            height: 52)
        registerButton.frame = CGRect(
            x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60,
            height: 52)
    }

    @objc private func registerButtonTapped() {

        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()

        guard let firstName = firstNameField.text,
            let lastName = lastNameField.text,
            let email = emailField.text,
            let password = passwordField.text,
            !firstName.isEmpty,
            !lastName.isEmpty,
            !email.isEmpty,
            !password.isEmpty,
            password.count >= 6
        else {
            alertUserLoginError()
            return
        }
        // Firebase Login
        DatabaseManager.shared.userExist(
            with: email,
            completion: { [weak self] exists in
                guard let strongSelf = self else {
                    return
                }

                guard !exists else {
                    //user already exists
                    self?.alertUserLoginError(message: "Account Already Exists with this Email")
                    return
                }
                FirebaseAuth.Auth.auth().createUser(
                    withEmail: email, password: password,
                    completion: { authResult, error in

                        guard authResult != nil, error == nil else {
                            return
                        }
                        DatabaseManager.shared.insertUser(
                            with: chatAppUser(
                                firstName: firstName, lastName: lastName,
                                emailAddress: email))
                        strongSelf.navigationController?.dismiss(
                            animated: true, completion: nil)
                    })
            })

    }

    @objc func alertUserLoginError(
        message: String =
            "Please Enter All The Information To Create A New Account"
    ) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc private func didTapChangeProfilePicture() {
        presentPhotoActionSheet()
    }
}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(
            title: "Profile Picture",
            message: "How would you like to select a picture",
            preferredStyle: .actionSheet)
        actionSheet.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil))
        actionSheet.addAction(
            UIAlertAction(
                title: "Take Photo",
                style: .default,
                handler: { [weak self] _ in
                    self?.presentCamera()
                }))
        actionSheet.addAction(
            UIAlertAction(
                title: "Choose Photo From Library",
                style: .default,
                handler: { [weak self] _ in
                    self?.presentPhotoPicker()
                }))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey:
            Any]
    ) {
        picker.dismiss(animated: true, completion: nil)
        guard
            let selectedImage = info[
                UIImagePickerController.InfoKey.editedImage] as? UIImage
        else {
            return
        }
        self.profileImageView.image = selectedImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
