//
//  EditProfilePicture.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 6/15/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase
class EditProfilePicture: UIViewController {
    @IBOutlet weak var profileImage: UIImageView!
    var imagePicker : ImagePicker! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Auth.auth().currentUser?.photoURL)
        // Do any additional setup after loading the view.
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.borderWidth = 5
        profileImage.layer.borderColor = UIColor.systemFill.cgColor
        
        let url = Auth.auth().currentUser?.photoURL
        let placeHolder = UIImage(named: "profile-placeholder")
        self.profileImage.sd_setImage(with: url, placeholderImage: placeHolder, options: .refreshCached) { (image, error, cacheType, url) in
            if error != nil {
                self.profileImage.image = placeHolder
            } else {
                self.profileImage.image = image
            }

        }
        
        
        profileImage.isUserInteractionEnabled = true
        self.imagePicker = ImagePicker(presentationController: self, delegate: self, originalImage: (self.profileImage.image ?? placeHolder)!)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(tapGestureRecognizer:)))
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func changeImage(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.imagePicker.present(from: profileImage)
        // Your action
    }
    
    @IBAction func save(_ sender: Any) {
        let storage = Storage.storage()
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
        if let profile_uid = Auth.auth().currentUser?.uid {
            let pathReference = storage.reference(withPath: "profile_pictures/" + profile_uid + "/" + String(Int.random(in: 1...100000000)))
            let uploadTask = pathReference.putData((self.profileImage.image?.sd_imageData())!, metadata: nil) { (metadata, error) in
              /*guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                    return
                }*/
                
                pathReference.downloadURL { (url, error) in
                  guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    alert.dismiss(animated: true, completion: nil)
                    print("Error: ", error?.localizedDescription)
                    return
                  }
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    let oldURL = Auth.auth().currentUser?.photoURL
                    changeRequest?.photoURL = downloadURL
                    changeRequest?.commitChanges { (error) in
                        if let err = error {
                            //error occured
                            print(err.localizedDescription)
                            return
                        } else {
                            print("Photo URL successfully updated")
                            //Delete old image
                            if oldURL != nil {
                                let oldRef = storage.reference(forURL: oldURL?.absoluteString ?? "")
                                // Delete the file
                                oldRef.delete { error in
                                  if let error = error {
                                    // Uh-oh, an error occurred!
                                    print(error.localizedDescription)
                                    alert.dismiss(animated: true, completion: nil)
                                  } else {
                                    // File deleted successfully
                                    // You can also access to download URL after upload.
                                    print("Old image deleted successfully")
                                    
                                }
                                
                            }
                            } else {
                                alert.dismiss(animated: true, completion: nil)
                            }
                            alert.dismiss(animated: false) {
                                  let success = UIAlertController(title: "Successfully Uploaded", message: "", preferredStyle: .alert)
                                  //let checkmark = UIImage.checkmark
                                  let ok = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                                      self.dismiss(animated: true, completion: nil)
                                  })
                                  //let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
                                  //imageView.image = checkmark
                                  success.addAction(ok)
                                  //success.view.addSubview(imageView)
                                  self.present(success, animated: true, completion: nil)
                            }
                    }
                    
                }
                
              
                }
            }
        } else {
            //Error check
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

public class ImagePicker: NSObject {
    private var originalImage: UIImage
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate, originalImage: UIImage) {
        self.pickerController = UIImagePickerController()
        self.originalImage = originalImage
        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.pickerController(self.pickerController, didSelect: self.originalImage)
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.originalImage = image
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}



extension EditProfilePicture: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.profileImage.image = image
    }
}





