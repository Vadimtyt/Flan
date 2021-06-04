//
//  CustomizedDetail.swift
//  Flan
//
//  Created by Вадим on 22.05.2021.
//

import UIKit
import Photos

class CustomizedDetailVC: UIViewController {
    
    var cake: Cake!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    @IBOutlet weak var cakeImage: UIImageView!
    @IBOutlet weak var cakeNumberLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        cakeImage.image = cake.image
        cakeNumberLabel.text = "#\(cake.number)"
        
        cakeImage.layer.cornerRadius = 10
        topView.layer.cornerRadius = 3
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
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
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        guard let image = cake.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
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
    
    func permissionDeniedAlert() {
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
