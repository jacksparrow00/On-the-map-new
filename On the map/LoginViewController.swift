//
//  ViewController.swift
//  On the map
//
//  Created by Nitish on 26/12/16.
//  Copyright © 2016 Nitish. All rights reserved.
//

import UIKit

extension UIViewController{
    func displayAlert(error: String?){      //to display all the errors in the app
        performUIUpdatesOnMain {
            let alertController = UIAlertController()
            alertController.title = "Error"
            alertController.message = error
            let alertAction = UIAlertAction(title: "OK", style: .default)
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
        
        //for all the smaller devices and using landscape mode, we are using keyboard notifications to shift the view accordingly
        subscribeToNotification(notification: .UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(notification: .UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(notification: .UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(notification: .UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()      //as the method name suggests, we are unsubscribing from all the notifications when the view disappears
        
    }
    @IBAction func loginPressed(_ sender: Any) {
        setUIEnabled(enabled: false)
        
        guard emailTextField.text != nil && passwordTextField.text != nil else{     //check whether the textfields are empty or not and give error accordingly
            setUIEnabled(enabled: true)
            self.displayAlert(error: "One of the fields is empty")
            return
        }
        print("Login pressed")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //run the login process
        UdacityAPIClient.sharedInstance().taskForPostmethod(username: emailTextField.text!, password: passwordTextField.text!) { (data, error) in
            print("In taskForPostMethod")
            if error == nil{
            guard let account = data?["account"] as? [String:Any] else{     //find account key in the parsed data
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
        
        //continuing the login process
        setUIEnabled(enabled: true)
        if let key = account["key"] as? String{     //finding the "key" key in the parsed data
            print("In completeLogin")
            userModel.userKey = key
            print(key)
            
            //get the user related data and store it for further usage
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
        performUIUpdatesOnMain {                //brings the map view controller on screen
            let controller =
                self.storyboard?.instantiateViewController(withIdentifier: "MapTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func setUIEnabled (enabled : Bool) {                //adjusts the appearance and status of the buttons when login is pressed
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
                self.loginButton.setTitle("Logging In", for: .disabled)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {          //provides sign up link
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
    
    func keyboardWillShow( notification: Notification){             //shifts the view when keyboard appears
        if !keyboardOnScreen{
            view.frame.origin.y -= keyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide( notification: Notification){             //brings the back to normal view when keyboard disappears
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
    
    private func keyboardHeight( notification: Notification) -> CGFloat{                //measures the keyboard size to adjust the view accordingly
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToNotification( notification : NSNotification.Name, selector: Selector){                  //subscribe to notifications
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
}
