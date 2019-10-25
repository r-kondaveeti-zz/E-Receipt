//
//  ViewController.swift
//  E-Receipt
//
//  Created by Radithya Reddy on 10/23/19.
//  Copyright © 2019 Yash Tech. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var shadowLable: UILabel!
    @IBOutlet var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stylizeUI()
//        self.photoAuthorization()
        
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
    
    func photoAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            //do loading
            print("do loading")
            self.image.image = loadImage()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ status in
                switch status {
                case .authorized:
                    //do loading
                    DispatchQueue.main.async {
                         print("do loading")
                        self.image.image =  self.loadImage()
                    }
                case .notDetermined:
                    break
                case .restricted:
                    print("Photo Auth restricted or denied")
                case .denied:
                    print("Photo Auth restricted or denied")
                @unknown default:
                    print("default case")
                }
            })
        case .restricted:
            print("Photo Auth restricted or denied")
        case .denied:
            print("Photo Auth restricted or denied")
        @unknown default:
            print("default case")
        }
    }
    
    func loadImage() -> UIImage? {
        let manager = PHImageManager.default()
        let fetchResult = PHAsset.fetchAssets(with: .image, options: self.fetchOptions())
        var image: UIImage? = nil
        manager.requestImage(for: fetchResult.object(at: 0), targetSize: CGSize(width: 357, height: 265), contentMode: .aspectFill, options: requestOptions()) { img, err  in
         guard let img = img else { return }
             image = img
        }
        return image
    }
    
    //Will return configured PHFetchOptions class instance
    private func fetchOptions() -> PHFetchOptions {
       let fetchOptions = PHFetchOptions()
       fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
       return fetchOptions
    }
    
    private func requestOptions() -> PHImageRequestOptions {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }
}

