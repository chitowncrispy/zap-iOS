//
//  Zap
//
//  Created by Otto Suess on 27.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Lightning
import UIKit

extension UIStoryboard {
    static func instantiatePinViewController(authenticationViewModel: AuthenticationViewModel, didAuthenticate: @escaping () -> Void) -> PinViewController {
        let pinViewController = Storyboard.numericKeyPad.initial(viewController: PinViewController.self)
        pinViewController.authenticationViewModel = authenticationViewModel
        pinViewController.didAuthenticateCallback = didAuthenticate
        return pinViewController
    }
}

final class PinViewController: UIViewController {
    @IBOutlet private weak var pinView: PinView!
    @IBOutlet private weak var keyPadView: KeyPadPinView!
    @IBOutlet private weak var imageBottomConstraint: NSLayoutConstraint!
    
    fileprivate var authenticationViewModel: AuthenticationViewModel?
    fileprivate var didAuthenticateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.Zap.seaBlue
        
        setupKeyPad()
        
        let shouldPinInputBeHidden = BiometricAuthentication.type != .none
        setPinView(hidden: shouldPinInputBeHidden, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if BiometricAuthentication.type != .none {
            startBiometricAuthentication()
        }
    }
    
    private func setupKeyPad() {
        keyPadView.backgroundColor = UIColor.Zap.seaBlue
        keyPadView.textColor = .white
        keyPadView.authenticationViewModel = authenticationViewModel
        keyPadView.delegate = self
        keyPadView.pinView = pinView
    }
    
    func setPinView(hidden: Bool, animated: Bool) {
        let block = {
            let alpha: CGFloat = hidden ? 0 : 1
            self.pinView.alpha = alpha
            self.keyPadView.alpha = alpha
            self.imageBottomConstraint.priority = UILayoutPriority(rawValue: hidden ? 749 : 751)
        }
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                block()
                self.view.layoutIfNeeded()
            }
        } else {
            block()
        }
    }
}

extension PinViewController: KeyPadPinViewDelegate {
    func startBiometricAuthentication() {
        guard BiometricAuthentication.type != .none else { return }
        
        BiometricAuthentication.authenticate { [weak self] result in
            switch result {
            case .success:
                self?.authenticationViewModel?.didAuthenticate()
                self?.didAuthenticate()
            case .failure:
                self?.setPinView(hidden: false, animated: true)
            }
        }
    }
    
    func didAuthenticate() {
        didAuthenticateCallback?()
    }
}
