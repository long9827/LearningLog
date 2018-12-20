//
//  EntryDetail.swift
//  LearningLog
//
//  Created by nonamer on 2018/12/16.
//  Copyright © 2018年 龙洪杰. All rights reserved.
//

import UIKit

class EntryDetail {
    
    //MARK: Properties
    var creationDate: Date
    var text: String
    var topic: String
    
    
    //MARK: Initialization
    init?(creationDate: Date, text: String, topic: String) {
        if text.isEmpty || topic.isEmpty {
            return nil
        }
        self.creationDate = creationDate
        self.text = text
        self.topic = topic
    }
}
