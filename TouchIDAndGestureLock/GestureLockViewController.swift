//
//  GestureLockViewController.swift
//  TouchIDAndGestureLock
//
//  Created by jichanghe on 16/6/1.
//  Copyright © 2016年 hjc. All rights reserved.
//

import UIKit

class GestureLockViewController: UIViewController {
    

    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureLockView = GestureLockView()
        self.view = gestureLockView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
