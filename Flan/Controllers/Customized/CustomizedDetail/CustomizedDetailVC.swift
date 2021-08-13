//
//  CustomizedDetail.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit
import Photos

class CustomizedDetailVC: UIViewController {
    
    // MARK: - Props
    
    var cake: Cake = Cake()
    
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    
    // MARK: - @IBOutlets
    
    @IBOutlet weak var cakeImage: UIImageView!
    @IBOutlet weak var cakeNumberLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        setPhoto()
        cakeImage.contentMode = .scaleAspectFill
        cakeNumberLabel.text = "#\(cake.number)"
        
        cakeImage.layer.cornerRadius = 20
        topView.layer.cornerRadius = 3
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    private func setPhoto() {
        cake.setImage { image in
            self.cakeImage.image = image
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
    
    // MARK: - @IBActions
    
    @IBAction private func shareButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let image = cake.getImage()
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
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
    
    // MARK: - Funcs
    
    private func permissionDeniedAlert() {
        let title = "Запись изображения в галерею недоступна"
        let message = "Вероятно, вы запретили приложению добавлять изображения в ваши фото. Если вы сделали это случайно или передумали, вы можете перейти в настройки приложения и разрешите доступ к фото."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
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
}
