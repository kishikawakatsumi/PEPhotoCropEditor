//
//  CGRect+Helpers.swift
//  PEPhotoCropEditor
//
//  Created by WITOLD SKIBNIEWSKI on 21/07/2017.
//  Copyright © 2017 kishikawa katsumi. All rights reserved.
//

import Foundation

extension CGRect {

    init(image: UIImage) {
        self.init(origin: .zero, size: image.size)
    }
}
