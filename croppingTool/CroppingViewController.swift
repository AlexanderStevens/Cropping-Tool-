//
//  ViewController.swift
//  croppingTool
//
//  Created by AlexS on 09/09/2017.
//  Copyright © 2017 AStevensProductions. All rights reserved.
//

import UIKit
import CoreGraphics

class CroppingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var holdingViewAspectRatioContraint: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    var startingPhoto : UIImage?
    private var imagePickerController = UIImagePickerController()
    private var imagesArray = [UIImage]()
    
    @IBOutlet var holdingView: UIView!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var croppingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        croppingImageView.layer.borderColor = UIColor.black.cgColor
        croppingImageView.layer.borderWidth = 2
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imagePickerController.delegate = self
        mainImageView.image = startingPhoto
        
        // Set holding view aspect ratio to match aspect ratio of startingPhoto
        let ar = startingPhoto!.size.width / startingPhoto!.size.height
        holdingView.removeConstraint(holdingViewAspectRatioContraint)
        holdingViewAspectRatioContraint = NSLayoutConstraint(item: holdingView, attribute: .width, relatedBy: .equal, toItem: holdingView, attribute: .height, multiplier: ar, constant: 0.0)
        holdingView.addConstraint(holdingViewAspectRatioContraint)
        
    }
    
    private func saveToGallery(croppedImage:UIImage) {
        
        self.imagesArray.append(croppedImage)
        print("imageArrayCount: \(self.imagesArray.count)")
    }
    
    @IBAction func savePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select a Photo", message: "Choose a source", preferredStyle: .actionSheet)
        let save = UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            let newscale = self.scale(from: self.mainImageView.frame.size.width, to: self.startingPhoto!.size.width)
            var rect = self.croppingImageView.frame
            rect.origin.x *= newscale
            rect.origin.y *= newscale
            rect.size.width *=  newscale
            rect.size.height *=  newscale
            
            let newImage = self.crop(img: self.mainImageView.image!, to: rect)
            self.croppingImageView.image = newImage
            self.saveToGallery(croppedImage: newImage)
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(save)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func changePhoto(_ sender: UIButton) {
        
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
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        // print("Holding View Wodth: \(holdingView.frame.size.width)")
        let translation = recognizer.translation(in: self.holdingView)
        if let cropview = recognizer.view {
            let newX = cropview.frame.origin.x + translation.x
            let newY = cropview.frame.origin.y + translation.y
            print("newx:\(newX)")
            print("newX+ boxWidth \(newX + view.frame.width)")
            // x,y origin not center
            let newRect = CGRect(x: newX, y: newY, width: cropview.frame.width, height: cropview.frame.height)
            if holdingView.bounds.contains(newRect){
                cropview.center = CGPoint(x:cropview.center.x + translation.x, y:cropview.center.y + translation.y)
            }
            
        }
        recognizer.setTranslation(CGPoint.zero, in: self.holdingView)
    }
    
    @IBAction func handlePinch(recognizer:UIPinchGestureRecognizer) {
        let view = UIView(frame: croppingImageView.frame)
        view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        
        if holdingView.bounds.contains(view.frame) {
            croppingImageView.frame = view.frame
        }
        recognizer.scale = 1
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            startingPhoto = selectedImg
            croppingImageView.image = nil
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func scale(from: CGFloat, to: CGFloat) -> CGFloat {
        let scale = to / from
        return scale
    }
    
    func crop(img:UIImage, to: CGRect) -> UIImage {
        
        //        print("toRect, x: \(to.origin.x), y:\(to.origin.y), width: \(to.size.width), height: \(to.size.height)")
        //        print(" ")
        //        print("mainImg, width: \(String(describing: img.cgImage?.width)), height: \(String(describing: img.cgImage?.height))")
        //        print("cgImg, width: \(img.size.width), height: \(img.size.height)")
        //
        //        print("mainImgView, x: \(mainImageView.frame.origin.x), y: \(mainImageView.frame.origin.y), width: \(mainImageView.frame.size.width), height: \(mainImageView.frame.size.height)")
        //        print("Rect, x: \(rect.origin.x), y: \(rect.origin.y), width: \(rect.size.width), height: \(rect.size.height)")
        
        // Manually get CGImageRef from UIImage ignoring imageOrientation...
        UIGraphicsBeginImageContext(img.size)
        img.draw(in: CGRect(x: 0.0, y: 0.0, width: img.size.width, height: img.size.height))
        var imageRef = UIGraphicsGetCurrentContext()!.makeImage()!
        UIGraphicsEndImageContext()
        
        // Crop CGImageRef
        imageRef = imageRef.cropping(to: to)!
        
        // Get UIImage from CGImageRef
        let image = UIImage(cgImage: imageRef , scale: 1.0  , orientation: .up)
        
        return image
    }
}

