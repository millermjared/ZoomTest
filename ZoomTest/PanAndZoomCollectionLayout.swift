//
//  PanAndZoomCollectionLayout.swift
//  ZoomTest
//
//  Created by Mathew Miller on 1/2/19.
//  Copyright © 2019 Mathew Miller. All rights reserved.
//

import UIKit



class PanAndZoomCollectionLayout: UICollectionViewLayout {
    
    var layout: [UICollectionViewLayoutAttributes] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepare() {
        
        for i in 0..<(collectionView?.numberOfItems(inSection: 0) ?? 0) {
            let indexPath = IndexPath(item: i, section: 0)
            let attribs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attribs.frame = CGRect(x: 0, y: i*1034, width: 760, height: 1024)
            attribs.zIndex = 1000
            attribs.size = CGSize(width: 760, height: 1024)
            
            layout.append(attribs)
        }
        
        // Note: call super last if we set itemSize
        super.prepare()
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 760*_scale, height: 1024.0*CGFloat(collectionView?.numberOfItems(inSection: 0) ?? 1)*_scale)
    }
    
    let kScaleBoundLower: CGFloat = 0.5
    let kScaleBoundUpper: CGFloat = 2.0
    var _scale: CGFloat = 1.0
    var scaleTransform = CGAffineTransform.identity
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard indexPath.item < layout.count else {return nil}
        
        let attribs = layout[indexPath.item].copy(with: nil) as! UICollectionViewLayoutAttributes
            
        attribs.frame = attribs.frame.applying(scaleTransform)
        attribs.size = attribs.frame.size
        
        return attribs
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let index = Int(rect.minY/1024.0)
        let cellCount = Int(rect.height/1024.0)

        var collectedAttribs = [UICollectionViewLayoutAttributes]()
        for i in index..<(index+cellCount) {
            guard i>=0 && i<layout.count else {
                continue
            }
            
            let attribs = layout[i].copy(with: nil) as! UICollectionViewLayoutAttributes
            
            attribs.frame = attribs.frame.applying(scaleTransform)
            attribs.size = attribs.frame.size
            
            collectedAttribs.append(attribs)
        }
        
        return collectedAttribs
    }
}




class PanAndZoomCollectionLayoutBckup: UICollectionViewFlowLayout {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func prepare() {
        scrollDirection = .vertical
        minimumInteritemSpacing = 1
        minimumLineSpacing = 10
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: self.minimumLineSpacing, right: 0)
        let collectionViewWidth = self.collectionView?.bounds.size.width ?? 0
        headerReferenceSize = CGSize(width: collectionViewWidth, height: 40)
        
        // cell size
        let itemWidth: CGFloat = 768.0
        self.itemSize = CGSize(width: itemWidth*_scale, height: 1024.0*_scale)
        
        // Note: call super last if we set itemSize
        super.prepare()
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 768*_scale, height: 2048*_scale)
    }
    
    let kScaleBoundLower: CGFloat = 0.5
    let kScaleBoundUpper: CGFloat = 2.0
    var _scale: CGFloat = 1.0
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        guard let collectionView = collectionView else { return nil }
        layoutAttributes.bounds.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right
        return layoutAttributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        guard scrollDirection == .vertical else { return superLayoutAttributes }
        
        let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
            return layoutAttribute.representedElementCategory == .cell ? layoutAttributesForItem(at: layoutAttribute.indexPath) : layoutAttribute
        }
        return computedAttributes
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
            
            let size = collectionView?.frame.size ?? .zero
            
            scaleTransform = CGAffineTransform.identity.translatedBy(x: size.width/2.0, y: size.height/2.0).scaledBy(x: _scale, y: _scale).translatedBy(x: -size.width/2.0, y: -size.height/2.0)
            
            invalidateLayout()
        }
    }
}
