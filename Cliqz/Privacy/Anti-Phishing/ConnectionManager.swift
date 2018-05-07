//
//  ConnectionManager.swift
//  Client
//
//  Created by Mahmoud Adam on 11/4/15.
//  Copyright © 2015 Cliqz. All rights reserved.
//

import Foundation
import Alamofire
//import Crashlytics

enum ResponseType {
    case jsonResponse
    case stringResponse
}

class ConnectionManager {
    
    //MARK: - Singltone
    static let sharedInstance = ConnectionManager()
    fileprivate init() {
        
    }
    
    //MARK: - Sending Requests
    internal func sendRequest(_ method: Alamofire.HTTPMethod, url: String, parameters: [String: Any]?, responseType: ResponseType, queue: DispatchQueue, onSuccess: @escaping (Any) -> (), onFailure:@escaping (Data?, Error) -> ()) {
        
        switch responseType {
            
        case .jsonResponse:
            Alamofire.request(url, method: method, parameters: parameters)
                .responseJSON(queue: queue) {
                    response in
                    self.handelJSONResponse(response, onSuccess: onSuccess, onFailure: onFailure)
            }
        case .stringResponse:
            Alamofire.request(url, method: method, parameters: parameters)
                .responseString(queue: queue) {
                    response in
                    self.handelStringResponse(response, onSuccess: onSuccess, onFailure: onFailure)
            }
        }
    }
    
    internal func sendPostRequestWithBody(_ url: String, body: Any, responseType: ResponseType, enableCompression: Bool, queue: DispatchQueue, onSuccess: @escaping (Any) -> (), onFailure:@escaping (Data?, Error) -> ()) {
        
        if JSONSerialization.isValidJSONObject(body) {
            do {
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let data = try JSONSerialization.data(withJSONObject: body, options: [])
                
                if (enableCompression) {
                    request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
                    let compressedData : Data = try data.gzipped()
                    request.httpBody = compressedData
                } else {
                    request.httpBody = data
                }
                
                switch responseType {
                case .jsonResponse:
                    Alamofire.request(request)
                        .responseJSON(queue: queue) {
                            response in
                            self.handelJSONResponse(response, onSuccess: onSuccess, onFailure: onFailure)
                    }
                case .stringResponse:
                    Alamofire.request(request)
                        .responseString(queue: queue) {
                            response in
                            self.handelStringResponse(response, onSuccess: onSuccess, onFailure: onFailure)
                    }
                }
            } catch let error as NSError {
                //Answers.logCustomEvent(withName: "sendPostRequestError", customAttributes: ["error": error.localizedDescription])
            }
        } else {
            //Answers.logCustomEvent(withName: "sendPostRequestError", customAttributes: nil)
        }
        
    }
    
    
    // MARK: - Private methods
    
    fileprivate func handelStringResponse(_ response: DataResponse<String>, onSuccess: (Any) -> (), onFailure:(Data?, Error) -> ()) {
        
        switch response.result {
            
        case .success(let string):
            onSuccess(string)
            
        case .failure(let error):
            onFailure(response.data, error)
        }
    }
    
    fileprivate func handelJSONResponse(_ response: Alamofire.DataResponse<Any>, onSuccess: (Any) -> (), onFailure:(Data?, Error) -> ()) {
        
        switch response.result {
            
        case .success(let json):
            onSuccess(json)
            
        case .failure(let error):
            onFailure(response.data, error)
        }
    }
}
