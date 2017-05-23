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
}
