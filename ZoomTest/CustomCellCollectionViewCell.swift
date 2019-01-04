//
//  CustomCellCollectionViewCell.swift
//  ZoomTest
//
//  Created by Mathew Miller on 12/30/18.
//  Copyright © 2018 Mathew Miller. All rights reserved.
//

import UIKit

class CustomCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: ScaleableImageView!
    @IBOutlet weak var pageNumber: UILabel!
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let att = super.preferredLayoutAttributesFitting(layoutAttributes)
        let scale = imageView.delegate?.scale ?? 1.0
        att.size = CGSize(width: 760 * scale, height: 1020 * scale)
        return att
    }
}
