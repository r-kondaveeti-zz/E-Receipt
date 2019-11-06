//
//  ViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 10/23/19.
//  Copyright © 2019 Yash Tech. All rights reserved.


import UIKit
import Photos
import AWSS3
import AWSTextract
import AWSMobileClient

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var shadowLabelImage: UILabel!
    @IBOutlet weak var textractLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var shadowLable: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var plusIcon: UIImageView!
    @IBOutlet weak var personIconImage: UIImageView!
    @IBOutlet weak var minusIcon: UIImageView!
    
    //MARK: S3 and Textract setup -------
    let textract = AWSTextract(forKey: "USEast1Textract")
    var localPath: URL!
    let transfermanager = AWSS3TransferManager.default()
    let S3BucketName = "yashereceipt"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = "\(AWSMobileClient.default().username!)"
        
        self.stylizeUI()
        
        //Make person icon tapable
        let tapGestureIcon = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.personIconImageTapped(gesture:)))
        personIconImage.addGestureRecognizer(tapGestureIcon)
        personIconImage.isUserInteractionEnabled = true
        
        //Make history label tapable
        let tapGestureHistoryLabel = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.historyLabelTapped(gesture:)))
        historyLabel.addGestureRecognizer(tapGestureHistoryLabel)
        historyLabel.isUserInteractionEnabled = true
        
        //Plus icon label tapable
        let tapGesturePlusIcon = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.plusIconImageTapped(gesture:)))
        plusIcon.addGestureRecognizer(tapGesturePlusIcon)
        plusIcon.isUserInteractionEnabled = true
    }
    
    
    @objc func plusIconImageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            
            //MARK: Open ImagePicker
            
            
            //MARK: Show selected image on the display
            
            
            //MARK: Send it to textract and get dollar amount
            pickImage()
            
            
            //MARK: add the image and total to the dictionary
            
            
        }
    }
    
    
    //MARK: Saves the document and uploads it to the s3 and invokes sendToTextract() and filters the text to find the total cost ($$$) ------
    @IBAction func didPressUpload(_ sender: Any) {
        self.pickImage()
    }
    
    private func saveAndUpload(_ imageToDictionary: UIImage) {
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
                self.sendToTextract(name: objectKey, imageToDictionary)
                return nil
            }
        }
        catch {
            print("File not save failed")
        }
    }
    
    //Takes document name (object name) of the file and returns text
    private func sendToTextract(name: String, _ imageToDictionary: UIImage) {
        var textFromTextract = ""
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
            let blocks = result.blocks
            for block in blocks! {
                if let text = block.text {
                    textFromTextract = textFromTextract + text
                    print(text)
                    DispatchQueue.main.async {
                        if self.getTotalCost(text: text) {
                            print("in the dispatch")
                            if text.contains("$") { self.textractLabel.text = "Total: "+text }
                            else { self.textractLabel.text = "Total: $"+text }
                        }
                    }
                }
            }
            return nil
        }
    }
    
    private func getTotalCost(text: String) -> Bool {
        if text.range(of: "^\\d{2,4}\\.\\d{2}$", options: .regularExpression) != nil {
            return true
        } else if text.range(of: "^\\$\\d{2,34}\\.\\d{2}$", options: .regularExpression) != nil {
            return true
        }
        else { return false }
    }
    
    
    //MARK: These call back functions gets called whenever the user performs tap gesture on the image icons, label (history, person) ---------
    @objc func personIconImageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            AWSMobileClient.default().signOut()
            self.transitionToLogin()
        }
    }
    
    @objc func historyLabelTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            AWSMobileClient.default().signOut()
            self.transitionToLogin()
        } else {
            transitionToHistory()
        }
    }
    
    func transitionToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
        view.window?.rootViewController = loginViewController
        view.window?.makeKeyAndVisible()
    }
    
    func transitionToHistory() {
        let historyViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.historyViewController) as? HistoryViewController
        view.window?.rootViewController = historyViewController
        view.window?.makeKeyAndVisible()
    }
    
    
    //MARK: Uses image picker and alert controller to pop up the menu -----
    private func pickImage() {
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
        self.saveAndUpload(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Styles the home page UI ----------
    private func stylizeUI() {
        Utilities.stylizeLabel(visibleLabel: mainLabel)
        Utilities.stylizeButtonAndShadow(uploadButton)
        Utilities.stylizeLabelAndShadow(visibleLabel: descriptionLabel, shadowLabel: shadowLable)
        Utilities.stylizeLabelAndShadow(visibleLabel: imageLabel, shadowLabel: shadowLabelImage)
        self.image.layer.cornerRadius = 10;
        self.image.layer.masksToBounds = true;
    }
    
}

