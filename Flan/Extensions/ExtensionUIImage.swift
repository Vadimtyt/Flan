//
//  ExtensionUIImage.swift
//  Flan
//
//  Created by Вадим on 25.08.2021.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let widthRatio  = size.width/self.size.width
        let heightRatio = size.height/self.size.height
        var updateSize = size
        if widthRatio > heightRatio {
            updateSize = CGSize(width: self.size.width * heightRatio, height: self.size.height * heightRatio)
        } else if heightRatio > widthRatio {
            updateSize = CGSize(width: self.size.width*widthRatio, height: self.size.height*widthRatio)
        }
        
        return UIGraphicsImageRenderer(size: updateSize).image { _ in
            draw(in: CGRect(origin: .zero, size: updateSize))
        }
    }
}
