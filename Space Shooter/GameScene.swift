//
//  GameScene.swift
//  Space Shooter
//
//  Created by Viorel Harabaru  on 26.03.2024.
//

// testing xCode

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // DECLARING GAME ABSTRACTIONS (objects - what we really have)
    var starfield: SKEmitterNode! // this an animation type
    var player: SKSpriteNode! // some kind of visual type
    var scoreLabel: SKLabelNode! // making the score LABEL
    var score: Int = 0 {
        // [!] IMPORTANT: everytime the score val is updated, we update the scoreLabel with some text and the score itself;
        didSet { scoreLabel.text = "Score \(score)" }
    }
    var gameTimer: Timer!
    var aliens = ["alien", "alien2", "alien3"]
    
    let alienCategory: UInt32 = 0x1 << 1  // some bit, low level shit computation
    let bulletCategory: UInt32 = 0x1 << 0 // this is assignemd to physicsBody?.categoryBitMask
    
    // FUNCTIONAL
    @objc func addAlien() {
        // FUNCTION CREATES A RANDOM ALIEN
        
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0]) // taking first element from the array;
        let randomPos = GKRandomDistribution(lowestValue: -350, highestValue: 350)
        let pos = CGFloat(randomPos.nextInt())
        
        // defining the alien position on the screen:
        alien.position = CGPoint(x: pos, y: 800)
        alien.setScale(2)
        
        // PHYSICS:
        // defining alien as a physical object with a rectangle matching its size:
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true; // in case if exists, alien is dynamic - can react to stuff;
        // defining the behaviour fo colision (categories):
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        // adding the final alien to the screen:
        self.addChild(alien)
        
        let animDuration: TimeInterval = 6 // animation duration;
        var actions = [SKAction]() // Its an array of SKAction type objects;
        
        actions.append(SKAction.move(to: CGPoint(x: pos, y: -800), duration: animDuration))
        actions.append(SKAction.removeFromParent()) // removing the object when we are outside of the screen
        
        alien.run(SKAction.sequence(actions))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // when touch ends fireBullet() is called:
        fireBullet()
    }
    
    func fireBullet () {
        // FIXME: This code is repeated as in addAlien(); Check if you can fix:
        
        // setting bullet sound:
        self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
        
        // creating the bullet and assigning it an image:
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        
        // positioning the bullet:
        bullet.position = player.position // bullet position matches player position;
        bullet.position.y += 5 // adding 5 pixels to y (after its set to player position);
        
        // DEFINING PHYSICS:
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        bullet.setScale(2)
        
        // defining behaviour for colision (categories):
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        
        bullet.physicsBody?.usesPreciseCollisionDetection = true // can colide with an object;
        
        // adding the final alien to the screen:
        self.addChild(bullet)
        
        let animDuration: TimeInterval = 0.3 // animation duration
        
         // [!] in actions we will store all actions we will store all actions performed on an object;
        // it seems like swift READS this array and performs this ctions sequentially;
        var actions = [SKAction]()
    
        // moving the object and removing it when it reaches the end of the screen:
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: 800), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        
        bullet.run(SKAction.sequence(actions))
        
    }
    
    
    
    override func didMove(to view: SKView) {
        
        // DEFINING PHYSICS OF THE GAME
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // Setting gravity to 0;
        self.physicsWorld.contactDelegate = self // allows to implement methods when physical objects colide;
        
        // CREATING THE BACKGROUND:
        starfield = SKEmitterNode(fileNamed: "Starfield") // importing the file
        starfield.position = CGPoint(x: 0, y: 1472) // settting the position of the background;
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1 // similar to z-index in CSS;
        self.addChild(starfield) // adding the object to the screen;
        
        // CREATING THE STARSHIP (player):
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: 0, y: -300)
        player.setScale(2)
        self.addChild(player)
        
        // CREATING THE SCORE LABEL:
        scoreLabel = SKLabelNode(text: "Score: 0") // creating the label;
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 56
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: -200, y: 500)
        
        score = 0 // just nulifying score;
        
        self.addChild(scoreLabel)
        
        // addAlien() is called at certain specific intervals:
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
