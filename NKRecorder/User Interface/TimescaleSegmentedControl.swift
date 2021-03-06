//
//  TimescaleSegmentedControl.swift
//  VideoMaker
//
//  Created by Tom on 10/15/15.
//  Copyright © 2015 Tom. All rights reserved.
//

import UIKit

enum TimescaleSegmentedControlIndex: Int {
    case x025, x05, x1, x15, x20
}

class TimescaleSegmentedControl: UISegmentedControl {
    
    // segmented control has a pointing triangle under it, making it look like a bubble
    var triangleWidth: CGFloat = 0.0
    let triangleHeight: CGFloat = 5.0
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let titleTextAttributes = [NSFontAttributeName : FontKit.segmentedControlLabel, NSForegroundColorAttributeName : UIColor.whiteColor()]
        setTitleTextAttributes(titleTextAttributes, forState: .Normal)
        setTitleTextAttributes(titleTextAttributes, forState: .Selected)
        
        setBackgroundImage(UIImage(key: .segCtrlNormalBg), forState: .Normal, barMetrics: .Default)
        setBackgroundImage(UIImage(key: .segCtrlSelectedBg), forState: .Selected, barMetrics: .Default)
        setDividerImage(UIImage(key: .segCtrlDividerNoneSelected), forLeftSegmentState: .Normal, rightSegmentState: .Normal, barMetrics: .Default)
        setDividerImage(UIImage(key: .segCtrlDividerRightSelected), forLeftSegmentState: .Normal, rightSegmentState: .Selected, barMetrics: .Default)
        setDividerImage(UIImage(key: .segCtrlDividerLeftSelected), forLeftSegmentState: .Selected, rightSegmentState: .Normal, barMetrics: .Default)
        
        let dividerImageWidth = UIImage(key: .segCtrlDividerNoneSelected)!.size.width // assuming all the divider images have the same width
        setContentPositionAdjustment(UIOffsetMake(dividerImageWidth / 2, 0), forSegmentType: .Left, barMetrics: .Default)
        setContentPositionAdjustment(UIOffsetMake(-dividerImageWidth / 2, 0), forSegmentType: .Right, barMetrics: .Default)
        tintColor = UIColor.whiteColor() 
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        triangleWidth = (bounds.size.width / CGFloat(numberOfSegments)) * 0.4
        (superview as! TimescaleSegmentedControlWrapper).timescaleSegmentedControl = self
    }

}

class TimescaleSegmentedControlWrapper: UIView {
    
    weak var timescaleSegmentedControl: TimescaleSegmentedControl?
    
    override func drawRect(rect: CGRect) {
        if let segmentedControl = timescaleSegmentedControl {
            let trianglePath = UIBezierPath()
            let originPoint = CGPoint(x: (bounds.width - segmentedControl.triangleWidth) / 2, y: segmentedControl.bounds.height)
            trianglePath.moveToPoint(originPoint)
            trianglePath.addLineToPoint(CGPoint(x: trianglePath.currentPoint.x + segmentedControl.triangleWidth, y: trianglePath.currentPoint.y))
            trianglePath.addLineToPoint(CGPoint(x: bounds.width / 2, y: trianglePath.currentPoint.y + segmentedControl.triangleHeight))
            trianglePath.closePath()
            UIColor.whiteColor().setFill()
            trianglePath.fill()
        }
    }
}
