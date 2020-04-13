//
//  Poo.swift
//  DuckPoo
//
//  Created by Adam Farmer on 10/4/20.
//  Copyright © 2020 Adam Farmer. All rights reserved.
//

import Foundation
import SpriteKit

class Poo : TravellingObject {
    init(bounds: CGRect, resetFunc: @escaping (TravellingObject) -> Void) {
        super.init(bounds: bounds, imageName: "8bitpoo", resetFunc: resetFunc)
        
        speed = (Double(arc4random_uniform(5)) + 1) * -1
        
        let baseSize = (screenWidth * screenHeight) * 0.0001
        let size = (Double(arc4random_uniform(3) + 1)) * baseSize
        self.sprite.size = CGSize.init(width: size, height: size)
        
        sprite.physicsBody = SKPhysicsBody.init(circleOfRadius: CGFloat(size / 3), center: CGPoint(x: 0, y: -7))
        sprite.physicsBody!.categoryBitMask = 0b0001
        sprite.physicsBody!.collisionBitMask = 0
        sprite.physicsBody!.contactTestBitMask = 0b0010
        sprite.physicsBody!.isDynamic = true
    }
}
