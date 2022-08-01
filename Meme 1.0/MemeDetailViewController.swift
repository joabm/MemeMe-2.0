//
//  MemeDetailViewController.swift
//  Meme 1.0
//
//  Created by Joab Maldonado on 8/1/22.
//

import Foundation
import UIKit


class MemeDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var memeDetail: Meme!
    
    // MARK: Outlet
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.label.text = self.villain.name
        self.tabBarController?.tabBar.isHidden = true
        self.imageView!.image = memeDetail.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
