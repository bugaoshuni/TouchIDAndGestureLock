//
//  GestureLockViewController.swift
//  TouchIDAndGestureLock
//
//  Created by jichanghe on 16/6/1.
//  Copyright © 2016年 hjc. All rights reserved.
//

import UIKit

protocol GestureLockProtocol {
    func gestureLockSuccess(isSuccess:Bool, title: String, message: String)
}

class GestureLockViewController: UIViewController,GestureLockProtocol {
    // MARK: - Properties
    let gestureLockView = GestureLockView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        gestureLockView.gestureLockDelegate = self
        self.view = gestureLockView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Delegate
    func gestureLockSuccess(isSuccess:Bool, title: String, message: String) {
        if isSuccess == true {
            print("设置手势密码成功")
        } else {
            print("设置手势密码失败")
        }
        
        let alert: UIAlertController = UIAlertController(title:title, message:message, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: {action in
            print("alert确定")
            
            self.gestureLockView.recoverNodeStatus()
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
