//
//  PhotoLibraryAuthorizer.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2016/03/26.
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit
import Photos

public typealias PhotoLibraryAuthorizerCompletion = (NSError?) -> Void

class PhotoLibraryAuthorizer {

    private let errorDomain = "com.zero.imageFetcher"

    private let completion: PhotoLibraryAuthorizerCompletion

    init(completion: PhotoLibraryAuthorizerCompletion) {
        self.completion = completion
        handleAuthorization(PHPhotoLibrary.authorizationStatus())
    }
    
    func onDeniedOrRestricted(completion: PhotoLibraryAuthorizerCompletion) {
        let error = errorWithKey("error.access-denied", domain: errorDomain)
        completion(error)
    }
    
    func handleAuthorization(status: PHAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization(handleAuthorization)
            break
        case .Authorized:
            dispatch_async(dispatch_get_main_queue()) {
                self.completion(nil)
            }
            break
        case .Denied, .Restricted:
            dispatch_async(dispatch_get_main_queue()) {
                self.onDeniedOrRestricted(self.completion)
            }
            break
        }
    }
}
