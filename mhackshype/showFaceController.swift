//
//  showFaceController.swift
//  mhackshype
//
//  Created by James on 2016/10/10.
//  Copyright © 2016年 JiangYifan. All rights reserved.
//

import UIKit

class showFaceController: UIViewController {
    
    @IBAction func onUnwindTap(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            performSegue(withIdentifier: "unwindFaceToScoreBoard", sender: sender)
        default:
            break;
        }
    }
    @IBAction func onUnwindPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .ended:
            fallthrough
        case .changed:
            let translation = sender.translation(in: faceImage)
            if translation.y > 40 {
                sender.setTranslation(CGPoint.zero, in: faceImage)
                performSegue(withIdentifier: "unwindFaceToScoreBoard", sender: sender)
            }
//            let happinessChange = Int(translation.y / Constants.HappinessGestureScale)
//            if happinessChange != 0 {
//                happiness += happinessChange
//                sender.setTranslation(CGPoint.zero, in: faceView)
//            }
        default:
            break
        }
    }
    var image : UIImage? = nil;
    @IBOutlet weak var faceImage: UIImageView!
    override var prefersStatusBarHidden: Bool{
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        faceImage.image = image;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
