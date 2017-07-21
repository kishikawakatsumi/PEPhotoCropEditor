//
//  PEPhotoCropEditorSnapshotTests.swift
//  PEPhotoCropEditorSnapshotTests
//
//  Created by WITOLD SKIBNIEWSKI on 21/07/2017.
//  Copyright © 2017 kishikawa katsumi. All rights reserved.
//

import FBSnapshotTestCase

class UIImage_RotationCropSnapshotTests: FBSnapshotTestCase {

    func test_nonTransformedImage() {
        let image = UIImage.defaultReferenceImage()
        let originalRect = CGRect(image: image)

        let croppedImage = image.rotatedImageWithtransform(.identity, croppedTo: originalRect)

        let resultView = UIImageView.make(image: croppedImage, frame: originalRect)
        FBSnapshotVerifyView(resultView)
    }

    func test_cropCenter() {
        let image = UIImage.defaultReferenceImage()
        let centerRect = CGRect(image: image).insetBy(dx: image.size.width/4, dy: image.size.height/4)

        let croppedImage = image.rotatedImageWithtransform(.identity, croppedTo: centerRect)

        let resultView = UIImageView.make(image: croppedImage, frame: centerRect)
        FBSnapshotVerifyView(resultView)
    }

    func test_rotateBy60DegreesAndCropCenter() {
        let image = UIImage.defaultReferenceImage()
        let centerRect = CGRect(image: image).insetBy(dx: image.size.width/4, dy: image.size.height/4)
        let rotation = CGAffineTransform.identity.rotated(by: degToRad(60))

        let croppedImage = image.rotatedImageWithtransform(rotation, croppedTo: centerRect)

        let resultView = UIImageView.make(image: croppedImage, frame: centerRect)
        FBSnapshotVerifyView(resultView)
    }

    func test_rotateBy5DegressAndCropTopLeft() {
        let image = UIImage.defaultReferenceImage()
        let topLeftRect = CGRect(image: image).applying(CGAffineTransform.identity.scaledBy(x: 0.25, y: 0.25))
        let rotation = CGAffineTransform.identity.rotated(by: degToRad(5))

        let croppedImage = image.rotatedImageWithtransform(rotation, croppedTo: topLeftRect)

        let resultView = UIImageView.make(image: croppedImage, frame: topLeftRect)
        FBSnapshotVerifyView(resultView)
    }
}
