//
//  GameScene.swift
//  DuckPoo
//
//  Created by Adam Farmer on 10/4/20.
//  Copyright © 2020 Adam Farmer. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var score : Int
    var scoreLabel : SKLabelNode
    
    private var duck : SKSpriteNode?
    
    private var move = false
    private var travellingObjects : [TravellingObject]
    private var enemies : [TravellingObject]
    
    var running : Bool = false
    var ready : Bool = true
    
    var initialEnemieCount = 10
    
    //static let shared = MusicPlayer()
    var backgroundMusic: AVAudioPlayer?
    var gameOverSound: AVAudioPlayer?
    var jumpSound: AVAudioPlayer?
    var coinSound: AVAudioPlayer?
    
    var gameOverLabel : SKLabelNode
    var startLabel : SKLabelNode
    
    var readyTimer : Timer?
    

    var largeSize : Int
    
    required init?(coder aDecoder: NSCoder) {
        travellingObjects = []
        enemies = []
        score = 0
        
        let screenSize = UIScreen.main.bounds
        
        largeSize = Int((screenSize.width * screenSize.height) * 0.0002)
        
        scoreLabel = SKLabelNode.init(text: "")
        
        scoreLabel.fontSize = 23
        scoreLabel.fontName = "8BIT WONDER"
        scoreLabel.position = CGPoint.init(x: 0, y: 180)
        scoreLabel.zPosition = 2
        
        gameOverLabel = SKLabelNode.init(text: "Game Over")
        gameOverLabel.fontSize = 40
        gameOverLabel.fontName = "8BIT WONDER"
        gameOverLabel.position = CGPoint.init(x: 0, y: screenSize.height / 15)
        gameOverLabel.isHidden = true
        gameOverLabel.zPosition = 2
        
        startLabel = SKLabelNode.init(text: "Tap to start")
        startLabel.fontSize = 20
        startLabel.fontName = "8BIT WONDER"
        startLabel.position = CGPoint.init(x: 0, y: (screenSize.height / 15) * -1)
        startLabel.run(SKAction.repeatForever(SKAction.sequence([ SKAction.fadeOut(withDuration: 0.01), SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 0.01), SKAction.wait(forDuration: 0.5) ])))
        startLabel.zPosition = 2
        
        
        super.init(coder: aDecoder)
        
        
        
        updateScore()
        self.addChild(scoreLabel)
        self.addChild(gameOverLabel)
        self.addChild(startLabel)
        
        for _ in 0..<initialEnemieCount {
            let cloud = Cloud.init(bounds: UIScreen.main.bounds)
            cloud.sprite.zPosition = 0
            travellingObjects.append(cloud)
            self.addChild(cloud.sprite)
        }
        
        setupAudio()
        
        createPlayer()
    }
    
    func start() {
        running = true
        resetEnemies()
        
        startLabel.isHidden = true
        gameOverLabel.isHidden = true
        
        backgroundMusic!.currentTime = 0
        backgroundMusic!.play()
        
        score = 0
        updateScore()
    }
            
    func end() {
        running = false
        ready = false
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block:
        { timer in
            self.ready = true
            self.startLabel.isHidden = false
        })
        
        gameOverLabel.isHidden = false
        gameOverLabel.isHidden = false
        backgroundMusic!.stop()
        gameOverSound!.play()
    }
    
    func resetEnemies() {
        let count = enemies.count
        for i in 0..<count {
            enemies[i].sprite.removeFromParent()
        }
        enemies.removeAll()
        
        for _ in 0..<initialEnemieCount {
            let poo = Poo.init(bounds: UIScreen.main.bounds, resetFunc: {
                object in
                self.coinSound!.play()
                self.score += 1
                self.updateScore()
            
                let point = SKLabelNode.init(text: "+ 1")
                point.fontName = "8BIT WONDER"
                point.fontSize = 20
                point.position = CGPoint(x: ((UIScreen.main.bounds.width / 2) * -1) + 10, y: object.sprite.position.y)
                point.zPosition = 2
                point.run(SKAction.fadeAlpha(to: 0, duration: 0.5),completion: { point.removeFromParent() })
                point.run(SKAction.scale(by: 1.5, duration: 0.5))
                self.addChild(point)
            })
            poo.sprite.zPosition = 1
            enemies.append(poo)
            self.addChild(poo.sprite)
        }
    }
    
    func updateScore() {
        scoreLabel.text = "Score: \(score)"
    }
    
    func setupAudio() {
        backgroundMusic = createAudioPlayer(filename: "backgroundmusic", filetype: "mp3")
        backgroundMusic!.numberOfLoops = -1
        
        gameOverSound = createAudioPlayer(filename: "gameover", filetype: "wav")
        jumpSound = createAudioPlayer(filename: "jump", filetype: "wav")
        jumpSound?.volume = 0.1
        
        coinSound = createAudioPlayer(filename: "coin", filetype: "wav")
    }
    
    func createAudioPlayer(filename: String, filetype: String) -> AVAudioPlayer {
        if let bundle = Bundle.main.path(forResource: filename, ofType: filetype) {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf:NSURL(fileURLWithPath: bundle) as URL)
                audioPlayer.prepareToPlay()
                return audioPlayer
            } catch {
                return AVAudioPlayer()
            }
        }
        return AVAudioPlayer()
    }
    
    func createPlayer() {
        let duck = SKSpriteNode.init(imageNamed: "8bitduck")
        duck.size = CGSize.init(width: largeSize, height: largeSize)
        duck.position = CGPoint.init(x: self.size.height * 0.25 * -1, y: UIScreen.main.bounds.width * 0.24 * -1)
        duck.physicsBody = SKPhysicsBody.init(circleOfRadius: 25)
        duck.physicsBody!.categoryBitMask = 0b0010
        duck.physicsBody!.collisionBitMask = 0
        duck.physicsBody!.contactTestBitMask = 0b0001
        duck.physicsBody!.isDynamic = true
        duck.zPosition = 2
        self.addChild(duck)
        self.duck = duck
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if running {
            end()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !running && ready {
            start()
        } else if running {
            jumpSound?.play()
            self.move = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.move = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let maxUp = UIScreen.main.bounds.width * 0.24
        let maxDown = UIScreen.main.bounds.width * 0.24 * -1
        
        for i in 0..<travellingObjects.count {
            travellingObjects[i].move()
        }
        
        if running {
            if move && duck!.position.y < maxUp {
                if let duck = self.duck {
                    duck.position = duck.position.applying(CGAffineTransform.init(translationX: 0, y: 4))
                }
            }
            
            if !move && duck!.position.y > maxDown {
                if let duck = self.duck {
                    duck.position = duck.position.applying(CGAffineTransform.init(translationX: 0, y: -4))
                }
            }
            
            for i in 0..<enemies.count {
                enemies[i].move()
            }
        }
    }
}
