//
//  PlayingItem.swift
//  VodeoPlayerKit
//
//  Created by xiaohongjun on 2017/10/29.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

import UIKit

class PlayingItem: NSObject {
    var url: String
    var requestOffset: Int64 = 0
    var customSchema: String = "customSchema"
    lazy var originalSchema: String? = {
        var components = URLComponents(string: url)
        return components?.scheme
    }()
    init(_ dict: Dictionary<String, Any>) {
        self.url = dict["url"] as? String ?? ""
        super.init()
    }
    
    func changeCustomSchema() -> String {
        if let _ = self.originalSchema, var components = URLComponents(string: url) {
           components.scheme = customSchema
           return (components.url?.absoluteString)!
        }
        return ""
    }
    
    func resetSchema() {
        if let _ = self.originalSchema {
            var components = URLComponents(string: url)
            components?.scheme = originalSchema
            self.url = components?.url?.absoluteString ?? ""
        }
    }
}

