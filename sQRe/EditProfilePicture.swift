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
        // Do any additional setup after loading the view.
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.borderWidth = 5
        profileImage.layer.borderColor = UIColor.systemFill.cgColor
        
        let uid = (Auth.auth().currentUser?.uid)!
        let placeHolder = UIImage(named: "profile-placeholder")
        
         let storage = Storage.storage()
         let storageReference = storage.reference().child("profile_pictures/" + uid)
         storageReference.listAll { (result, error) in
           if error != nil {
                print("Error loading profile picture")
           }
             
           for item in result.items {
             // The items under storageReference.
             self.profileImage.sd_setImage(with: item, placeholderImage: placeHolder)
             print("Image successfully processed")
             break
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
        let alert = self.presentLoadingIndicator()
        if let profile_uid = Auth.auth().currentUser?.uid {
            let pathReference = storage.reference(withPath: "profile_pictures/" + profile_uid + "/" + String(Int.random(in: 1...100000000)))
            let uploadTask = pathReference.putData((self.profileImage.image?.sd_imageData())!, metadata: nil) { (metadata, error) in
                if let err = error {
                    print(err.localizedDescription)
                    alert.dismiss(animated: true) {
                        self.presentAlertWithHandler(withTitle: "Error Updating Profile Picture", message: "") { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
                pathReference.downloadURL { (url, error) in
                  guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    alert.dismiss(animated: true) {
                        print("Error: ", error?.localizedDescription)
                        self.presentAlertWithHandler(withTitle: "Error Updating Profile Picture", message: "") { _ in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    return
                  }
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    let oldURL = Auth.auth().currentUser?.photoURL
                    changeRequest?.photoURL = downloadURL
                    changeRequest?.commitChanges { (error) in
                        if let err = error {
                            //error occured
                            print(err.localizedDescription)
                            alert.dismiss(animated: true) {
                                self.presentAlertWithHandler(withTitle: "Error Updating Profile Picture", message: "") { _ in
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        } else {
                            print("Photo URL successfully updated")
                            //Delete old image
                            if oldURL != nil {
                                let oldRef = storage.reference(forURL: oldURL?.absoluteString ?? "")
                                // Delete the file
                                oldRef.delete { error in
                                  if let error = error {
                                    // Uh-oh, an error occurred!
                                    alert.dismiss(animated: true) {
                                        self.presentAlert(withTitle: "Error", message: "An error occurred. Please try again later.")
                                        print(error.localizedDescription)
                                        
                                    }
                                  } else {
                                    // File deleted successfully
                                    // You can also access to download URL after upload.
                                    print("Old image deleted successfully")
                                    
                                }
                                
                            }
                            }
                            alert.dismiss(animated: false) {
                                self.presentAlertWithHandler(withTitle: "Successfully Updated Profile Picture", message: "") { _ in
                                    self.navigationController?.popViewController(animated: true)
                                }
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





