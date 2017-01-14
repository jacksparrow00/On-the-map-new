//
//  MapViewController.swift
//  On the map
//
//  Created by Nitish on 11/01/17.
//  Copyright © 2017 Nitish. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    var students: [ParseAPIClient.ParseModel]!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let b1 = UIBarButtonItem(barButtonSystemItem: .refresh , target: self, action: #selector(refreshView))
        let b2 = UIBarButtonItem(image: #imageLiteral(resourceName: "pin") , style: .plain , target: self, action: #selector(pinIt))
        self.navigationItem.rightBarButtonItems = [b1,b2]
        let b3 = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut))
        self.navigationItem.leftBarButtonItem = b3
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ParseAPIClient.sharedInstance().taskForGetLocation(uniqueKey: userModel.userKey) { (data, error) in
            print("In taskForGetLocation")
            if error == nil{
                guard let results = data?[ParseAPIClient.ParseAPIConstants.results] as? [[String:AnyObject]] else{
                    self.displayAlert(error: "Could not find results key")
                    return
                }
                
                guard let latitude = results.last?[ParseAPIClient.ParseAPIConstants.latitude] as? Double else{
                    self.displayAlert(error: "Could not find latitude key")
                    return
                }
                userModel.latitude = latitude
                
                guard let longitude = results.last?[ParseAPIClient.ParseAPIConstants.longitude] as? Double else{
                    self.displayAlert(error: "Couldn't find longitude key")
                    return
                }
                userModel.longitude = longitude
                
                guard let mediaURL = results.last?[ParseAPIClient.ParseAPIConstants.mediaURL] as? String else{
                    self.displayAlert(error: "Couldn't find mediaURL key")
                    return
                }
                userModel.mediaURL = mediaURL
                
                guard let mapString = results.last?[ParseAPIClient.ParseAPIConstants.mapString] as? String else{
                    self.displayAlert(error: "Couldn't find mapString key")
                    return
                }
                userModel.mapString = mapString
                
                guard let objectId = results.last?[ParseAPIClient.ParseAPIConstants.objectId] as? String else{
                    self.displayAlert(error: "Couldn't find objectId key")
                    return
                }
                userModel.objectID = objectId
                
                let mapLat = userModel.latitude
                let mapLong = userModel.longitude
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                performUIUpdatesOnMain {
                    let coordinates = CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong)
                    let coordinateSpan = MKCoordinateSpanMake(10, 10)
                    let coordinatesRegion = MKCoordinateRegion(center: coordinates, span: coordinateSpan)
                    self.mapView.setRegion(coordinatesRegion, animated: true)
                }
            }else{
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
                print(error!)
            }
        }
        self.refreshView()
    }

    func refreshView(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        ParseAPIClient.sharedInstance().taskForGetStudentLocation { (data, error) in
            print("In taskForGetStudentLocation")
            performUIUpdatesOnMain {
                if error == nil {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    guard let results = data?[ParseAPIClient.ParseAPIConstants.results] as? [[String:AnyObject]] else{
                        self.displayAlert(error: "Couldn't get results key")
                        return
                    }
                    
                    self.students = ParseAPIClient.ParseModel.studentInformationFromResults(results: results)
                    self.reAnnotateMap()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }else{
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.displayAlert(error: error)
                }
            }
        }
    }
    
    func logOut(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        UdacityAPIClient.sharedInstance().taskForDeleteMethod { (response, error) in
            if response!{
                performUIUpdatesOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                print(error!)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func pinIt(){
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "InformationPostingView") as! InformationPostingViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    func reAnnotateMap(){
        print("reannotating the map")
        var annotations = [MKPointAnnotation]()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        for student in students{
            let studentLatitude = CLLocationDegrees(student.latitude)
            let studentLongitude = CLLocationDegrees(student.longitude)
            let coordinates = CLLocationCoordinate2D(latitude: studentLatitude, longitude: studentLongitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "Mark"
        var pinPoint = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinPoint == nil{
            pinPoint = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinPoint?.canShowCallout = true
            pinPoint?.pinTintColor = .red
            pinPoint?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinPoint?.annotation = annotation
        }
        return pinPoint
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            if let open = view.annotation?.subtitle{
                UIApplication.shared.open(URL(string: open!)!, options: [:], completionHandler: nil)
            }
        }
    }
}
