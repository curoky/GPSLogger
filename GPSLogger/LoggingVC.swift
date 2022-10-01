//
//  LoggingVC.swift
//  GPSLogger
//
//  Created by curoky on 2022/9/30.
//

import UIKit

class LoggingVC: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func fetchLogClicked(_ sender: Any) {
        logTextView.text = GPSLogHelper.shared.tailfLog()
    }
    
    @IBAction func exportClicked(_ sender: Any) {
        var filesToShare = [Any]()
        filesToShare.append(URL(filePath: GPSLogHelper.shared.logFilePath))
        
        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
