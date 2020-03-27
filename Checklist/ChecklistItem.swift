//
//  ChecklistItem.swift
//  Checklist
//
//  Created by Shishira on 2/21/20.
//  Copyright © 2020 Shishira. All rights reserved.
//

import Foundation

class ChecklistItem : NSObject {
    @objc var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked
    }
}
