//
//  ViewController.swift
//  croppingTool
//
//  Created by AlexS on 09/09/2017.
//  Copyright © 2017 AStevensProductions. All rights reserved.
//

import UIKit

class CroppingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    override func viewDidAppear(_ animated: Bool) {
        imagePickerController.delegate = self
        mainImageView.image = startingPhoto
    }
    
    private func saveToGallery(croppedImage:UIImage) {
        
        self.imagesArray.append(croppedImage)
        print("imageArrayCount: \(self.imagesArray.count)")
    }
    
    @IBAction func savePhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select a Photo", message: "Choose a source", preferredStyle: .actionSheet)
        let save = UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            let newImage = self.crop(img: self.mainImageView.image!, to: self.croppingImageView.frame)
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
        print("Holding View Wodth: \(holdingView.frame.size.width)")
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
    
    func crop(img:UIImage, to: CGRect) -> UIImage {
        
        let scale = CGFloat((img.cgImage?.width)!) / mainImageView.frame.size.width
        print("Scale: \(scale)")
        print("Image scale: \(img.scale)")
        
        var rect = to
        rect.origin.x *= scale
        rect.origin.y *= scale
        rect.size.width *= scale
        rect.size.height *= scale
        
        print("Rect, x: \(rect.origin.x), y: \(rect.origin.y), width: \(rect.size.width), height: \(rect.size.height)")
        print("mainImg, width: \(img.cgImage?.width), height: \(img.cgImage?.height)")
        print("cgImg, width: \(img.size.width), height: \(img.size.height)")
        print("mainImgView, x: \(mainImageView.frame.origin.x), y: \(mainImageView.frame.origin.y), width: \(mainImageView.frame.size.width), height: \(mainImageView.frame.size.height)")
        scale = 
        let imageRef = img.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: img.scale, orientation: img.imageOrientation)
        
        return image
        
//        let cgimage = img.cgImage!
//        print("crop: cgimage width \(cgimage.width) img width \(img.size.width)")
//        var scale =  CGFloat(cgimage.width) / CGFloat(img.size.width)
//        print("Scale: \(scale)")
//        let newWidth = to.width * scale
//        let newHeight = to.height * scale
//        let newX = to.maxX * scale
//        let newY = to.maxY * scale
//        
//        let newRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
//        
//        let c = cgimage.cropping(to: newRect)!
//        
//        print("New image width: \(c.width)")
//        
//        //            scale = CGFloat(croppingImageView.frame.size.width) / CGFloat(mainImageView.frame.width)
//        return UIImage(cgImage: c, scale: scale, orientation: img.imageOrientation)
//        //
        //            UIGraphicsBeginImageContextWithOptions(to.size, false, imgScale
        //            cropped.draw(in: CGRect(x: posX, y: posY, width: to.width, height: to.height))
        //            let resized = UIGraphicsGetImageFromCurrentImageContext()
        //            UIGraphicsEndImageContext()
        //            return resized!
        
    }
}

