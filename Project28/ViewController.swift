//
//  ViewController.swift
//  Project28
//
//  Created by Miloslav Milenkov on 08/07/2019.
//  Copyright © 2019 Miloslav G. Milenkov. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    @IBOutlet var secretTextArea: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,selector: #selector(adjustForKeyboard),name: UIResponder.keyboardWillHideNotification,object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        title = "Nothing to see here"
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecredMessage()
                    } else {
                        //error in authentication
                        let ac = UIAlertController(title: "Auth failed", message: "You could not be verified. Please try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        self?.present(ac,animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "No biometrics available", message: "Your device is not configured for biometric configuration", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac,animated: true)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEnd = view.convert(keyboardScreenEnd,from:view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secretTextArea.contentInset = .zero
        } else {
            secretTextArea.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEnd.height-view.safeAreaInsets.bottom, right: 0)
        }
        
        secretTextArea.scrollIndicatorInsets = secretTextArea.contentInset
        
        let selectedRange = secretTextArea.selectedRange
        secretTextArea.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecredMessage() {
        secretTextArea.isHidden = false
        title = "Sected Stuff"
        
        secretTextArea.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
    
    @objc func saveSecretMessage(notification: Notification) {
        guard secretTextArea.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secretTextArea.text, forKey: "SecretMessage")
        secretTextArea.isHidden = true
        title = "Nothing to see here"
    }

}

