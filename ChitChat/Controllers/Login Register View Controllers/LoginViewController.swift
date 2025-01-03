//
//  LoginViewController.swift
//  ChitChat
//
//  Created by Pranav Sharma on 2024-12-29.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

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

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Login"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Register", style: .done, target: self,
            action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self

        //add subview
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 2
        imageView.frame = CGRect(
            x: (scrollView.width - size) / 2, y: 20, width: size,
            height: size)
        emailField.frame = CGRect(
            x: 30, y: imageView.bottom + 10, width: scrollView.width - 60,
            height: 52)
        passwordField.frame = CGRect(
            x: 30, y: emailField.bottom + 10, width: scrollView.width - 60,
            height: 52)
        loginButton.frame = CGRect(
            x: 30, y: passwordField.bottom + 10, width: scrollView.width - 60,
            height: 52)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !emailField.state.isEmpty, !passwordField.state.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
            // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self  else {
                return
            }
            
            guard let result = authResult, error == nil else {
                return
            }
            let user = result.user
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func alertUserLoginError() {
        let alert = UIAlertController(title: "Error", message: "Please Enter Valid Email and Password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}
