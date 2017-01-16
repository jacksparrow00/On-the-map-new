//
//  TableViewController.swift
//  On the map
//
//  Created by Nitish on 04/01/17.
//  Copyright © 2017 Nitish. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    @IBOutlet var generateTableView: UITableView!
    var students: [ParseAPIClient.ParseModel]!

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
        self.refreshView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        generateTableView.reloadData()
    }
    func refreshView(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("refreshing view")
        ParseAPIClient.sharedInstance().taskForGetStudentLocation { (data, error) in
            print("In taskForGetStudentLocation")
            if error == nil{
                performUIUpdatesOnMain {
                    self.generateTableView.reloadData()
                }
            }else{
                print(error)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.displayAlert(error: error)
            }
            
            guard let results = data?[ParseAPIClient.ParseAPIConstants.results] as? [[String:AnyObject]] else{
                self.displayAlert(error: "Couldn't get results key")
                return
            }
            
            self.students = ParseAPIClient.ParseModel.studentInformationFromResults(results: results)
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
                print(error)
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = students[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCell", for: indexPath)
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.detailTextLabel?.text = student.mapString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.open(URL(string: students[indexPath.row].mediaURL)!, options: [:], completionHandler: nil)
    }
}

