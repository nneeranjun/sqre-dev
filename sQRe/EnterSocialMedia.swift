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
    
    var selectedMedia: String!
    
    let allMedias = ["Name", "Snapchat", "Instagram", "Phone Number", "Twitter", "Linkedin", "Facebook", "Venmo"]
    /*let allColors = [UIColor.init(hexaString: "#FFFC00"), UIColor.init(hexaString: "#DD2A7B"), UIColor.init(hexaString: "#F07249"), UIColor.init(hexaString: "#55ACEE"), UIColor.init(hexaString: "#006192"), UIColor.init(hexaString: "#1778F2"), UIColor.init(hexaString: "#3D95CE")]*/
    //@IBOutlet weak var fbButton: UIButton!
    var mediaData : Dictionary<String, String> = [:]
    var imagePicker : ImagePicker! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView()
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.layer.borderWidth = 5
        profileImage.layer.borderColor = UIColor.systemFill.cgColor
        
        print(Auth.auth().currentUser?.displayName)
        
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        .addSnapshotListener { documentSnapshot, error in
          guard let document = documentSnapshot else {
            print("Error fetching document: \(error!)")
            return
          }
          guard let data = document.data() else {
            print("Document data was empty.")
            return
          }
            for val in self.allMedias {
                if val != "Name" {
                    self.mediaData[val] = data[val] as? String
                }
            }
            let storage = Storage.storage()
            if let profile_uid = Auth.auth().currentUser?.uid {
                let pathReference = storage.reference(withPath: "profile_pictures/" + profile_uid)
                let placeHolder = UIImage(named: "profile-placeholder")
                self.profileImage.sd_setImage(with: pathReference, placeholderImage: placeHolder)
            } else {
                //Error check
            }
            self.tableView.reloadData()
        }
        
        profileImage.isUserInteractionEnabled = true
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(tapGestureRecognizer:)))
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mediaData["Name"] = Auth.auth().currentUser?.displayName
        self.tableView.reloadData()
    }
    
    
    @objc func changeImage(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.imagePicker.present(from: profileImage)
        // Your action
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        performSegue(withIdentifier: "settingsSegue", sender: self)
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
        } else {
            cell.mediaTag.text = mediaData[allMedias[indexPath.row]]
        }
    
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditProfile", sender: self)
        self.tableView.deselectRow(at: indexPath, animated: false)
    }
    

    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is EditProfile {
            let dest = segue.destination as? EditProfile
            let selectedMedia = allMedias[self.tableView.indexPathForSelectedRow?.row ?? 0]
            dest?.media = selectedMedia
            dest?.value = mediaData[selectedMedia]
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





