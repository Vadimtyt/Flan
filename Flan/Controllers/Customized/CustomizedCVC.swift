//
//  CustomizedCVC.swift
//  Flan
//
//  Created by Вадим on 21.05.2021.
//

import UIKit

private let reuseIdentifier = "customizedCell"

class CustomizedCVC: UICollectionViewController {
    
    private let itemsPerRow: CGFloat = 2
    private let sectionPadding: CGFloat = 16
    
    private let popoverText = "Здесь находится лишь небольшая часть наших работ, но мы надеемся, что одна из них поможет вам найти идею для индивидуального заказа."
    private let popoverTextFontSize: CGFloat = 22
    
    @IBOutlet weak var infoBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.showsVerticalScrollIndicator = false
        configureNavigationBarLargeStyle()
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "\(CustomizedHeaderView.self)",
                                                                                   for: indexPath) as? CustomizedHeaderView
            else { fatalError("Invalid view type") }
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int.random(in: 30...40)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomizedCell
    
        cell.cakeImage.image = UIImage(named: "КексКвадрат")
        cell.backgroundColor = .red
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let storyboard = UIStoryboard(name: "CustomizedDetail", bundle: nil)
        
        guard let customizedDetailVC = storyboard.instantiateViewController(withIdentifier: "customizedDetail") as? CustomizedDetailVC else { return }
        customizedDetailVC.cake = Cake(number: indexPath.row + 1)
        
        customizedDetailVC.modalPresentationStyle = .custom
        customizedDetailVC.transitioningDelegate = self
        self.present(customizedDetailVC, animated: true, completion: nil)
    }
    
    @IBAction func infoBarButtonPressed(_ sender: UIBarButtonItem) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let popoverWidth = 290
        let popoverHeight = 175
        let popoverTextTopConstraint: CGFloat = 20
        
        let vc = InfoPopover(text: popoverText, fontSize: popoverTextFontSize, topConstraint: popoverTextTopConstraint)
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        
        popover.permittedArrowDirections = .up
        vc.preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
        
        popover.barButtonItem = sender
        popover.delegate = self
        present(vc, animated: true, completion:nil)
    }
}

extension CustomizedCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width - sectionPadding * (itemsPerRow + 1)) / itemsPerRow
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: sectionPadding, bottom: sectionPadding, right: sectionPadding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionPadding - 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionPadding - 1
    }
}

extension CustomizedCVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension CustomizedCVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
