//
//  ViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 10/23/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import UIKit
import Photos
import AWSS3
import AWSTextract

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var shadowLable: UILabel!
    @IBOutlet weak var image: UIImageView!
    
     let textract = AWSTextract(forKey: "USEast1Textract")
     var localPath: URL!
     let transfermanager = AWSS3TransferManager.default()
     let S3BucketName = "yashereceipt"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylizeUI()
    }
    
    @IBAction func didPressUpload(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.image.image = image;
        self.saveAndUpload()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func stylizeUI() {
        self.mainLabel.layer.shadowColor = UIColor.lightGray.cgColor
        self.mainLabel.layer.shadowOffset = CGSize(width: -5, height: 5)
        self.mainLabel.layer.shadowOpacity = 0.5
        self.mainLabel.layer.shadowRadius = 4.0
        self.uploadButton.layer.cornerRadius = 10
        self.uploadButton.layer.masksToBounds = false
        self.uploadButton.layer.shadowColor = UIColor.lightGray.cgColor
        self.uploadButton.layer.shadowOffset = CGSize(width: -5, height: 5)
        self.uploadButton.layer.shadowOpacity = 0.5
        self.uploadButton.layer.shadowRadius = 4.0
        self.descriptionLabel.layer.cornerRadius = 10
        self.descriptionLabel.layer.masksToBounds = true
        self.shadowLable.layer.cornerRadius = 10
        self.shadowLable.layer.masksToBounds = false
        self.shadowLable.layer.shadowColor = UIColor.lightGray.cgColor
        self.shadowLable.layer.shadowOffset = CGSize(width: -5, height: 5)
        self.shadowLable.layer.shadowOpacity = 45
        self.shadowLable.layer.shadowRadius = 4.0
    }
    
    private func saveAndUpload() {
        guard let image = self.image.image else {return}
        let data = image.pngData()
               let remoteName = "test.png"
               let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
               do {
                   try data?.write(to: fileURL)
                   localPath = fileURL
                   let uploadRequest = AWSS3TransferManagerUploadRequest()
                   uploadRequest?.body = fileURL
                   let objectKey = ProcessInfo.processInfo.globallyUniqueString + ".png"
                   uploadRequest?.key = objectKey
                   uploadRequest?.bucket = S3BucketName
                   uploadRequest?.contentType = "image/png"
                   let transferManager = AWSS3TransferManager.default()
                   transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
                       if let error = task.error {
                           print("Upload failed (\(error))")
                       }
                       self.sendToTextract(name: objectKey)
                       return nil
                   }
               }
               catch {
                   print("File not save failed")
               }
    }
    //Takes document name (object name) of the file and return text
    private func sendToTextract(name: String) {
        print(name)
        let s3Object = AWSTextractS3Object()
        s3Object?.bucket = self.S3BucketName
        print(textract.configuration.regionType.rawValue)
        s3Object?.name = name
        let request: AWSTextractDetectDocumentTextRequest = AWSTextractDetectDocumentTextRequest()
        let document = AWSTextractDocument()
        document?.s3Object = s3Object
        request.document = document
        textract.detectDocumentText(request).continueWith { (task) -> Any? in
        guard let result = task.result else {
            let error =  task.error as NSError?
            print("Should not produce error: \(error.debugDescription)")
            return nil
        }
        // Work with your result here
           let blocks = result.blocks
            for block in blocks! {
                if let text = block.text {
                    print(text)
                }
            }
            
        return nil
        }
    }

}

