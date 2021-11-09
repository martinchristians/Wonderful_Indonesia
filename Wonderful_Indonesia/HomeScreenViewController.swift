//
//  HomeScreenViewController.swift
//  Wonderful_Indonesia
//
//  Created by Martin Christian Solihin on 09.11.21.
//

import UIKit

class HomeScreenViewController: UIViewController {

    @IBAction func Exit(_ sender: Any) {
        let cont = UIAlertController(title: "Exit", message: "Are you sure?", preferredStyle: .alert)
        
        cont.addAction(UIAlertAction(title: "NO", style: .cancel,
            handler: {(action: UIAlertAction) -> Void in
                print ("Click button \(action.title!)")
            }
        ))
        
        cont.addAction(UIAlertAction(title: "YES", style: .default,
            handler: {(action: UIAlertAction) -> Void in
                print ("Click button \(action.title!)")
                exit(0)
            }
        ))
        
        self.present(cont, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
