//
//  GestureLockView.swift
//  TouchIDAndGestureLock
//
//  Created by jichanghe on 16/6/1.
//  Copyright © 2016年 hjc. All rights reserved.
//

import UIKit

class GestureLockView: UIView {
    // MARK: - Properties
    let screenWidth = UIScreen.mainScreen().bounds.size.width

    var btnArray:[UIButton] = [UIButton]()
    //选中的按钮 的tag值
    var selectBtnTagArray:[Int] = [Int]()
    //手势中手指当前 的位置
    var gesturePoint:CGPoint = CGPoint()
    //按钮的宽高
    let btnWH:CGFloat = 70
    
    
    // MARK: - Lifecycle
     override init(frame:CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        initButtons()
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        print("执行drawRect")
        let context = UIGraphicsGetCurrentContext()//获取画笔上下文
//        CGContextClearRect(context, rect)
        
        var i = 0
        for tag in selectBtnTagArray {
            if (0 == i) {
                //设置 直线的起点
                CGContextMoveToPoint(context, btnArray[tag].center.x, btnArray[tag].center.y);
            } else {
                //新加 一段直线
                CGContextAddLineToPoint(context, btnArray[tag].center.x,btnArray[tag].center.y);
            }
            i = i+1
        }
        
        //如果有选中的节点，就取 跟着 手指的滑动 画线
        if (selectBtnTagArray.count > 0) {
            // 移除最后一条多余的线，
            if gesturePoint != CGPointZero {
                CGContextAddLineToPoint(context, gesturePoint.x, gesturePoint.y);
            }
        }

        CGContextSetLineWidth(context, 10);//设置画笔宽度
        CGContextSetLineJoin(context, .Round);
        CGContextSetLineCap(context, .Round);
        CGContextSetRGBStrokeColor(context, 20/255.0, 107/255.0, 153/255.0, 1);
        CGContextStrokePath(context);
    }
    
    // MARK: - Override
    // 当手指接触屏幕时，就会调用touchesBegan:withEvent方法；
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("执行touchesBegan")
        selectBtnTagArray.removeAll()
        touchesChange(touches)
    }
    
    //当手指在屏幕上移动时，调用touchesMoved:withEvent方法；
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesChange(touches)
    }
    
    //当触摸被取消（比如触摸过程中被来电打断），就会调用touchesCancelled:withEvent方法。而这几个方法被调用时，正好对应了UITouch类中phase属性的4个枚举值。
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
    //当手指离开屏幕时，就会调用touchesEnded:withEvent方法；
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("执行touchesEnded")
        var alertTitle =  "请设置正确的手势"
        var alertMessage = "手势密码不能少于4个"
        if selectBtnTagArray.count >= 4 {
            
            alertTitle =  "手势密码设置成功"
            alertMessage = "密码为：\(selectBtnTagArray)"
            
        }
        let errorAlert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: "确定")
        errorAlert.show()
        
        gesturePoint = CGPointZero;
        self.setNeedsDisplay()
        
        self.performSelector(#selector(recoverNodeStatus), withObject: nil, afterDelay: 1.0)
    }

    // MARK: - PrivateMethod
    private func initButtons() {
        for i in 0...8 {
            //第几行
            let row = i / 3
            let loc = i % 3
            
            //两个button的间距
            let btnSpace = (screenWidth - 3*btnWH)/4
            let btnX = btnSpace + (btnWH + btnSpace) * CGFloat(loc)
            let btnY = 70 + btnSpace + (btnWH + btnSpace) * CGFloat(row)

            let gestureNodeBtn = UIButton(frame:CGRectMake(btnX, btnY, btnWH, btnWH))
            gestureNodeBtn.tag = i
            gestureNodeBtn.userInteractionEnabled = false   //不响应用户的交互。一定要加上这句
            gestureNodeBtn.setImage(UIImage(named: "gesture_node_normal"), forState: .Normal)
            self.addSubview(gestureNodeBtn)
            btnArray.append(gestureNodeBtn)
        }
    }
    
    private func touchesChange(touches: Set<UITouch>) {
        //获取 触摸对象 ,触摸对象的位置坐标来实现
        gesturePoint = touches.first!.locationInView(self)
 
        //保存划过的按钮的tag
        for btn in btnArray {
            //判断 手指的坐标 是否在 button的坐标里
            if !selectBtnTagArray.contains(btn.tag) && CGRectContainsPoint(btn.frame, gesturePoint) {
                selectBtnTagArray.append(btn.tag)
                
                btn.setImage(UIImage(named: "gesture_node_normal"), forState: .Normal)
            }
        }
        
        //setNeedsDisplay和setNeedsLayout。 两个方法都是异步执行的。而setNeedsDisplay会自动调用drawRect方法，这样可以拿到  UIGraphicsGetCurrentContext，就可以画画了。而setNeedsLayout会默认调用layoutSubViews，
        self.setNeedsDisplay()
    }
    
    func recoverNodeStatus() {
        selectBtnTagArray.removeAll()
        for btn in btnArray {
            btn.setImage(UIImage(named: "gesture_node_normal"), forState: .Normal)
        }
        self.setNeedsDisplay()
    }
    
}
