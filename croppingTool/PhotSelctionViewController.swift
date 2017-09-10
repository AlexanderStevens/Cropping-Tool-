//
//  PhotSelctionViewController.swift
//  croppingTool
//
//  Created by AlexS on 09/09/2017.
//  Copyright © 2017 AStevensProductions. All rights reserved.
//

import UIKit
import MobileCoreServices

class PhotSelctionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var  imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePickerController.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    @IBAction func openGallery(_ sender: UIButton) {
    }
    @IBAction func selectPhoto(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Select a Photo", message: "Choose a source", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
            {
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.allowsEditing = true
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        })
        
        let library = UIAlertAction(title: "Library", style: .default, handler: { (UIAlertAction) in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary))
            {
                self.imagePickerController.sourceType = .photoLibrary
                self.imagePickerController.allowsEditing = false
                
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(camera) //library,cancel
        alert.addAction(library)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image : UIImage? = nil
        
        let storybord = UIStoryboard.init(name: "Main", bundle: nil)
        let cropVC = storybord.instantiateViewController(withIdentifier: "cropVC") as! CroppingViewController
        
        if let selectedImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
           image = selectedImg
            dismiss(animated: true, completion: nil)

        }
        cropVC.startingPhoto = image
        self.present(cropVC, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
