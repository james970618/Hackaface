//
//  startViewController.swift
//  mhackshype
//
//  Created by James on 2016/10/8.
//  Copyright © 2016年 JiangYifan. All rights reserved.
//

import UIKit
//let login = LoginManager.init()


class startViewController: UIViewController {
    var logined = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (logined) {
            performSegue(withIdentifier: "start to main", sender: self)
        }
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
