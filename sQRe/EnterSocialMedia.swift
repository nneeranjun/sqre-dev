//
//  EnterSocialMedia.swift
//  sQRe
//
//  Created by Nilay Neeranjun on 4/10/20.
//  Copyright © 2020 Nilay Neeranjun. All rights reserved.
//

import UIKit
import Firebase

class EnterSocialMedia: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    
   
    let allMedias = ["Snapchat", "Instagram", "Phone Number", "Twitter", "Linkedin", "Facebook", "Venmo"]
    /*let allColors = [UIColor.init(hexaString: "#FFFC00"), UIColor.init(hexaString: "#DD2A7B"), UIColor.init(hexaString: "#F07249"), UIColor.init(hexaString: "#55ACEE"), UIColor.init(hexaString: "#006192"), UIColor.init(hexaString: "#1778F2"), UIColor.init(hexaString: "#3D95CE")]*/
    //@IBOutlet weak var fbButton: UIButton!
    var mediaData : Dictionary<String, String> = [:]
    var imagePicker : ImagePicker! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                for val in self.allMedias {
                    self.mediaData[val] = (document.data()![val] as! String)
                    print(document.data()![val] as! String)
                }
                let storage = Storage.storage()
                if let profile_uid = Auth.auth().currentUser?.uid {
                    let pathReference = storage.reference(withPath: "profile_pictures/" + profile_uid)
                    let placeHolder = UIImage(named: "profile-placeholder")
                    self.profileImage.sd_setImage(with: pathReference, placeholderImage: placeHolder)
                } else {
                    //Error check
                }
                
                
                
            } else {
                for media in self.allMedias {
                    self.mediaData[media] = ""
                }
            }
            self.tableView.reloadData()
            self.tableView.tableFooterView = UIView()
        }
        
        profileImage.isUserInteractionEnabled = true
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(tapGestureRecognizer:)))
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func changeImage(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.imagePicker.present(from: profileImage)
        // Your action
    }
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMedias.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(70)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EnterInfoCell", for: indexPath) as! EnterInfoCell
        cell.mediaLogo.image = UIImage(named: allMedias[indexPath.row])
        if mediaData[allMedias[indexPath.row]] == "" {
            if allMedias[indexPath.row] == "Linkedin" || allMedias[indexPath.row] == "Facebook" {
                cell.mediaTag.text = "Enter Your " + allMedias[indexPath.row] + " URL"
            } else {
                cell.mediaTag.text = "Enter Your " + allMedias[indexPath.row]
            }
            cell.accessoryType = .none
        } else {
            cell.mediaTag.text = mediaData[allMedias[indexPath.row]]
            cell.accessoryType = .checkmark
        }
    
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .blue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var userIdTextField: UITextField?
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! EnterInfoCell
        let alert = UIAlertController(title: allMedias[indexPath.row], message: "Type Below", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            if let userInput = userIdTextField!.text {
                //Do checking here
                if userInput != "" {
                    if self.verifyInput(input: userInput, media: self.allMedias[indexPath.row]) {
                        cell.mediaTag.text = userInput
                        self.mediaData[self.allMedias[indexPath.row]] = userInput
                        cell.accessoryType = .checkmark
                    } else {
                        let invalidation = "Invalid " + self.allMedias[indexPath.row] + ". Please try again."
                        /*let attributedString = NSAttributedString(string: invalidation, attributes: [
                            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                            NSAttributedString.Key.foregroundColor : UIColor.red
                        ])
                        alert.setValue(attributedString, forKey: "attributedMessage")*/
                        alert.message = invalidation
                        userIdTextField?.text = ""
                        cell.accessoryType = .none
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (textField) -> Void in
            userIdTextField = textField
            userIdTextField?.placeholder = self.allMedias[indexPath.row]
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func save(_ sender: Any) {
        var hasEmpty = false
        for val in mediaData.values {
            if val == "" {
                hasEmpty = true
                break
            }
        }
        let storage = Storage.storage()
        let storageRef = storage.reference()
        if hasEmpty {
            let alert = UIAlertController(title: "Are You Sure You Want to Continue?", message: "Leaving a media blank means you will not be able to share it", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                let loading = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = .medium
                loadingIndicator.startAnimating();
                loading.view.addSubview(loadingIndicator)
                self.present(loading, animated: true, completion: nil)
                
                let db = Firestore.firestore()
                db.collection("users").document((Auth.auth().currentUser?.uid)!).setData([
                    "Snapchat": self.mediaData["Snapchat"] ?? "",
                    "Instagram": self.mediaData["Instagram"] ?? "",
                    "Twitter": self.mediaData["Twitter"] ?? "",
                    "Linkedin": self.mediaData["Linkedin"] ?? "",
                    "Venmo": self.mediaData["Venmo"] ?? "",
                    "Facebook": self.mediaData["Facebook"] ?? "",
                    "Phone Number": self.mediaData["Phone Number"] ?? "",
                    "Score": 0
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        loading.dismiss(animated: false, completion: nil)
                        return
                    } else {
                        let profileRef = storageRef.child("profile_pictures/" + Auth.auth().currentUser!.uid)
                        
                        if let data = self.profileImage.image?.jpegData(compressionQuality: 1) {
                            let uploadTask = profileRef.putData(data, metadata: nil) { (metadata, error) in
                              guard let metadata = metadata else {
                                // Uh-oh, an error occurred!
                                loading.dismiss(animated: true, completion: nil)
                                return
                              }
                              // Metadata contains file metadata such as size, content-type.
                              // You can also access to download URL after upload.
                                
                            }
                            uploadTask.observe(.success) {snapshot in
                                print("Successfully upload image")
                                loading.dismiss(animated: true, completion: nil)
                            }
                            uploadTask.observe(.failure) {snapshot in
                                print("Could not upload image")
                                loading.dismiss(animated: true, completion: nil)
                                return
                            }
                        } else {
                            //Error checking
                            return
                        }
                    }
                }
                

                // Upload the file to the path "images/rivers.jpg"
                
            })
            let cancel = UIAlertAction(title: "Go Back", style: .cancel, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.addAction(yes)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            let loading = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating();
            loading.view.addSubview(loadingIndicator)
            self.present(loading, animated: true, completion: nil)
            
            let db = Firestore.firestore()
            db.collection("users").document((Auth.auth().currentUser?.uid)!).setData([
                "Snapchat": self.mediaData["Snapchat"] ?? "",
                "Instagram": self.mediaData["Instagram"] ?? "",
                "Twitter": self.mediaData["Twitter"] ?? "",
                "Linkedin": self.mediaData["Linkedin"] ?? "",
                "Venmo": self.mediaData["Venmo"] ?? "",
                "Facebook": self.mediaData["Facebook"] ?? "",
                "Phone Number": self.mediaData["Phone Number"] ?? "",
                "Score": 0
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    loading.dismiss(animated: false, completion: nil)
                    return
                } else {
                    let profileRef = storageRef.child("profile_pictures/" + Auth.auth().currentUser!.uid)
                    
                    if let data = self.profileImage.image?.jpegData(compressionQuality: 1) {
                        let uploadTask = profileRef.putData(data, metadata: nil) { (metadata, error) in
                          guard let metadata = metadata else {
                            // Uh-oh, an error occurred!
                            loading.dismiss(animated: true, completion: nil)
                            return
                          }
                          // Metadata contains file metadata such as size, content-type.
                          // You can also access to download URL after upload.
                            
                        }
                        uploadTask.observe(.success) {snapshot in
                            print("Successfully upload image")
                            loading.dismiss(animated: true) {
                                self.performSegue(withIdentifier: "AfterEnteringSocialSegue", sender: nil)
                            }
                        }
                        uploadTask.observe(.failure) {snapshot in
                            print("Could not upload image")
                            loading.dismiss(animated: true, completion: nil)
                            return
                        }
                    } else {
                        //Error checking
                        return
                    }
                }
        }
        
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
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    func isPhoneNumber(phoneNumber: String) -> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: phoneNumber, options: [], range: NSRange(location: 0, length: phoneNumber.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == phoneNumber.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func verifyInput(input: String, media: String) -> Bool {
        if media == "Linkedin" || media == "Facebook" {
            return verifyUrl(urlString: input)
        } else if media == "Phone Number" {
            return isPhoneNumber(phoneNumber: input)
        } else {
            return !input.contains(" ")
        }
    }
    
    
    

}
extension UIColor {
    convenience init(hexaString: String, alpha: CGFloat = 1) {
        let chars = Array(hexaString.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]),nil,16))/255,
                  green: .init(strtoul(String(chars[2...3]),nil,16))/255,
                  blue:  .init(strtoul(String(chars[4...5]),nil,16))/255,
                  alpha: alpha)}
}

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

public class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

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

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

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
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}

extension EnterSocialMedia: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.profileImage.image = image
    }
}





