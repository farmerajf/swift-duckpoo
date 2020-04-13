//
//  TravellingObject.swift
//  DuckPoo
//
//  Created by Adam Farmer on 11/4/20.
//  Copyright © 2020 Adam Farmer. All rights reserved.
//

import SpriteKit

class TravellingObject {
    var speed : Double
    
    var sprite : SKSpriteNode
    
    var screenWidth : Double
    var screenHeight : Double
    
    var leftEdge : Double
    
    var resetFunc : (TravellingObject) -> Void
    
    init(bounds: CGRect, imageName: String, resetFunc: @escaping (TravellingObject) -> Void) {
        self.resetFunc = resetFunc
        
        screenWidth = Double(bounds.width)
        screenHeight = Double(bounds.height)
        leftEdge = (screenWidth / 2) * -1
        
        speed = 0
        sprite = SKSpriteNode.init(imageNamed: imageName)
        resetPosition()
    }
    
    func resetPosition() {
        let x = screenWidth + Double(arc4random_uniform(UInt32(screenWidth) * 2))
        let y = Double(arc4random_uniform(UInt32(screenHeight))) - (screenHeight / 2)
        sprite.position = CGPoint.init(x:x, y: y)
    }
    
    func move() {
        self.sprite.position = self.sprite.position.applying(CGAffineTransform(translationX: CGFloat(speed), y: 0))
        
        let leftLimit = leftEdge - Double(sprite.size.width) / 2
        let spriteX = Double(sprite.position.x)
        if spriteX < leftLimit {
            resetFunc(self)
            resetPosition()
        }
    }
}
