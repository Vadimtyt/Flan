//
//  CustomizedDetail.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit
import Photos
import LinkPresentation

class CustomizedDetailVC: UIViewController {
    
    // MARK: - Props
    
    var cake: Cake = Cake()
    
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var cakeImage: UIImageView!
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cakeNumberLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPhoto()
        setupElements()
        
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    private func setPhoto() {
        downloadIndicator.isHidden = true
        var isSetPhoto = false
        cakeImage.image = nil
        
        let settingImageName = cake.imageName
        let imageSize = CGSize(width: cakeImage.bounds.width, height: cakeImage.bounds.height)
        cake.setImage(size: imageSize, type: .detailPhoto) { [settingImageName] image in
            DispatchQueue.main.async {
                guard settingImageName == (self.cake.imageName) && !isSetPhoto else { return }
                self.cakeImage.image = image
                isSetPhoto = true
                self.cakeImage.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    self.cakeImage.alpha = 1
                }

                self.downloadIndicator.stopAnimating()
                self.downloadIndicator.isHidden = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if !isSetPhoto {
                self?.downloadIndicator.isHidden = false
                self?.downloadIndicator.startAnimating()
            }
        }
    }
    
    // MARK: - @objc funcs
    
    @objc private func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y/2)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 || translation.y > 200 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    // MARK: - Funcs
    
    private func setupElements() {
        cakeImage.contentMode = .scaleAspectFill
        cakeNumberLabel.text = "#\(cake.number)"
        
        cakeImage.layer.cornerRadius = 20
        topView.layer.cornerRadius = 3
    }
    
    private func permissionDeniedAlert() {
        let alert = UIAlertController(title: Labels.CustomizedDetailVC.permissionDeniedAlertTitle,
                                      message: Labels.CustomizedDetailVC.permissionDeniedAlertMessage,
                                      preferredStyle: .alert)
        
        // OpenSettingsAction action
        let openSettingsAction = UIAlertAction(title: "Настройки", style: .default) {  _ in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
        
        // Close action
        let closelAction = UIAlertAction(title: "Закрыть", style: .cancel)
        alert.addAction(closelAction)
        alert.addAction(openSettingsAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - @IBActions
    
    @IBAction private func shareButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let image = cake.getImage(type: .detailPhoto)
        let activityVC = UIActivityViewController(activityItems: [image, self], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        activityVC.popoverPresentationController?.sourceView = sender
        
        defer { self.present(activityVC, animated: true, completion: nil) }
        
        if #available(iOS 14, *) {
            guard PHPhotoLibrary.authorizationStatus(for: .addOnly) != .notDetermined else { return }
            activityVC.completionWithItemsHandler = { [weak self] activity, success, _, _ in
                if activity == .saveToCameraRoll && !success { self?.permissionDeniedAlert() }
            }
        } else {
            activityVC.completionWithItemsHandler = { [weak self] activity, success, _, _ in
                if activity == .saveToCameraRoll && !success { self?.permissionDeniedAlert() }
            }
        }
        
    }
}

// MARK: - UIActivityItemSource

extension CustomizedDetailVC: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let image = cake.getImage(type: .detailPhoto)
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.imageProvider = imageProvider
        metadata.title = "Заказной торт из Флана " + (cakeNumberLabel.text ?? "")
        
        return metadata
    }
}
