//
//  UIImage+Helpers.swift
//  PEPhotoCropEditor
//
//  Created by WITOLD SKIBNIEWSKI on 21/07/2017.
//  Copyright © 2017 kishikawa katsumi. All rights reserved.
//

import UIKit

private class BundleDummy {}

extension Bundle {
    static let test: Bundle = .init(for: BundleDummy.self)
}

extension UIImage {
    static func defaultReferenceImage() -> UIImage {
        return UIImage(named: "default_reference_image", in: .test, compatibleWith: nil)!
    }
}
