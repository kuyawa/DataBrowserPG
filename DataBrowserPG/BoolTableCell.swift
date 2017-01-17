//
//  BoolTableCell.swift
//  DataBrowserPG
//
//  Created by Mac Mini on 1/16/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa

class BoolTableCell: NSTableCellView {

    @IBOutlet weak var checkbox : NSButton!

    var checked: Bool {
        get { return checkbox.state == 1 }
        set { checkbox.state = newValue ? 1 : 0 }
    }
    
/*
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
*/
}
