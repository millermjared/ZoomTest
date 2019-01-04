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
//        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragDetected(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchDetected(_:))))
//        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragDetected(_:))))
    }
    
    @objc func dragDetected(_ gesture: UIPanGestureRecognizer) {
        if let view = viewToScaleAndPan {
            switch gesture.state {
            case .changed:
                
                let dragPoint = gesture.translation(in: view)
                let transform = view.transform.translatedBy(x: dragPoint.x, y: dragPoint.y)
                
                view.transform = transform
                
            default:
                return
            }
        }
    }
    
    var scaleStart: CGFloat = 1.0
    @objc func pinchDetected(_ gesture: UIPinchGestureRecognizer) {
        if let delegate = delegate {
            
            switch gesture.state {
            case .began:
                scaleStart = delegate.scale
            case .changed:
                delegate.scale = scaleStart*gesture.scale
            default:
                break
            }
            
//            gesture.scale = 1.0
        }
    }

    var initialFrame = CGRect.zero
    @objc func pinchDetected2(_ gesture: UIPinchGestureRecognizer) {
        if let view = viewToScaleAndPan {
            switch gesture.state {
            case .began:
                initialFrame = view.frame
                fallthrough
            case .changed:
                let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                                          y: gesture.location(in: view).y - view.bounds.midY)
                
                let sourceTransform = view.layer.affineTransform()
                
                let transform = sourceTransform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: gesture.scale, y: gesture.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)

//                let resultingFrame = view.bounds.applying(transform)
//                if (resultingFrame.height < view.bounds.height) {
////                    view.frame = CGRect(x: view.frame.minX, y: view.bounds.minY, width: view.frame.width, height: view.bounds.height)
//                    view.bounds = CGRect(x: view.bounds.minX, y: view.bounds.minY - view.bounds.height / 2.0, width: view.bounds.width, height: <#T##CGFloat#>)
//                }

                view.layer.transform = CATransform3DMakeAffineTransform(transform)

                gesture.scale = 1
            default:
                return
            }
        }
    }

    
}
