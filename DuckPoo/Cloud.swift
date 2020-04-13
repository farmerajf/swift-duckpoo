//
//  Cloud.swift
//  DuckPoo
//
//  Created by Adam Farmer on 11/4/20.
//  Copyright © 2020 Adam Farmer. All rights reserved.
//

import SpriteKit

class Cloud : TravellingObject {
    init(bounds: CGRect) {
        super.init(bounds: bounds, imageName: "8bitcloud", resetFunc: {_ in})
        
        let scale = Double(arc4random_uniform(2)) + 1
        speed = scale * -1
        
        let baseSize = (screenWidth * screenHeight) * 0.0001
        let size = scale * baseSize
        self.sprite.size = CGSize.init(width: size * 1.7, height: size)
    }
}
