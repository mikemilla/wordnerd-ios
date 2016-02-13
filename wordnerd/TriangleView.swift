//
//  TriangleView.swift
//  wordnerd
//
//  Created by Michael Miller on 2/10/16.
//  Copyright © 2016 Michael Miller. All rights reserved.
//

import UIKit

class TriangleView: UIView {
    
    var color:UIColor = UIColor.blackColor()

    override func drawRect(rect: CGRect) {
        
        // Get Height and Width
        let layerHeight = self.layer.frame.height
        let layerWidth = self.layer.frame.width
        
        // Create Path
        let bezierPath = UIBezierPath()
        
        // Draw Points
        bezierPath.moveToPoint(CGPointMake(layerHeight, layerHeight))
        bezierPath.addLineToPoint(CGPointMake(layerWidth, 0))
        bezierPath.addLineToPoint(CGPointMake(0, 0))
        
        // Apply Color
        color.setFill()
        bezierPath.fill()
        
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.CGPath
        self.layer.mask = shapeLayer
    }

}
