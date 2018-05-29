import UIKit
import Alamofire

class AvatarViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet var uploadButton: UIButton!
    
    let user = UserManager.shared
    let imagePickerController = UIImagePickerController()
    var timer: Timer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setCustomBack()
        
        if user.login {
            avatarImageView.kf.setImage(with: user.avatarURL)
        }
        
        imagePickerController.delegate = self
        imagePickerController.navigationBar.barTintColor = Color.main
        imagePickerController.navigationBar.tintColor = UIColor.white
        imagePickerController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.white
        ]
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        avatarImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        
        uploadButton.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
 
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target      : self,
            selector    : #selector(updateUploadProgress),
            userInfo    : nil,
            repeats     : true)
        
        user.uploadAvatar(avatarImageView.image!) { (success) in
            self.uploadButton.isEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.timer?.invalidate()
            self.timer = nil
            if success {
                self.uploadButton.setTitle(R.string.localizable.upload_profile_photo(), for: .normal)
            }
        }
        
    }
    
    // MARK: - Action
    @IBAction func uploadAvatar(_ sender: Any) {
        let alertController = UIAlertController(title: R.string.localizable.upload_profile_photo(),
                                                message: R.string.localizable.photo_tip(),
                                                preferredStyle: .actionSheet)
        alertController.view.tintColor = Color.main
        let takePhoto = UIAlertAction(title: R.string.localizable.photo_take(), style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.cameraCaptureMode = .photo
                self.imagePickerController.cameraDevice = .front
                self.imagePickerController.allowsEditing = true
            }
            self.present(self.imagePickerController, animated: true)
        }
        let choosePhoto = UIAlertAction(title: R.string.localizable.photo_choose(), style: .default) { action in
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true)
        }
        let cancel = UIAlertAction(title: R.string.localizable.cancel_name(), style: .cancel)
        alertController.addAction(takePhoto)
        alertController.addAction(choosePhoto)
        alertController.addAction(cancel)
        alertController.popoverPresentationController?.sourceView = uploadButton;
        alertController.popoverPresentationController?.sourceRect = uploadButton.bounds;
        self.present(alertController, animated: true)
    }
    
    // MARK: - Service
    func updateUploadProgress() {
        let progress = String(format: "%.2f", user.avatarUploadingProgress * 100)
        uploadButton.setTitle(R.string.localizable.upload_progress() + progress + "%", for: .normal)
    }
    
}
