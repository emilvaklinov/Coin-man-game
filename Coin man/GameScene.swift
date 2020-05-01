//
//  GameScene.swift
//  Coin man
//
//  Created by Emil Vaklinov on 01/05/2020.
//  Copyright © 2020 Emil Vaklinov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
   var coinMan: SKSpriteNode?
    var coinTimer: Timer?
    var bombTimer: Timer?
    var ground: SKSpriteNode?
    var ceil: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var finalScoreLabel: SKLabelNode?
    
    
    let coinManCategory : UInt32 = 0x1 << 1
    let coinCategory : UInt32 = 0x1 << 2
    let bombCategory : UInt32 = 0x1 << 3
    let groundAndCeilCategory : UInt32 = 0x1 << 4
//    let bombCategory : UInt32 = 0x1 << 5
    
    var score = 0
    
    override func didMove(to view: SKView) {
         
        physicsWorld.contactDelegate = self
        coinMan = childNode(withName: "coinMan") as? SKSpriteNode
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
//        coinMan?.physicsBody?.collisionBitMask = groundAndCeilCategory
        var coinManRun: [SKTexture] = []
        for number in 1...5 {
            coinManRun.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.05)))
        
        ground = childNode(withName: "ground") as? SKSpriteNode
//        ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ground?.physicsBody?.categoryBitMask = coinManCategory
        
        ceil = childNode(withName: "ceil") as? SKSpriteNode
//        ceil?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceil?.physicsBody?.categoryBitMask = coinManCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
   

      startTimers()
      createGrass()
    }
    
    func createGrass() {
        
    }
    
    func startTimers() {
        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                   self.createCoin()
               })
               
               bombTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                   self.createBomb()
               })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scene?.isPaused == false {
        coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
        }
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            
            for node in theNodes {
                if node.name == "play" {
                    score = 0
                    node.removeFromParent()
                    finalScoreLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    startTimers()
                }
            }
        }
        }
    
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "business")
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        addChild(coin)
        
        let maxY = size.height / 2 - coin.size.height / 2
        let minY = -size.height / 2 + coin.size.height / 2
        let range = maxY - minY
        let coinY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        coin.position = CGPoint(x: size.width / 2 + coin.size.width / 2, y: coinY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - coin.size.width, y: 0, duration: 4)
        
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
        }
    
    func createBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        addChild(bomb)
        
        let maxY = size.height / 2 - bomb.size.height / 2
        let minY = -size.height / 2 + bomb.size.height / 2
        let range = maxY - minY
        let bombY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        bomb.position = CGPoint(x: size.width / 2 + bomb.size.width / 2, y: bombY)
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width, y: 0, duration: 4)
        
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == coinCategory {
            contact.bodyA.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        if contact.bodyB.categoryBitMask == coinCategory {
            contact.bodyB.node?.removeFromParent()
            score += 1
            scoreLabel?.text = "Score: \(score)"
        }
        if contact.bodyA.categoryBitMask == bombCategory {
            contact.bodyA.node?.removeFromParent()
            gameOver()
        }
        if contact.bodyB.categoryBitMask == bombCategory {
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
        
    }
    func gameOver() {
        scene?.isPaused = true
        
        coinTimer?.invalidate()
        bombTimer?.invalidate()
        
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 70
        yourScoreLabel?.zPosition = 1
//        yourScoreLabel.color = UIColor.red
        if yourScoreLabel != nil {
        addChild(yourScoreLabel!)
        }
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if finalScoreLabel != nil {
        addChild(finalScoreLabel!)
        }
        let playButton = SKSpriteNode(imageNamed: "play")
        playButton.position = CGPoint(x: 0, y: -200)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
    }
}

