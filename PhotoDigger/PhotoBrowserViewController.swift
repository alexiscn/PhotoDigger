//
//  PhotoBrowserViewController.swift
//  PhotoDigger
//
//  Created by xu.shuifeng on 06/03/2018.
//  Copyright © 2018 shuifeng.me. All rights reserved.
//

import UIKit
import Photos

public class PhotoBrowserViewController: UIViewController {

    fileprivate var fetchResult: PHFetchResult<PHAsset> = PHFetchResult()
    fileprivate var collectionView: UICollectionView?
    fileprivate let queue: DispatchQueue = DispatchQueue(label: "me.shuifeng.photo.cacheManager")
    fileprivate var imageManager: PHCachingImageManager?
    fileprivate let targetSize: CGSize = CGSize(width: 180, height: 180)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupCollectionView()
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.loadAssets()
            } else {
                self.showError("Please enable Photo Library access in settings")
            }
        }
    }

    fileprivate func loadAssets() {
        self.imageManager = PHCachingImageManager()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    fileprivate func setupCollectionView() {
        let spacing: CGFloat = 10.0
        let itemcount: CGFloat = 3.0
        let totalWidth = self.view.frame.size.width
        let tempWidth = (totalWidth - spacing * (itemcount + 1))/CGFloat(itemcount)
        let itemWidth: CGFloat = CGFloat(ceilf(Float(tempWidth)))
        let margin = (totalWidth - CGFloat(itemWidth * itemcount) - spacing * (itemcount - 1))/2
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 20, left: margin, bottom: 0, right: margin)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(PhotoBrowserCell.self, forCellWithReuseIdentifier: NSStringFromClass(PhotoBrowserCell.self))
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.prefetchDataSource = self
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func showError(_ err: String) {
        let controller = UIAlertController(title: nil, message: err, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension PhotoBrowserViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PhotoBrowserCell.self), for: indexPath) as! PhotoBrowserCell
        
        let asset = fetchResult.object(at: indexPath.item)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        cell.assetIdentifier = asset.localIdentifier
        imageManager?.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
            if cell.assetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let asset = fetchResult.object(at: indexPath.row)
        asset.requestContentEditingInput(with: nil) { (input, _) in
            if let url = input?.fullSizeImageURL, let image = CIImage(contentsOf: url) {
                let controller = PhotoMetadataViewController(dataSource: image.metadataGroups())
                let navigationController = UINavigationController(rootViewController: controller)
                self.present(navigationController, animated: true, completion: nil)
            } else {
                self.showError("can not dig Photo...")
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension PhotoBrowserViewController: UICollectionViewDataSourcePrefetching {
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let validIndexPaths = indexPaths.filter { return $0.item >= 0 && $0.item < self.fetchResult.count }
        let assets = validIndexPaths.map { self.fetchResult.object(at: $0.item) }
        self.imageManager?.startCachingImages(for: assets, targetSize: self.targetSize, contentMode: .aspectFill, options: nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let validIndexPaths = indexPaths.filter { return $0.item >= 0 && $0.item < self.fetchResult.count }
        let assets = validIndexPaths.map { self.fetchResult.object(at: $0.item) }
        self.imageManager?.stopCachingImages(for: assets, targetSize: self.targetSize, contentMode: .aspectFill, options: nil)
    }
}
