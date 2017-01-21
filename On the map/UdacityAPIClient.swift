//
//  UdacityAPIClient.swift
//  On the map
//
//  Created by Nitish on 28/12/16.
//  Copyright © 2016 Nitish. All rights reserved.
//

import Foundation

class UdacityAPIClient: NSObject{
    var session = URLSession.shared
    
    func taskForPostmethod( username: String, password: String, completionHandlerForPost : @escaping (_ result: AnyObject?, _ error: String?) -> Void){
        
        //to login into udacity
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue(UdacityAPIClient.UdacityAPIConstants.value, forHTTPHeaderField: "Accept")
        request.addValue(UdacityAPIClient.UdacityAPIConstants.value, forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest){ data, response, error in
            func sendError(errorString: String){
                performUIUpdatesOnMain {
                    print(errorString)
                    completionHandlerForPost(nil,errorString)
                }
            }
            
            guard error == nil else{
                sendError(errorString: "Your request returned an error : \(error?.localizedDescription)")
                return
            }
            
            /*if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300{
                sendError(errorString: "Your request returned a status code other than 2xx")
                print(error?.localizedDescription)
                print(statusCode)
                return
            }else{
                print("status code is 2xx")
            }*/
            
            guard let data = data else{
                sendError(errorString: "Your request didn't return any data")
                return
            }
            
            let range = Range(uncheckedBounds: (5,data.count))
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForPost)
        }
        task.resume()
    }
    
    func taskForDeleteMethod(completionForDeleteMethod: @escaping(_ result: Bool?, _ error: String?) -> Void){
        
        //to log out of udacity
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN"{
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie{
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(errorString: String){
                performUIUpdatesOnMain {
                    print(error!)
                    completionForDeleteMethod(false, errorString)
                }
            }
            
            guard error == nil else{
                sendError(errorString: "Your request returned an error: \(error?.localizedDescription)")
                return
            }
            
            /*guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else{
                sendError(errorString: "Your request returned a status code other than 2xx")
                return
            }*/
            
            guard let data = data else{
                sendError(errorString: "Your request didn't return any data")
                return
            }
            
            let range = Range(uncheckedBounds: (5,data.count))
            let newData = data.subdata(in: range)
            
            completionForDeleteMethod(true,nil)
        }
        task.resume()
    }
    
    private func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: String?) -> Void){       //parse the data into JSON
        var parsedResult:AnyObject!
        do{
            parsedResult = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        }catch{
            print("Error occured while parsing the data \(data)")
            completionHandlerForConvertData(nil,error.localizedDescription)
        }
        completionHandlerForConvertData(parsedResult,nil)
    }

    
    func taskForGetData(userId: String, completionHandlerForGetData: @escaping(_ result: AnyObject?, _ error: String?) -> Void ){
        
        //get user data from udacity
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userId)")!)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            func sendError(errorString: String){
                performUIUpdatesOnMain {
                    print(error!)
                    completionHandlerForGetData(nil, errorString)
                }
            }
            
            guard error == nil else{
                sendError(errorString: "Your request returned an error: \(error?.localizedDescription)")
                return
            }
            
            /*guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else{
                sendError(errorString: "Your request returned a status code other than 2xx")
                return
            }*/
            
            guard let data = data else{
                sendError(errorString: "Your request didn't return any data")
                return
            }
            
            let range = Range(uncheckedBounds: (5,data.count))
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForGetData)
        }
        task.resume()
    }
    
    class func sharedInstance() -> UdacityAPIClient{
        struct Singleton{
            static var sharedInstance = UdacityAPIClient()
        }
        return Singleton.sharedInstance
    }
}


