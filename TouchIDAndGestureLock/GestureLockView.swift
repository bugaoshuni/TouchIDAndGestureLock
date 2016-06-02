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
    var gestureLockDelegate:GestureLockProtocol?
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    var btnArray:[UIButton] = [UIButton]()

    var selectBtnTagArray:[Int] = [Int]()   //选中的按钮 的tag值
    var gesturePoint:CGPoint = CGPoint()    //手势中手指当前 的位置
    let btnWH:CGFloat = 70                  //按钮的宽高
    let btnImgNormal = "gesture_node_normal"
    let btnImgSelected =  "gesture_node_selected"
    
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
        let context = UIGraphicsGetCurrentContext() //获取画笔上下文
        
        var i = 0
        for tag in selectBtnTagArray {
            if (0 == i) {
                //开始画线,设置直线的起点坐标
                CGContextMoveToPoint(context, btnArray[tag].center.x, btnArray[tag].center.y)
            } else {
                //画直线,设置直线的终点坐标
                CGContextAddLineToPoint(context, btnArray[tag].center.x,btnArray[tag].center.y)
            }
            i = i+1
        }
        
        //如果有选中的节点，就取 跟着 手指的滑动 画线
        if (selectBtnTagArray.count > 0) {
            // 移除最后一条多余的线，
            if gesturePoint != CGPointZero {
                CGContextAddLineToPoint(context, gesturePoint.x, gesturePoint.y)
            }
        }

        CGContextSetLineWidth(context, 10)      //设置画笔宽度
        CGContextSetLineJoin(context, .Round)   //两个线相交点 平滑处理
        CGContextSetLineCap(context, .Round)    //设置线条两端的样式为圆角
        CGContextSetRGBStrokeColor(context, 227/255.0, 54/255.0, 58/255.0, 1)
        CGContextStrokePath(context)            // //对线条进行渲染
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
    
    //当触摸被取消（比如触摸过程中被来电打断），就会调用touchesCancelled:withEvent方法。
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
    }
    //当手指离开屏幕时，就会调用touchesEnded:withEvent方法；
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("执行touchesEnded")
        var alertTitle =  "请设置正确的手势"
        var alertMessage = "手势密码不能少于4个"
        var isSuccess = false
        
        if selectBtnTagArray.count >= 4 {
            alertTitle =  "手势密码设置成功"
            isSuccess = true
            alertMessage = "密码为：\(selectBtnTagArray)"
        }
        
        gestureLockDelegate!.gestureLockSuccess(isSuccess, title: alertTitle, message: alertMessage)
        
        gesturePoint = CGPointZero;
        self.setNeedsDisplay()
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
            gestureNodeBtn.setImage(UIImage(named: btnImgNormal), forState: .Normal)
            self.addSubview(gestureNodeBtn)
            btnArray.append(gestureNodeBtn)
        }
    }
    
    private func touchesChange(touches: Set<UITouch>) {
        //获取 触摸对象 ,触摸对象的位置坐标来实现
        gesturePoint = touches.first!.locationInView(self)

        for btn in btnArray {
            //判断 手指的坐标 是否在 button的坐标里
            if !selectBtnTagArray.contains(btn.tag) && CGRectContainsPoint(btn.frame, gesturePoint) {
                //处理跳跃连线
                var lineCenterPoint:CGPoint = CGPoint()
                
                if selectBtnTagArray.count > 0 {
                    lineCenterPoint = centerPoint(btn.frame.origin, endPoint: btnArray[selectBtnTagArray.last!].frame.origin)
                }
                
                //保存中间跳跃 过的节点
                for btn in btnArray {
                    if  !selectBtnTagArray.contains(btn.tag) && CGRectContainsPoint(btn.frame, lineCenterPoint)  {
                        btn.setImage(UIImage(named: btnImgSelected), forState: .Normal)
                        selectBtnTagArray.append(btn.tag)
                    }
                }
                
                //保存划过的按钮的tag
                selectBtnTagArray.append(btn.tag)
                btn.setImage(UIImage(named: btnImgSelected), forState: .Normal)
            }
        }
        
        //setNeedsDisplay会自动调用drawRect方法 进行画线
        self.setNeedsDisplay()
    }
    
    //计算2个节点中心的坐标
    private func centerPoint(startPoint: CGPoint, endPoint:CGPoint) -> CGPoint {
        let rightPoint = startPoint.x > endPoint.x ? startPoint.x : endPoint.x
        let leftPoint = startPoint.x < endPoint.x ? startPoint.x : endPoint.x
        
        let topPoint = startPoint.y > endPoint.y ? startPoint.y : endPoint.y
        let bottomPoint = startPoint.y < endPoint.y ? startPoint.y : endPoint.y
        
        //x坐标： leftPoint +（rightPoint-leftPoint)/2 = (rightPoint+leftPoint)/2
        return CGPointMake((rightPoint + leftPoint)/2 + btnWH/2, (topPoint + bottomPoint)/2 + btnWH/2);
    }
    
    func recoverNodeStatus() {
        selectBtnTagArray.removeAll()
        for btn in btnArray {
            btn.setImage(UIImage(named: btnImgNormal), forState: .Normal)
        }
        self.setNeedsDisplay()
    }
    
}
