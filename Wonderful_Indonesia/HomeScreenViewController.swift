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
        navItem()
    }
    
    private func navItem() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "info.circle.fill"),
            style: .done,
            target: self,
            action: #selector(imprintStoryBoard))
    }
    
    @objc func imprintStoryBoard() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let imprintViewController = mainStoryboard.instantiateViewController(withIdentifier: "ImprintViewController") as? ImprintViewController else {
            print("View Controller not found")
            return
        }
        
        navigationController?.pushViewController(imprintViewController, animated: true)
    }
}
