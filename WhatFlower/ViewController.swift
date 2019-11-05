//
//  ViewController.swift
//  WhatFlower
//
//  Created by CASE on 6/21/19.
//  Copyright © 2019 CASE. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    @IBOutlet weak var navbar: UINavigationItem!
    
    @IBOutlet weak var selectedImage: UIImageView!
    
    @IBOutlet weak var flowerInfoLabel: UILabel!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navbar.title = "What Flower?"
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        flowerInfoLabel.textAlignment = .center
        flowerInfoLabel.text = "Click the camera button to select a photo to anazlyze."
        
        
        
    }
    
   // MARK:- FLOWER DATA MANIPULATION METHODS
    
    func updateUIWithInfo(json: JSON) {
        // if let flowerInfo = [results][]{
            let pageID = json["query"]["pageids"][0].stringValue
            let flowerInfo = json["query"]["pages"][pageID]["extract"].stringValue
            let flowerImageURL = json["query"]["pages"][pageID]["thumbnail"]["source"].stringValue
        print(flowerInfo)
        
         self.flowerInfoLabel.text = flowerInfo
        self.selectedImage.sd_setImage(with: URL(string: flowerImageURL), completed: nil)
        
        }

    func getFlowerInfo(for flower: String) {
        
        let params : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flower,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        ]
        
       Alamofire.request(wikipediaURl, method: .get, parameters: params).responseJSON { (response) in
            if response.result.isSuccess {
                let flowerJSON : JSON = JSON(response.result.value!)
                
               // print(flowerJSON)
                self.updateUIWithInfo(json: flowerJSON)
            }
        }
        
        
       
    }
    
     // MARK:- CAMERA BUTTON AND IMAGE PICKER SET-UP
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard  let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage  else {
            fatalError("Error converting userPickedImage to UIImage")
        }
            
            guard let convertedImage = CIImage(image: userPickedImage) else {
                fatalError("Error converting UIImage to CIImage")
            }
        
      detect(CiImage: convertedImage)
     
        
        imagePicker.dismiss(animated: true) {
            self.selectedImage.image = userPickedImage
        }
        
    }
    
    
    

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
       
        present(imagePicker, animated: true, completion: nil)
    }
    
    
     // MARK:- MACHINE LEARNING METHODS
    
    private func detect(CiImage: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: flowerclassification().model) else {
        fatalError("Error loading flowerclassification.mlmodel as Core ML Model")
    }
        
        let request =  VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation],
                let firstResult =  results.first        else {
                    fatalError("Model failed to process image.")
            }
                DispatchQueue.main.async {
                self.navigationItem.title = firstResult.identifier
                self.getFlowerInfo(for: firstResult.identifier)
                }
            
        })
        
        let handler = VNImageRequestHandler(ciImage: CiImage)
        
        do {
             try handler.perform([request])
        } catch {
            print(error)
        }
  
}

}
