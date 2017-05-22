//
//  ConnectionController.swift
//  PaiementJ.O
//
//  Created by joffrey pijoan on 21/05/2017.
//  Copyright © 2017 joffrey pijoan. All rights reserved.
//

import UIKit


class ConnectionController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func clickedConnection(_ sender: Any) {
        //if compte bon
        performSegue(withIdentifier: "segueToScan", sender: nil)
        //else
        //alertview (login ou password mauvais)
    }

}
