import UIKit
import NVActivityIndicatorView

class ResetViewController: LoginBaseViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendEmailSuccessImageView: UIImageView!
    @IBOutlet weak var tipLabel: UILabel!

    let user = UserManager.shared
    var submit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        var minY = submitButton.frame.minY
        if UIDevice.current.isX() {
            minY += 100
        }
        self.shownHeight = minY
    }

    // MARK: - Action
    @IBAction func back(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submit(_ sender: Any) {
        // If email is submitted before, back to sign in view
        if submit {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        guard let email = emailTextField.text else {
            return
        }
        if !email.isEmailAddress {
            showTip(R.string.localizable.reset_password_not_validate())
            return
        }
        
        finishEdit()
        startAnimating()
    
        user.reset(email: email) { (success, message) in
            self.stopAnimating()

            if (success) {
                // Set submit flag to true
                self.submit = true
                // Hide tip and email text field
                self.tipLabel.isHidden = true
                self.emailTextField.isHidden = true
                // Show success image.
                self.sendEmailSuccessImageView.isHidden = false
                self.submitButton.setTitle(R.string.localizable.back_to_login(), for: .normal)
                self.titleLabel.text = R.string.localizable.reset_password_check_email()
            } else {
                self.showTip(message!)
            }
        }
    }
    
}
