//
//  SentMemesTableViewController.swift
//  Meme 1.0
//
//  Created by Joab Maldonado on 7/30/22.
//

import Foundation
import UIKit

class MemeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var memeLabel: UILabel!
    
}

class SentMemesTableViewController: UITableViewController {
    
    // MARK: Properties
    
    //Access the memes array in AppDelegate
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell", for: indexPath) as! MemeTableViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // Set the text and image
        cell.memeLabel?.text = meme.topText + "..." + meme.bottomText
        cell.memeImage?.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.memeDetail = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
