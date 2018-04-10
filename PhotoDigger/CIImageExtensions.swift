//
//  CIImageExtensions.swift
//  PhotoDigger
//
//  Created by xu.shuifeng on 2018/4/10.
//  Copyright © 2018 shuifeng.me. All rights reserved.
//

import Foundation
import CoreImage

extension CIImage {

    func metadataGroups() -> [MetadataGroup] {
        let metadata = properties.sorted(by: { $0.key < $1.key })
        var groups: [MetadataGroup] = []
        var basics: [MetadataInfo] = []
        metadata.forEach({ (key, value) in
            if let dict = value as? [String: Any] {
                let title = key.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
                groups.append(MetadataGroup(title: title, metadatas: dict.sorted(by: { $0.key < $1.key })))
            } else {
                basics.append((key, value))
            }
        })
        groups.insert(MetadataGroup(title: "BASIC", metadatas: basics), at: 0)
        return groups
    }
}
