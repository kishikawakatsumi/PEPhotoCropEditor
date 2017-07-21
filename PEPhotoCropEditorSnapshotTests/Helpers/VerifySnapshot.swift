//
//  SnapshotVerification.swift
//  PEPhotoCropEditor
//
//  Created by WITOLD SKIBNIEWSKI on 21/07/2017.
//  Copyright © 2017 kishikawa katsumi. All rights reserved.
//

import FBSnapshotTestCase

extension FBSnapshotTestCase {

    func verifySnapshot(image: UIImage, transform: CGAffineTransform, cropRect: CGRect, file: StaticString = #file, line: UInt = #line) {
        let croppedImage = image.rotatedImageWithtransform(transform, croppedTo: cropRect)
        let resultView = UIImageView.make(image: croppedImage, frame: cropRect)
        FBSnapshotVerifyView(resultView, file: file, line: line)
    }
}
