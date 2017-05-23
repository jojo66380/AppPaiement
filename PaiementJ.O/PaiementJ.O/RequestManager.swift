//
//  RequestManager.swift
//  News_application
//
//  Created by Developpeur on 21/05/2017.
//  Copyright © 2017 Developpeur. All rights reserved.
//

import UIKit

class RequestManager: NSObject {
    static func do_get_Request (atUrl: String) -> [[String:Any]] {
        let requestObject = NSMutableURLRequest(url: URL(string: atUrl)!)
        requestObject.httpMethod = "GET"
        
        let content = NSData.init(contentsOf: URL(string:atUrl)!)
        let datas = JSON(content! as Data).arrayObject as! [[String:Any]]
        return datas
    }
    
    @discardableResult
    static func do_post_request_account (atUrl:String, withData:[String:Any]) -> [[String:Any]] {
        var result_request : [[String:Any]]?
        
        DispatchQueue.global(qos: .userInitiated).sync {
            let group = DispatchGroup()
            group.enter()
            
            //Debut de la requete
            let requestObject = NSMutableURLRequest(url: URL(string: atUrl)!)
            requestObject.httpMethod = "POST"
            requestObject.addValue("application/json", forHTTPHeaderField: "Content-Type")
            requestObject.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let posting = JSON(withData)
            requestObject.httpBody = posting.rawString()!.data(using: String.Encoding.utf8)
            print(posting.rawString()!.data(using: String.Encoding.utf8)!)
            
            URLSession.shared.dataTask(with: (requestObject as URLRequest), completionHandler: { (data, response, error) in
                
                if (error != nil) {
                    print(error!.localizedDescription)
                    result_request = [[String:Any]]()
                    group.leave()
                }
                else {
                    let httpcode = (response as? HTTPURLResponse)?.statusCode
                    if (httpcode == 200) {
                        let response_of_server = JSON(data!)
                        result_request = response_of_server.arrayObject as? [[String:Any]]
                        group.leave()
                    }
                    else {
                        print("passage dans le 204, no content")
                        result_request = [[String:Any]]()
                        group.leave()
                    }
                }
            }).resume()
            group.wait()
        }
        return result_request!
    }

}
