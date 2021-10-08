//
//  PresentationController.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit

class PresentationController: UIPresentationController {
    
    // MARK: - Props
    
    let blurEffectView: UIVisualEffectView!
    let blurEffectValue: CGFloat = 0.8
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    // MARK: - Initialization
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        var blurEffect = UIBlurEffect(style: .extraLight)
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        }
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Layout
  
    override var frameOfPresentedViewInContainerView: CGRect {
        var bottomIndent: CGFloat = 68
        let safeAreaBottomIdent = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        if safeAreaBottomIdent > 0 {
            bottomIndent += safeAreaBottomIdent
        }
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        return CGRect(origin: CGPoint(x: 0, y: height - (width + bottomIndent)),
                      size: CGSize(width: width, height: height))
    }

    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = self.blurEffectValue
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
  
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.alpha = 0
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
        })
    }
  
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.roundCorners([.topLeft, .topRight], radius: 20)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }

    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
