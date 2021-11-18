//
//  ContentViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 18.11.21.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = content
    }
    
    
}
