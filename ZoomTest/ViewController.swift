//
//  ViewController.swift
//  ZoomTest
//
//  Created by Mathew Miller on 12/30/18.
//  Copyright © 2018 Mathew Miller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView.collectionViewLayout = BidirectionCollectionLayout()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 500, height: 500)
        }
//        collectionView.contentInsetAdjustmentBehavior = .automatic
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCellCollectionViewCell
        
        cell.imageView.viewToScaleAndPan = collectionView
        if let layout = collectionView.collectionViewLayout as? PanAndZoomCollectionLayout {
            cell.imageView.delegate = layout
            print(cell.imageView.image?.size)
            cell.pageNumber.text = "Page \(indexPath.item)"
        }

        return cell
    }
    
    
}

