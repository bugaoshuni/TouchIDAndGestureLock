//
//  ViewController.swift
//  TouchIDAndGestureLock
//
//  Created by jichanghe on 16/6/1.
//  Copyright © 2016年 hjc. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    // MARK: - Properties
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - XXXXXDelegate
    // MARK: - EventResponse
    @IBAction func touchID(sender: UIButton) {
        let laContext = LAContext()
        var error:NSError?
        if laContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            laContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics,
                                     localizedReason: "请验证已有的指纹",
                                     reply: {(success: Bool, error: NSError?) in
                //这里不是在主线程中执行的，是多线程。
                if success {
                    print("验证指纹成功")
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        //主线程刷新View
                    })
                } else {
                    print(error)
                    switch error?.code {
                    case LAError.AuthenticationFailed.rawValue?:
                        print("授权失败")
                    case LAError.UserCancel.rawValue?:
                        print("用户取消验证Touch ID")
                    case LAError.UserFallback.rawValue?:
                        print("用户点击 输入密码，切换主线程处理")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    case LAError.SystemCancel.rawValue?:
                        print("切换到其他APP，系统取消验证Touch ID")
                    case LAError.PasscodeNotSet.rawValue?:
                        print("系统未设置密码")
                    case LAError.TouchIDNotAvailable.rawValue?:
                        print("设备Touch ID不可用，例如未打开")
                    case LAError.TouchIDNotEnrolled.rawValue?:
                        print("设备Touch ID不可用，用户未录入")
                    case LAError.TouchIDLockout.rawValue?:
                        print("Touch ID输入错误多次，已被锁")
                    case LAError.AppCancel.rawValue?:
                        print("用户除外的APP挂起，如电话接入等切换到了其他APP")
                    default:
                        print("其他情况")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    }
                }
            })

        } else {
            print(error)
        }
        
    }

    //手势密码
    @IBAction func gestureLock(sender: UIButton) {
        switch (sender.tag) {
        case 1:
            print("设置手势密码")
            let gestureLockVC = GestureLockViewController()
            
            self.navigationController?.pushViewController(gestureLockVC, animated: true)
            
        case 2:
            print("验证手势密码")
            
        default:
            break
        }
        
    }

    // MARK: - PrivateMethod
    //指纹解锁
    private func showPasswordAlert() {
        let passwordAlert: UIAlertController = UIAlertController(title:"指纹验证选择输入密码", message:"请输入手机密码", preferredStyle:.Alert)
        passwordAlert.addTextFieldWithConfigurationHandler({ (textField: UITextField) in
            textField.secureTextEntry = true
        })

        passwordAlert.addAction(UIAlertAction(title: "确定", style: .Default, handler: {action in
            let password = passwordAlert.textFields?.first?.text
            if let pw = password {
                print("输入密码正确，密码为： \(pw)")
            }
        }))
        
        passwordAlert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: {action in
            print("取消输入密码")
        }))
        
        self.presentViewController(passwordAlert, animated: true, completion: nil)
    }
    
    
    // MARK: - PublicMethod
    // MARK: - Request
    // MARK: - SetterGetter

    
    
}

