//
//  ScaleableImageView.swift
//  ZoomTest
//
//  Created by Mathew Miller on 12/30/18.
//  Copyright © 2018 Mathew Miller. All rights reserved.
//

import UIKit


class ScaleableImageView: UIImageView {

    var viewToScaleAndPan: UICollectionView?
    weak var delegate: ScaleableCollectionItemDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchDetected(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchDetected(_:))))
    }
    
    var scaleStart: CGFloat = 1.0
    @objc func pinchDetected(_ gesture: UIPinchGestureRecognizer) {
        if let delegate = delegate {
            
            switch gesture.state {
            case .began:
                scaleStart = delegate.scale
            case .changed:
                delegate.scale = scaleStart*gesture.scale
                let pinchCenter = CGPoint(x: gesture.location(in: self).x - self.bounds.midX,
                                          y: gesture.location(in: self).y - self.bounds.midY)
//                delegate.centerOn(pinchCenter, inView: self)
            default:
                break
            }
        }
    }
}
