//
//  InformationPostingViewController.swift
//  On the map
//
//  Created by Nitish on 06/01/17.
//  Copyright © 2017 Nitish. All rights reserved.
//
import Foundation
import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate,MKMapViewDelegate {
    var pinPlace: CLPlacemark!
    @IBOutlet weak var linkTextfield: UITextField!
    @IBOutlet weak var whereAreYouLabel: UILabel!
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var locationTextfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //I think these are not required. Just let me know :)
        setDelegate(linkTextfield)
        setDelegate(locationTextfield)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(enable: true)                   //to configure the view when the view appears at first.
    }
    
    func configureUI(enable: Bool){
        linkTextfield.isHidden = enable
        whereAreYouLabel.isHidden = !enable
        studyingLabel.isHidden = !enable
        mapViewOutlet.isHidden = enable
        submitButton.isHidden = enable
        findOnTheMapButton.isHidden = !enable
        locationTextfield.isHidden = !enable
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        
        //brings back to map view controller
        dismiss(animated: true, completion: nil)
    }
    
    func getLocation(){
        print("Getting location")
        guard locationTextfield.text != nil else{               //checks whether the location is entered or not
            displayAlert(error: "Please enter a location")
            return
        }
        performUIUpdatesOnMain {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            //start geocoding the string mentioned for location
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(self.locationTextfield.text!) { (results, error) in
                print("Geocoding address")
                guard error == nil else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: "Sorry there was an error with your request")
                    return
                }
                
                guard (results?.isEmpty) == false else{                 //find whether there is any data recieved
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: "Sorry we couldn't find the specified location")
                    return
                }
                
                self.pinPlace = results![0]
                self.configureUI(enable: false)
                self.mapViewOutlet.showAnnotations([MKPlacemark(placemark: self.pinPlace)] , animated: true)        //annotate the map according to the location specified
                
                if userModel.mediaURL.isEmpty == false{
                    self.linkTextfield.text = userModel.mediaURL
                }
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        
    }
    
    func postStatus(){
        print("Posting status")
        guard linkTextfield.text != nil else{               //check whether the link is entered or not
            displayAlert(error: "Please enter a link")
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        
        //if the user already has an objectID then use taskForPUTMethod otherwise use taskForPostLocation
        if userModel.objectID.isEmpty {
            ParseAPIClient.sharedInstance().taskForPostLocation(uniqueKey: userModel.userKey, firstName: userModel.firstName, lastName: userModel.lastName, mapString: locationTextfield.text!, mediaURL: linkTextfield.text!, latitude: (self.pinPlace.location?.coordinate.latitude)!, longitude: (self.pinPlace.location?.coordinate.longitude)!, completionHandlerForPost: { (data, error) in
                print("In taskForPostLocation")
                if error == nil {
                    
                    self.enterData()
                    
                    guard let objectId = data?[ParseAPIClient.ParseAPIConstants.objectId] as? String else{
                        self.displayAlert(error: "Couldn't find objectId")
                        return
                    }
                    
                    userModel.objectID = objectId
                    performUIUpdatesOnMain {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }else{
            ParseAPIClient.sharedInstance().taskForPutMethod(objectID: userModel.objectID, uniqueKey: userModel.userKey, firstName: userModel.firstName, lastName: userModel.lastName, mapString: locationTextfield.text!, mediaURL: linkTextfield.text!, latitude: (self.pinPlace.location?.coordinate.latitude)!, longitude: (self.pinPlace.location?.coordinate.longitude)!, completionHandlerForPost: { (success, error) in
                print("In taskForPutMethod")
                print(userModel.objectID)
                if success! {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.enterData()
                    performUIUpdatesOnMain {
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
    }
    
    func enterData(){
        print("entering data")
        
        //save the data till the app runs
        userModel.latitude = (self.pinPlace.location?.coordinate.latitude)!
        userModel.longitude = (self.pinPlace.location?.coordinate.longitude)!
        
        userModel.mapString = self.locationTextfield.text!
        userModel.mediaURL = self.linkTextfield.text!
    }
    @IBAction func submitButton(_ sender: Any) {
        postStatus()
    }
    @IBAction func findOnTheMapButton(_ sender: Any) {
        getLocation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
    func setDelegate(_ textfield: UITextField){
        textfield.delegate = self
    }
}

