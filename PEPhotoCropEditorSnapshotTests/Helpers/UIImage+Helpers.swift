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

    static let defaultReferenceImageName: String = "default_reference_image"

    static func defaultReferenceImage() -> UIImage {
        return UIImage(named: UIImage.defaultReferenceImageName, in: .test, compatibleWith: nil)!
    }

    convenience init(testImageWithOrientation orientation: UIImageOrientation) {
        let filename = "Portrait_\(orientation.exiffOrientation).jpg"
        self.init(named: filename, in: .test, compatibleWith: nil)!
    }
}

fileprivate extension UIImageOrientation {
    /// Converts `UIImageOrientation` to corresponding EXIF orientation value.
    /// For reference see [CIImage-UIImage-Orientation-Fix](https://github.com/FlexMonkey/CIImage-UIImage-Orientation-Fix#ciimage-uiimage-orientation-fix).
    var exiffOrientation: Int {
        switch self {
        case .up:   // 0
            return 1
        case .down: // 1
            return 3
        case .left: // 2
            return 8
        case .right:  // 3
            return 6
        case .upMirrored:  // 4
            return 2
        case .downMirrored:  // 5
            return 4
        case .leftMirrored:  // 6
            return 5
        case .rightMirrored: // 7
            return 7
        }
    }
}
