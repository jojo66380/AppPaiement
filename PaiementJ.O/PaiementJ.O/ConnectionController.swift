//
//  ConnectionController.swift
//  PaiementJ.O
//
//  Created by joffrey pijoan on 21/05/2017.
//  Copyright © 2017 joffrey pijoan. All rights reserved.
//

import UIKit


class ConnectionController: UIViewController {
    
    let url_request = "http://172.30.0.120:5000/user/account"

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
        
        if (passwordTextField.text! == "" || loginTextField.text! == "") {
            display_alert_with_one_action(title: "Erreur formulaire", message: "Veuillez remplir le formulaire pour vous connectez", titleAction: "Fermer")
        }
        else {
            let email_tf_text = loginTextField.text!
            let password_tf_text = passwordTextField.text!
        
            //On regarde si l'utilisateur existe dans la base de données
            let result_request = RequestManager.do_post_request_account(atUrl: url_request, withData: ["mail":email_tf_text, "motdepasse":password_tf_text])
            print(result_request)
        
            //L'utilisateur n'existe pas dans la base de données
            if (result_request.count == 0) {
                display_alert_with_one_action(title: "Champs incorrects", message: "Email ou mot de passe incorrects", titleAction: "Fermer")
            }
        
            //L'utilisateur existe dans la base de données
            if (result_request.count > 0) {
                let result_type_request = result_request[0]["type"] as! String
                if (result_type_request == "orga") {
                    performSegue(withIdentifier: "segueToScan", sender: nil)
                }
                else {
                    display_alert_with_one_action(title: "Erreur compte", message: "Seule les compte organisateurs peuvent accedez au service", titleAction: "Fermer")
                }
            }
        }
    }
    
    internal func display_alert_with_one_action (title:String?, message:String?, titleAction:String?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: titleAction, style: .default, handler: nil)
        alertVC.addAction(done)
        self.present(alertVC, animated: true, completion: nil)
    }


}
