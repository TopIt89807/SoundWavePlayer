//
//  BookmarkTableViewController.swift
//  SoundWavePlayer
//
//  Created by Admin User on 5/9/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import waveFormLibrary


class BookmarkTableViewController: UITableViewController {
    
    var array : [Int] = []
    var controller : ControllerWaveForm!
    
    var delegate : BookmarkDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int{
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return array.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)

        // Configure the cell...
        //cell.textLabel?.text = fruits[indexPath.row]
        //for arr in mBookmarks {
        //let str = String(format: "%d", array[indexPath.row])
        
        let totSec = controller.pixelsToMillisecs(pos: array[indexPath.row]) / 1000
        let milliSec = (controller.pixelsToMillisecs(pos: array[indexPath.row]) % 1000) / 10
        let sec = totSec % 60
        let min = totSec / 60
        
        var milliStr : String = ""
        var secStr : String = ""
        
        if milliSec < 10 {
            milliStr = String(format: "0%d", milliSec)
        }else {
            milliStr = String(format: "%d", milliSec)
        }
        if sec < 10 {
            secStr = String(format: "0%d", sec)
        }else {
            secStr = String(format: "%d", sec)
        }
        
        let str = String(format: "%d:%@:%@",min, secStr, milliStr)
        cell.textLabel?.text = str
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Bookmark(s)"
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            array.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            delegate.getBookmarkData(index : indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //indexPath.row
        delegate.playBookmark(index : indexPath.row)
        _ = navigationController?.popViewController(animated: true)
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
