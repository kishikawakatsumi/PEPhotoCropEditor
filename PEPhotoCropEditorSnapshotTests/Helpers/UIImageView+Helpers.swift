//
//  UIImageView+Helpers.swift
//  PEPhotoCropEditor
//
//  Created by WITOLD SKIBNIEWSKI on 21/07/2017.
//  Copyright © 2017 kishikawa katsumi. All rights reserved.
//

import UIKit

extension UIImageView {
    static func make(image: UIImage?, frame: CGRect) -> UIImageView {
        let view = UIImageView(frame: frame)
        view.image = image
        return view
    }
}
