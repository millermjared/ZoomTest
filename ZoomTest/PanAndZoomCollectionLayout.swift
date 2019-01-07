//
//  PanAndZoomCollectionLayout.swift
//  ZoomTest
//
//  Created by Mathew Miller on 1/2/19.
//  Copyright © 2019 Mathew Miller. All rights reserved.
//

import UIKit


//TODO move to CGExtensions file
extension CGSize : ExpressibleByStringLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        
        let size: CGSize;
        if value[value.startIndex] != "{" {
            size = NSCoder.cgSize(for: "{\(value)}")
        } else {
            size = NSCoder.cgSize(for: value)
        }
        self.width = size.width;
        self.height = size.height;
    }
    
    func scaledTo(width: CGFloat)->CGSize {
        let scale = width/self.width
        return CGSize(width: self.width*scale, height: self.height*scale)
    }
    
}

enum PageSize: CGSize {
    case A4Portrait = "595, 842"
    case A4Landscape = "842, 595"
}

extension CGSize {
    func scaledBy(width: CGFloat, height: CGFloat)->CGSize {
        return CGSize(width: self.width*width, height: self.height*height)
    }
}

extension CGPoint {
    func scaledBy(x: CGFloat, y: CGFloat)->CGPoint {
        return CGPoint(x: self.x*x, y: self.y*y)
    }
}



class PanAndZoomCollectionLayout: UICollectionViewLayout {
    
    var layout: [UICollectionViewLayoutAttributes]?
    var estimatedItemSize = PageSize.A4Portrait
    var rowSpacing: CGFloat = 10.0
    
    var cumulativeHeight: CGFloat = 0.0
    var maximumWidth: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        
        if layout == nil {
            layout = [UICollectionViewLayoutAttributes]()
            for i in 0..<(collectionView?.numberOfItems(inSection: 0) ?? 0) {
                
                let indexPath = IndexPath(item: i, section: 0)
                let attribs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attribs.zIndex = 1000
                attribs.size = PageSize.A4Portrait.rawValue//.scaledTo(width: estimatedItemSize.rawValue.width)
                attribs.center = CGPoint(x: (collectionView?.frame.size.width ?? 0.0)/2.0, y: CGFloat(i)*rowSpacing + cumulativeHeight + attribs.size.height/2.0)
                
                cumulativeHeight += attribs.size.height
                layout?.append(attribs)
            }
        } else if let layout = layout {
            for i in 0..<(collectionView?.numberOfItems(inSection: 0) ?? 0) {
                
                let attribs = layout[i]
                let currentFrame = attribs.frame
                attribs.frame = CGRect(x: 0.0, y: cumulativeHeight, width: currentFrame.width, height: currentFrame.height)

                cumulativeHeight += currentFrame.height
            }
        }
        
        // Note: call super last if we set itemSize
        super.prepare()
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: maximumWidth*_scale, height: cumulativeHeight*_scale)
    }
    
    let kScaleBoundLower: CGFloat = 0.5
    let kScaleBoundUpper: CGFloat = 2.0
    var _scale: CGFloat = 1.0
    var scaleTransform = CGAffineTransform.identity
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard indexPath.item < layout?.count ?? 0 else {return nil}
        
        if let attribs = layout?[indexPath.item].copy(with: nil) as? UICollectionViewLayoutAttributes {
            
            attribs.size = attribs.size.applying(scaleTransform)
            attribs.center = attribs.center.applying(scaleTransform)
            
            return attribs
        } else {
            return nil
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        guard let layout = layout else {return nil}
        
        let scaledHeight = estimatedItemSize.rawValue.height*_scale
        
        let index = Int(rect.minY/scaledHeight)
        let cellCount = Int(rect.height/scaledHeight)
        
        let start = max(0, index-1)

        var collectedAttribs = [UICollectionViewLayoutAttributes]()
        
        guard start < (index+cellCount) else {return nil}
        
        for i in start...(index+cellCount) {
            guard i>=0 && i<layout.count else {
                continue
            }
            
            let attribs = layout[i].copy(with: nil) as! UICollectionViewLayoutAttributes
            
            let transformedFrame = attribs.frame.applying(scaleTransform)
            
            attribs.frame = transformedFrame.offsetBy(dx: -1*transformedFrame.minX, dy: 0.0)
            attribs.size = attribs.frame.size
            attribs.center = CGPoint(x: collectionView?.frame.midX ?? transformedFrame.midX, y: transformedFrame.midY)
            
            collectedAttribs.append(attribs)
        }
        
        return collectedAttribs
    }

    func setNativeSize(_ size: CGSize, forIndexPath indexPath: IndexPath) {
        if let attribs = layout?[indexPath.item] {
            cumulativeHeight -= attribs.size.height
            attribs.size = size
            cumulativeHeight += attribs.size.height
            if attribs.size.width > maximumWidth {
                maximumWidth = attribs.size.width
            }
        }
    }

    //TODO think about this one - this is for self-sizing cells
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return false
    }
}

extension PanAndZoomCollectionLayout: ScaleableCollectionItemDelegate {    
    
    var scale: CGFloat {
        get {
            return _scale
        }
        
        set {
            setScale(newValue)
        }
    }
    
    func setScale(_ scale: CGFloat) {
        let originalScale = _scale
        
        // Make sure it doesn't go out of bounds
        if (scale < kScaleBoundLower)
        {
            _scale = kScaleBoundLower
        }
        else if (scale > kScaleBoundUpper)
        {
            _scale = kScaleBoundUpper
        }
        else
        {
            _scale = scale
        }
        
        if _scale != originalScale {
            
            if let offset = collectionView?.contentOffset {
                let relativeScale = 1.0 + _scale - originalScale
                collectionView?.contentOffset = offset.scaledBy(x: relativeScale, y: relativeScale)
            }
            
            let size = collectionView?.frame.size ?? .zero
            
            scaleTransform = CGAffineTransform.identity.translatedBy(x: size.width/2.0, y: size.height/2.0).scaledBy(x: _scale, y: _scale).translatedBy(x: -size.width/2.0, y: -size.height/2.0)
                        
            invalidateLayout()
        }
    }
}
