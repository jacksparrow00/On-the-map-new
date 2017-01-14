//
//  ViewController.swift
//  On the map
//
//  Created by Nitish on 26/12/16.
//  Copyright © 2016 Nitish. All rights reserved.
//

import UIKit

extension UIViewController{
    func displayAlert(error: String?){
        performUIUpdatesOnMain {
            let alertController = UIAlertController()
            alertController.title = "Error"
            alertController.message = error
            let alertAction = UIAlertAction(title: "OK", style: .default) { action in self.dismiss(animated: true, completion: nil)}
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var keyboardOnScreen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate(emailTextField)
        setDelegate(passwordTextField)
        
        subscribeToNotification(notification: .UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(notification: .UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(notification: .UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(notification: .UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
    }
    @IBAction func loginPressed(_ sender: Any) {
        setUIEnabled(enabled: false)
        
        guard emailTextField.text != nil && passwordTextField.text != nil else{
            setUIEnabled(enabled: true)
            self.displayAlert(error: "One of the fields is empty")
            return
        }
        print("Login pressed")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        UdacityAPIClient.sharedInstance().taskForPostmethod(username: emailTextField.text!, password: passwordTextField.text!) { (data, error) in
            print("In taskForPostMethod")
            if error == nil{
            guard let account = data?["account"] as? [String:Any] else{
                self.displayAlert(error: "Couldn't find the account key")
                self.setUIEnabled(enabled: true)
                return
            }
            
            self.completeLogin(account: account)
            }else{
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
                self.setUIEnabled(enabled: true)
            }
        }
    }
    
    func completeLogin(account: [String:Any]){
        setUIEnabled(enabled: true)
        if let key = account["key"] as? String{
            print("In completeLogin")
            userModel.userKey = key
            print(key)
            UdacityAPIClient.sharedInstance().taskForGetData(userId: key){ (data, error) in
                print("In taskForGetData")
                if error == nil{
                    let userData = data?["user"] as! NSDictionary
                    let firstName = userData["first_name"] as! String
                    let lastName = userData["last_name"] as! String
                    
                    
                    userModel.firstName = firstName
                    userModel.lastName = lastName
                    print(userModel.firstName)
                    print(userModel.lastName)
                }else{
                    print(error)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
            }
        }else{
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.displayAlert(error: "Couldn't find the user key")
            
        }
        performUIUpdatesOnMain {
            let controller =
                self.storyboard?.instantiateViewController(withIdentifier: "MapTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func setUIEnabled (enabled : Bool) {
        performUIUpdatesOnMain {
        self.loginButton.isEnabled = enabled
        self.emailTextField.isEnabled = enabled
        self.passwordTextField.isEnabled = enabled
        
        if enabled{
            self.loginButton.alpha = 1.0
        }else{
            self.loginButton.alpha = 0.5
        }
            if enabled {
                self.loginButton.setTitle("Login", for: .normal)
            } else {
                self.loginButton.setTitle("Loggin In", for: .disabled)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(URL(string: UdacityAPIClient.UdacityAPIConstants.signUpURL)!, options: [:], completionHandler: nil)
    }
}

extension LoginViewController : UITextFieldDelegate{
    func setDelegate( _ textfield: UITextField){
        textfield.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow( notification: Notification){
        if !keyboardOnScreen{
            view.frame.origin.y -= keyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide( notification: Notification){
        if keyboardOnScreen{
            view.frame.origin.y += keyboardHeight(notification: notification)
            view.frame.origin.y = 0
        }
    }
    
    func keyboardDidShow(notification: Notification){
        keyboardOnScreen = true
    }
    
    func keyboardDidHide( notification: Notification){
        keyboardOnScreen = false
    }
    
    private func keyboardHeight( notification: Notification) -> CGFloat{
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToNotification( notification : NSNotification.Name, selector: Selector){
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
}
