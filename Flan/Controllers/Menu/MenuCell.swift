//
//  MenuCell.swift
//  Flan
//
//  Created by Вадим on 02.04.2021.
//

import UIKit

// MARK: - Protocol

protocol UpdatingMenuCellDelegate: AnyObject {
    func updateListVCBadge()
    func updateFavorites()
}

class MenuCell: UITableViewCell {
    
    // MARK: - Props
    
    weak var updateCellDelegate: UpdatingMenuCellDelegate?
    
    static let reuseId = "MenuCell"
    private var item: MenuItem = MenuItem()
    
    // MARK: - @IBOutlets
    @IBOutlet private weak var backgoundSubwiew: UIView!
    @IBOutlet private weak var containerImageView: UIView!
    @IBOutlet private weak var imageItemView: UIImageView!
    @IBOutlet private weak var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var secondPriceLabel: UILabel!
    @IBOutlet private weak var measurmentLabel: UILabel!
    @IBOutlet private weak var secondMeasurmentLabel: UILabel!
    
    @IBOutlet private weak var removeButton: UIButton!
    @IBOutlet private weak var countItemLabel: UILabel!
    @IBOutlet private weak var addButton: UIButton!
    
    @IBOutlet private weak var priceLabelWidth: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapPriceLabel = UITapGestureRecognizer(target: self, action: #selector(MenuCell.tapPriceLabel))
        priceLabel.isUserInteractionEnabled = true
        priceLabel.addGestureRecognizer(tapPriceLabel)
        
        let tapSecondPriceLabel = UITapGestureRecognizer(target: self, action: #selector(MenuCell.tapSecondPriceLabel))
        secondPriceLabel.isUserInteractionEnabled = true
        secondPriceLabel.addGestureRecognizer(tapSecondPriceLabel)
    }
    
    override func prepareForReuse() {
        resetAll()
    }
    
    override func layoutSubviews() {
        setupViews()
        setupElements()
    }
    
    // MARK: - Funcs
    
    func configureCell(with item: MenuItem) {
        self.item = item
        setPhoto()
    }
    
    private func setupViews() {
        nameLabel.adjustsFontSizeToFitWidth = true
        if UIScreen.main.bounds.width <= 320 {
            priceLabelWidth.constant = 82
        }
        countItemLabel.layer.borderColor = UIColor.yellow.cgColor
        countItemLabel.layer.borderWidth = 2.5
        countItemLabel.layer.cornerRadius = 16
        priceLabel.layer.borderColor =  UIColor.yellow.cgColor
        priceLabel.layer.borderWidth = 2.5
        priceLabel.layer.cornerRadius = 16
        priceLabel.roundCorners(.allCorners, radius: 16)
        secondPriceLabel.layer.borderColor =  UIColor.yellow.cgColor
        secondPriceLabel.layer.borderWidth = 2.5
        secondPriceLabel.layer.cornerRadius = 16
        backgoundSubwiew.layer.cornerRadius = 20
        backgoundSubwiew.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        backgoundSubwiew.applyShadow()
        backgoundSubwiew.layer.shadowOpacity = 0.3
        backgoundSubwiew.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        containerImageView.layer.shadowPath = UIBezierPath(roundedRect: containerImageView.bounds,
                                                           byRoundingCorners: [.bottomRight, .topRight],
                                                           cornerRadii: CGSize(width: 20, height: 20)).cgPath
        containerImageView.layer.shouldRasterize = true
        containerImageView.layer.rasterizationScale = UIScreen.main.scale
        imageItemView.layer.cornerRadius = 20
        imageItemView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

        removeButton.layer.cornerRadius = 16
        addButton.layer.cornerRadius = 16
    }
    
    private func setupElements() {
        secondPriceLabel.isHidden = true
        secondMeasurmentLabel.isHidden = true
        
        selectionStyle = .none
        
        if item.isFavorite {
            favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
        } else { favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal) }
        
        countItemLabel.text = "\(item.count)"
        
        if item.count == 0 {
            removeButton.isEnabled = false
        } else if item.count == 99 {
            addButton.isEnabled = false
        }
        
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        
        priceLabel.text = "\(item.prices[0])₽"
        measurmentLabel.text = item.measurements[0]
        updatePriceLabels()
    }
    
    private func setPhoto() {
        downloadIndicator.isHidden = true
        var isSetPhoto = false
        imageItemView.image = nil
        
        let settingImageName = item.imageName
        
        let imageSize = getImageSize()
        item.setImage(size: imageSize, type: .cellPhoto) { [settingImageName] image, isNeedAnimation  in
            DispatchQueue.main.async {
                guard settingImageName == (self.item.imageName) && !isSetPhoto else { return }
                self.imageItemView.image = image
                isSetPhoto = true
                
                if isNeedAnimation {
                    self.imageItemView.alpha = 0
                    UIView.animate(withDuration: 0.2) {
                        self.imageItemView.alpha = 1
                    }
                }
                if image != ImageModel.standartImage {
                    self.containerImageView.applyShadow()
                    self.containerImageView.layer.shadowOpacity = 0.8
                    self.containerImageView.layer.shadowOffset = CGSize(width: 2, height: 0)
                    self.containerImageView.layer.cornerRadius = self.imageItemView.layer.cornerRadius
                    self.containerImageView.layer.maskedCorners = self.imageItemView.layer.maskedCorners
                }

                self.downloadIndicator.stopAnimating()
                self.downloadIndicator.isHidden = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if !isSetPhoto {
                self?.downloadIndicator.isHidden = false
                self?.downloadIndicator.startAnimating()
            } else {
                self?.downloadIndicator.stopAnimating()
                self?.downloadIndicator.isHidden = true
            }
        }
    }
    
    private func getImageSize() -> CGSize {
        let imageAspectRatio = CGFloat(0.75)
        var imageSize = CGSize(width: imageItemView.bounds.height / imageAspectRatio, height: imageItemView.bounds.height)
        
        let scale = UIScreen.main.nativeScale
        imageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        
        return imageSize
    }
    
    private func updatePriceLabels() {
        guard item.prices.count > 1 else { return }
        if item.count == 0 {
            priceLabel.text = "\(item.prices[0])₽"
            measurmentLabel.text = item.measurements[0]
            secondPriceLabel.text = "\(item.prices[1])₽"
            secondMeasurmentLabel.text = item.measurements[1]
            secondPriceLabel.isHidden = false
            secondMeasurmentLabel.isHidden = false
            removeButton.isHidden = true
            countItemLabel.isHidden = true
            addButton.isHidden = true
        } else if item.count > 0 {
            priceLabel.text = "\(item.prices[item.selectedMeasurment])₽"
            measurmentLabel.text = item.measurements[item.selectedMeasurment]
            secondPriceLabel.isHidden = true
            secondMeasurmentLabel.isHidden = true
            removeButton.isHidden = false
            countItemLabel.isHidden = false
            addButton.isHidden = false
        }
    }
    
    private func resetAll() {
        imageItemView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
        favoriteButton.imageView?.image = nil
        priceLabel.text = nil
        secondPriceLabel.text = nil
        measurmentLabel.text = nil
        secondMeasurmentLabel.text = nil
        
        containerImageView.layer.masksToBounds = true
        downloadIndicator.isHidden = true
        descriptionLabel.isHidden = false
        removeButton.isHidden = false
        countItemLabel.isHidden = false
        addButton.isHidden = false
        secondPriceLabel.isHidden = false
        
        removeButton.isEnabled = true
        addButton.isEnabled = true
    }
    
    // MARK: - @objc funcs
    
    @objc private func tapPriceLabel(sender:UITapGestureRecognizer) {
        if item.count == 0 {
            item.selectedMeasurment = 0
        }
        secondPriceLabel.isHidden = true
        secondMeasurmentLabel.isHidden = true
        
        guard addButton.isEnabled else { return }
        addButtonPressed(addButton)
        
        priceLabel.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.priceLabel.backgroundColor = nil
        }
    }
    
    @objc private func tapSecondPriceLabel(sender:UITapGestureRecognizer) {
        if item.count == 0 {
            item.selectedMeasurment = 1
        }
        secondPriceLabel.isHidden = true
        secondMeasurmentLabel.isHidden = true
        
        guard addButton.isEnabled else { return }
        addButtonPressed(addButton)
        
        priceLabel.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.priceLabel.backgroundColor = nil
        }
    }
    
    
    // MARK: - @IBActions
    
    @IBAction private func removeButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        DataManager.shared.setNewCountFor(item: item, count: item.count - 1)
        countItemLabel.text = "\(self.item.count)"
        let itemsCount = self.item.count
        
        if itemsCount == 0 {
            removeButton.isEnabled = false
        } else if itemsCount == 98{
            addButton.isEnabled = true
        }
        
        removeButton.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.removeButton.backgroundColor = nil
        }
        
        updatePriceLabels()
        updateCellDelegate?.updateListVCBadge()
    }
    
    @IBAction private func addButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        
        DataManager.shared.setNewCountFor(item: item, count: item.count + 1)
        countItemLabel.text = "\(self.item.count)"
        let itemsCount = self.item.count
        
        if itemsCount == 1 {
            removeButton.isEnabled = true
        } else if itemsCount >= 99 {
            addButton.isEnabled = false
        }
        
        addButton.backgroundColor = .yellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.addButton.backgroundColor = nil
        }
        
        updatePriceLabels()
        updateCellDelegate?.updateListVCBadge()
    }
    
    @IBAction private func favoriteButtonPressed(_ sender: UIButton) {
        TapticFeedback.shared.tapticFeedback(.light)
        animatePressingView(sender)

        item.isFavorite = !item.isFavorite

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if self?.item.isFavorite == true {
                self?.favoriteButton.setImage(UIImage(named: "heart.fill.png"), for: .normal)
            } else if self?.item.isFavorite == false {
                self?.favoriteButton.setImage(UIImage(named: "heart.png"), for: .normal)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.updateCellDelegate?.updateFavorites()
            }
        }
    }
}
