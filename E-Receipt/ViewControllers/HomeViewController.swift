//
//  ViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 10/23/19.
//  Copyright © 2019 Yash Tech. All rights reserved.

//MARK: Add the images with sucessful total extraction to an Array and totals to a different one --> Done
//MARK: Pop the array when user hits minus and display the image of the last element in the array and total - poped cost --> Done
//MARK: When user hits save then write it into the db -->
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
    
    var selectedImages = [UIImage]()
    var costs = [Float]()
    var totalCost: Float = 0.00
    var userName: String!
    var fileURLs = [URL]()
    
    //MARK: S3 and Textract setup -------
    let textract = AWSTextract(forKey: "USEast1Textract")
    var localPath: URL!
    let transfermanager = AWSS3TransferManager.default()
    let S3BucketName = "yashereceipt"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName = AWSMobileClient.default().username!
        userNameLabel.text = "\(AWSMobileClient.default().username!)"
        
        self.stylizeUI()
        
        //Make person icon tapable
        let tapGestureIcon = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.personIconImageTapped(gesture:)))
        personIconImage.addGestureRecognizer(tapGestureIcon)
        personIconImage.isUserInteractionEnabled = true
        
        //        Make history label tapable
        //        let tapGestureHistoryLabel = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.historyLabelTapped(gesture:)))
        //        historyLabel.addGestureRecognizer(tapGestureHistoryLabel)
        //        historyLabel.isUserInteractionEnabled = true
        
        //Plus icon label tapable
        let tapGesturePlusIcon = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.plusIconImageTapped(gesture:)))
        plusIcon.addGestureRecognizer(tapGesturePlusIcon)
        plusIcon.isUserInteractionEnabled = true
        
        //Minus icon label tapable
        let tapGestureMinusIcon = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.minusIconImageTapped(gesture:)))
        minusIcon.addGestureRecognizer(tapGestureMinusIcon)
        minusIcon.isUserInteractionEnabled = true
    }
    
    
    @objc func plusIconImageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            pickImage()
        }
    }
    
    
    @objc func minusIconImageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            
            //MARK: If the there is no last Image or Cost display some default image and cost!!
            if(self.costs.isEmpty || self.selectedImages.isEmpty)  {
                print("is empty")
                self.image.image = UIImage.from(color: .white)
                self.textractLabel.text = "Please select at least one image!"
                self.costs.removeAll()
                self.selectedImages.removeAll()
            } else {
                
                //MARK: Pop from selectedImages
                let _ = self.selectedImages.popLast()
                
                //MARK: Make the last image appear on screen
                self.image.image = self.selectedImages.last
                
                //MARK: Pop from costs
                let lastItemCost = self.costs.popLast()
                
                //MARK: Remove the last cost from the total cost
                self.totalCost -= lastItemCost!
                
                //MARK: Make the last cost appear on the screen
                self.textractLabel.text = "Total: $\(self.totalCost)"
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        for cost in costs {
            print("The costs of the recipt --- \(cost)" )
        }
    }
    
    
    
    //MARK: Saves the document and uploads it to the s3 and invokes sendToTextract() and filters the text to find the total cost ($$$) ------
    @IBAction func didPressUpload(_ sender: Any) {
        if self.uploadButton.currentTitle == "Upload" {
            self.pickImage()
        } else {
            if self.costs.isEmpty || self.selectedImages.isEmpty {
                self.textractLabel.text = "Please select at least one receipt to send"
            } else {
                //MARK: Code for writing to the db belongs here as this becomes send button
                print("Writing to db")
                for index in 0...costs.count-1 {
                    let values: [String] = ["\(self.userName!)", "Ankit", "\(self.fileURLs[index])", "\(self.costs[index])", "pending"]
                    FMDBDatabase.insert(values: values, completion: {
                        (success, error) in
                        if success { print("values inserted!") }
                    })
                }
            }
        }
    }
    
    private func saveAndUpload(_ imageToDictionary: UIImage) {
        guard let image = self.image.image else {return}
        let data = image.pngData()
        let remoteName = "\(ProcessInfo.processInfo.globallyUniqueString).png"
        print("This is the changed remote name \(remoteName)")
        let fileURL = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(remoteName)
        self.fileURLs.append(fileURL)
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
            var hasValue = true
            guard let result = task.result else {
                let error =  task.error as NSError?
                print("Should not produce error: \(error.debugDescription)")
                return nil
            }
            let blocks = result.blocks
            for block in blocks! {
                if let text = block.text {
                    textFromTextract = textFromTextract + text
                    if self.getTotalCost(text: text) {
                        if (hasValue) {
                            DispatchQueue.main.async {
                                print(text)
                                if text.contains("$") {
                                    self.selectedImages.append(self.image.image!)
                                    let tempText = text.replacingOccurrences(of: "$", with: "", options: NSString.CompareOptions.literal, range: nil)
                                    print(tempText)
                                    let floatTempText = Float(tempText)!
                                    self.costs.append(floatTempText)
                                    self.addToTotalCosts(cost: floatTempText)
                                    self.textractLabel.text = "Total: $\(self.totalCost)"
                                    print("the count of the array -->>> \(self.selectedImages.count)")
                                    self.uploadButton.setTitle("Send", for: UIControl.State.normal)
                                }
                                else {
                                    self.selectedImages.append(self.image.image!)
                                    let tempText = text
                                    let floatTempText = Float(tempText)!
                                    self.costs.append(floatTempText)
                                    self.addToTotalCosts(cost: floatTempText)
                                    self.textractLabel.text = "Total: $\(self.totalCost)"
                                    print("the count of the array -->>> \(self.selectedImages.count)")
                                    self.uploadButton.setTitle("Send", for: UIControl.State.normal)
                                }
                            }
                            hasValue = false
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
        AWSMobileClient.default().signOut()
        let loginViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
        view.window?.rootViewController = loginViewController
        view.window?.makeKeyAndVisible()
        print("Transition to login.....");
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
    
    
    //MARK: Manages the total
    private func addToTotalCosts(cost: Float) {
        self.totalCost += cost
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


//MARK: UIImage -------
extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 158, height: 234)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

