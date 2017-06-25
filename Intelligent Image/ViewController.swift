//
//  ViewController.swift
//  Intelligent Image
//
//  Created by Atil Samancioglu on 23/06/2017.
//  Copyright © 2017 Atil Samancioglu. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var chosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func changeClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            self.chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
        
    }
    
    
    func recognizeImage(image: CIImage) {
        
        resultLabel.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) {
            
            let request = VNCoreMLRequest(model: model, completionHandler: { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    
                    let topResult = results.first
                    
                    DispatchQueue.main.async {
                        
                        let conf = (topResult?.confidence)! * 100
                        
                        let rounded = Int (conf * 100) / 100
                        
                        self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                        
                    }
                }
            })
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    try handler.perform([request])
                    
                } catch {
                    print("error")
                }
                
            }
            
        }
        
        
    }
    
}

