//
//  HelpViewController.swift
//  Earth Memo
//
//  Created by Yuning Jin on 8/4/15.
//  Copyright (c) 2015 Noctiz. All rights reserved.
//

import UIKit
import Parse
import ParseUI


class HelpViewController: UIViewController {
    
    var imFlag: Int = 1
    
    @IBOutlet weak var t01: UIImageView!
    @IBOutlet weak var t02: UIImageView!
    @IBOutlet weak var t03: UIImageView!
    @IBOutlet weak var t04: UIImageView!
    @IBOutlet weak var t05: UIImageView!
    
    
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        t02.hidden = true
        t03.hidden = true
        t04.hidden = true
        t05.hidden = true
        
        if (imFlag == 5) {
            
            playButton.setTitle("  Replay", forState: UIControlState.Normal)
            playButton.setImage(UIImage(named: "backIcon"), forState: UIControlState.Normal)
            
        } else {
            
            playButton.setTitle("  Next", forState: UIControlState.Normal)
            playButton.setImage(UIImage(named: "playIcon"), forState: UIControlState.Normal)
        }
        
        self.view.backgroundColor = UIColor(red: 44/255, green: 54/255, blue: 62/255, alpha: 1)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playAction(sender: UIButton) {
        
        if (imFlag == 1) {
            
            imFlag = 2
            
            t01.hidden = true
            t02.hidden = false
            
            playButton.setTitle("  Next", forState: UIControlState.Normal)
            playButton.setImage(UIImage(named: "playIcon"), forState: UIControlState.Normal)
            
        } else if (imFlag == 2) {
            
            imFlag = 3
            
            t02.hidden = true
            t03.hidden = false
            
        } else if (imFlag == 3) {
            
            imFlag = 4
            
            t03.hidden = true
            t04.hidden = false
            
        } else if (imFlag == 4) {
            
            imFlag = 5
            
            t04.hidden = true
            t05.hidden = false
            
            
        } else {
            
            imFlag = 1
            
            t05.hidden = true
            t01.hidden = false
            
            playButton.setTitle("  Replay", forState: UIControlState.Normal)
            playButton.setImage(UIImage(named: "backIcon"), forState: UIControlState.Normal)
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
