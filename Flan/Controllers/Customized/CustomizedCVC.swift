//
//  CustomizedCVC.swift
//  Flan
//
//  Created by Вадим on 21.05.2021.
//

import UIKit

private let reuseIdentifier = "customizedCell"

class CustomizedCVC: UICollectionViewController {
    
    // MARK: - Props
    private var cakes: [Cake] { DataManager.shared.getCakes() }
    
    private var itemsPerRow: CGFloat = 2
    private let sectionPadding: CGFloat = 12
    
    private let popoverText = "Здесь находится лишь небольшая часть наших работ, но мы надеемся, что одна из них поможет вам найти идею для индивидуального заказа."
    private let popoverTextFontSize: CGFloat = 20
    
    // MARK: - @IBOutlets
    
    @IBOutlet private weak var infoBarButton: UIBarButtonItem!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            itemsPerRow = 3
        }
        configureNavigationBarLargeStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateBackgound()
    }
    
    
    // MARK: - Funcs
    
    private func updateBackgound() {
        if cakes.isEmpty {
            collectionView.setEmptyView(title: Labels.CustomizedCVC.emptyViewTitle,
                                        message: Labels.CustomizedCVC.emptyViewMessage,
                                        messageImage: UIImage(named: "cloudError.png")!)
            collectionView.isScrollEnabled = false
        } else {
            collectionView.restore()
            collectionView.isScrollEnabled = true
        }
    }

    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: UIScreen.main.bounds.width, height: 68)
        } else { return CGSize(width: UIScreen.main.bounds.width, height: 110)}
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "\(CustomizedHeaderView.self)",
                                                                                   for: indexPath) as? CustomizedHeaderView
            else { fatalError("Invalid view type") }
            headerView.superVC = self
            return headerView
        default:
            assert(false, "Invalid element type")
        }
        return UICollectionReusableView()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cakes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CustomizedCell
    
        let cake = cakes[indexPath.row]
        cell.configureWith(cake: cake)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let storyboard = UIStoryboard(name: "CustomizedDetail", bundle: nil)
        
        guard let customizedDetailVC = storyboard.instantiateViewController(withIdentifier: "customizedDetail") as? CustomizedDetailVC else { return }
        customizedDetailVC.cake = cakes[indexPath.row]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            customizedDetailVC.modalPresentationStyle = .formSheet
        } else { customizedDetailVC.modalPresentationStyle = .custom }
        customizedDetailVC.transitioningDelegate = self
        self.present(customizedDetailVC, animated: true, completion: nil)
    }
    
    // MARK: - @IBActions
    
    @IBAction private func infoBarButtonPressed(_ sender: UIBarButtonItem) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        let popoverWidth = 288
        let popoverHeight = 128
        
        let vc = InfoPopover(text: popoverText, fontSize: popoverTextFontSize)
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
    
    // MARK: - Collection view delegate flow layout
    
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
