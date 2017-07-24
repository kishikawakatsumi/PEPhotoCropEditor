//
//  UIImage+OrientationSnapshotTests.swift
//  PEPhotoCropEditor
//
//  Created by WITOLD SKIBNIEWSKI on 21/07/2017.
//  Copyright © 2017 kishikawa katsumi. All rights reserved.
//

import FBSnapshotTestCase

class UIImage_OrientationSnapshotTests: FBSnapshotTestCase {

    func test_cropCenterOrientationUp() {
        verifyOrientationSnapshot(orientation: .up)
    }

    func test_cropCenterOrientationUpMirrored() {
        verifyOrientationSnapshot(orientation: .upMirrored)
    }

    func test_cropCenterOrientationRight() {
        verifyOrientationSnapshot(orientation: .right)
    }

    func test_cropCenterOrientationRightMirrored() {
        verifyOrientationSnapshot(orientation: .rightMirrored)
    }

    func test_cropCenterOrientationDown() {
        verifyOrientationSnapshot(orientation: .down)
    }

    func test_cropCenterOrientationDownMirrored() {
        verifyOrientationSnapshot(orientation: .downMirrored)
    }

    func test_cropCenterOrientationLeft() {
        verifyOrientationSnapshot(orientation: .left)
    }

    func test_cropCenterOrientationLeftMirrored() {
        verifyOrientationSnapshot(orientation: .leftMirrored)
    }
}
