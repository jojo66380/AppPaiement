//
//  ViewController.swift
//  PaiementJ.O
//
//  Created by joffrey pijoan on 19/05/2017.
//  Copyright © 2017 joffrey pijoan. All rights reserved.
//

import UIKit
import AVFoundation

let request_url_compte = "http://172.30.0.120:5000/compte/"
let request_url_update = "http://172.30.0.120:5000/update"
var num_compte_text = String()
var character_textfield = String()

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    @IBOutlet weak var montantTextField: UITextField!
    @IBOutlet weak var numCompte: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clickedButton(_ sender: Any) {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //messageLabel.text = metadataObj.stringValue
                //print(metadataObj.stringValue)
                numCompte.text = metadataObj.stringValue
                captureSession?.stopRunning()
                videoPreviewLayer?.removeFromSuperlayer()
            }
        }
    }

    @IBAction func clickedValidationButton(_ sender: Any) {
        num_compte_text = numCompte.text!
        if montantTextField.text == "" || numCompte.text == "" {
            let alert = UIAlertController(title: "Erreur", message: "Veuillez remplir le formaulaire entièrement", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
        else {
            character_textfield = montantTextField.text!
            let character_textfield_nsstring = character_textfield as NSString
            let character_textfield_double = character_textfield_nsstring.doubleValue
            let alertVerif = UIAlertController(title: "Verification", message: "Êtes-vous sûr de vouloir faire cette transaction: \(montantTextField.text!) sur le compte: \(numCompte.text!)", preferredStyle: UIAlertControllerStyle.alert)
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: { (Ok) in
                //Url complet
                let get_correct_request = "\(request_url_compte)\(num_compte_text)"
                print(get_correct_request)
                //Fonction requete GET
                let get_request_result = RequestManager.do_get_Request(atUrl: get_correct_request)
                print(get_request_result)
                //Verif si compte existe
                if get_request_result.count == 0 {
                    print("Error de num_compte")
                }
                //Recuperation du montant du compte
                let montant_compte = get_request_result[0]["montant"] as! NSString
                let montant_compte_double = montant_compte.doubleValue
                
                let result = montant_compte_double + character_textfield_double
                
                if (result < 0) {
                    let alert = UIAlertController(title: "Erreur", message: "Le montant a débité est supérieur au montant contenu dans le compte", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true)
                }
                print(result)
                self.fetch_request_PATCH(url: request_url_update, datas_dict: ["collection":"compte", "id":num_compte_text, "field_name":"montant", "new_value":"\(result)"])

                self.montantTextField.text = ""
                self.numCompte.text = ""
                //Action sur la base de données
            })
            alertVerif.addAction(cancelButton)
            alertVerif.addAction(okButton)
            self.present(alertVerif, animated: true)
        }
    }
    
    func fetch_request_PATCH (url:String, datas_dict:[String:Any]) {
        let requestObject = NSMutableURLRequest(url: URL(string:url)!)
        requestObject.httpMethod = "PATCH"
        requestObject.addValue("application/json", forHTTPHeaderField: "Content-Type")
        requestObject.addValue("application/json", forHTTPHeaderField: "Accept")
        
        /* Envoie des données entrées en paramètres, et converties en JSON */
        let posting = JSON(datas_dict)
        requestObject.httpBody = posting.rawString()!.data(using: String.Encoding.utf8)
        print(posting.rawString()!.data(using: String.Encoding.utf8)!)
        
        
        let requestToServer = URLSession.shared.dataTask(with: requestObject as URLRequest) { (data, response, error) in
            if (error != nil){
                print(error!.localizedDescription)
            }
            else {
                let statusHTTPCode = (response as! HTTPURLResponse).statusCode
                if (statusHTTPCode == 204) {
                    print("The document with id : \(String(describing: datas_dict["id"])) was updated")
                }
            }
        }
        requestToServer.resume()
    }


}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


