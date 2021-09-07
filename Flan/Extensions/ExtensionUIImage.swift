//
//  ExtensionUIImage.swift
//  Flan
//
//  Created by Вадим on 25.08.2021.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
