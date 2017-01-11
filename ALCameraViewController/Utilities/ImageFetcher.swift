//
//  ALImageFetchingInteractor.swift
//  ALImagePickerViewController
//
//  Created by Alex Littlejohn on 2015/06/09.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public typealias ImageFetcherSuccess = (PHFetchResult) -> ()
public typealias ImageFetcherFailure = (NSError) -> ()

//extension PHFetchResult: Sequence {
//    public func makeIterator() -> NSFastEnumerationIterator {
//        return NSFastEnumerationIterator(self)
//    }
//}

public class ImageFetcher {

    private var success: ImageFetcherSuccess?
    private var failure: ImageFetcherFailure?
    
    private var authRequested = false
    private let errorDomain = "com.zero.imageFetcher"

    let libraryQueue = dispatch_queue_create("com.zero.ALCameraViewController.LibraryQueue", DISPATCH_QUEUE_SERIAL);
	
    public init() { }
    
    public func onSuccess(success: ImageFetcherSuccess) -> Self {
        self.success = success
        return self
    }
    
    public func onFailure(failure: ImageFetcherFailure) -> Self {
        self.failure = failure
        return self
    }
    
    public func fetch() -> Self {
        _ = PhotoLibraryAuthorizer { error in
            if error == nil {
                self.onAuthorized()
            } else {
                self.failure?(error!)
            }
        }
        return self
    }
    
    private func onAuthorized() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		dispatch_async(libraryQueue) {
            let assets = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: options)
            dispatch_async(dispatch_get_main_queue()) {
                self.success?(assets)
            }
        }
    }
}
