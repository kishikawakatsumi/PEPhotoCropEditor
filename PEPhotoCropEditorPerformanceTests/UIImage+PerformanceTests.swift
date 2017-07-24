//
//  PEPhotoCropEditorPerformanceTests.swift
//  PEPhotoCropEditorPerformanceTests
//
//  Created by WITOLD SKIBNIEWSKI on 21/07/2017.
//  Copyright © 2017 kishikawa katsumi. All rights reserved.
//

import XCTest
import ImageIO

extension Bundle {
    static let performanceTest: Bundle = Bundle(for: PEPhotoCropEditorPerformanceTests.self)
}

extension UIImage {

    static func decodedDefaultReferenceImage() -> UIImage {
        guard let resourceURL = Bundle.performanceTest.url(forResource: UIImage.defaultReferenceImageName, withExtension: "png") else {
            fatalError()
        }

        let data = try! Data(contentsOf: resourceURL)
        let dataSource = CGImageSourceCreateWithData(data as CFData, nil)
        let options: [NSObject: Any] = [kCGImageSourceShouldCacheImmediately: true]
        let cgImage = CGImageSourceCreateImageAtIndex(dataSource!, 0, options as CFDictionary)
        return UIImage(cgImage: cgImage!)
    }
}

class PEPhotoCropEditorPerformanceTests: XCTestCase {

    func test_noTransformation() {
        let image = UIImage.decodedDefaultReferenceImage()
        let originalRect = CGRect(image: image)

        measure {
            _ = image.rotatedImageWithtransform(.identity, croppedTo: originalRect)
        }
    }

    func test_cropWithQuarterInset() {
        let image = UIImage.decodedDefaultReferenceImage()
        let insetRect = CGRect(image: image).insetBy(dx: image.size.width/4, dy: image.size.height/4)

        measure {
            _ = image.rotatedImageWithtransform(.identity, croppedTo: insetRect)
        }
    }

    func test_rotateBy60DegreesAndCropWithQuarterInset() {
        let image = UIImage.decodedDefaultReferenceImage()
        let insetRect = CGRect(image: image).insetBy(dx: image.size.width/4, dy: image.size.height/4)
        let rotation = CGAffineTransform.identity.rotated(by: degToRad(60))

        measure {
            _ = image.rotatedImageWithtransform(rotation, croppedTo: insetRect)
        }
    }
}
