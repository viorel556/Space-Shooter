//
//  GameScene.swift
//  Space Shooter
//
//  Created by Viorel Harabaru  on 26.03.2024.
//

// testing xCode

import SpriteKit
import GameplayKit
import CoreMotion

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
    
    // Creating accelerometer: (the thing to change the position of screen by playing with the phone)
    let motionManager = CMMotionManager()
    var xAccelerate: CGFloat = 0
    
    
    // FUNCTIONAL
    func didBegin(_ contact: SKPhysicsContact) {
        // Writing a func to define the contact behaviour when 2 objects collide:
        var alienBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        }
        else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        
        // IF alien and a bullet colides we do following:
        if (alienBody.categoryBitMask & alienCategory) != 0
            &&
            (bulletBody.categoryBitMask & bulletCategory) != 0
        {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode,
                              alienNode: alienBody.node as! SKSpriteNode)
        }
    }
    
    
    func collisionElements(bulletNode: SKSpriteNode, alienNode: SKSpriteNode) {
        // function is called when 2 objects colide:
        
        let explosion = SKEmitterNode(fileNamed: "Explosion") // creating the explosion animation;
        explosion?.position = alienNode.position // explosion position matches the alien position;
        self.addChild(explosion!) // not sure is ok to forcefully unwrap here;
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent() // clean up
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        score += 5 // on collision changing the score; 
    }
    
    @objc func addAlien() {
        // FUNCTION CREATES A RANDOM ALIEN
        
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0]) // taking first element from the array;
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
        let pos = CGFloat(randomPos.nextInt())
        
        // defining the alien position on the screen:
        alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)
        
        
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
        
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))
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
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
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
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 40)
        
        self.addChild(player)
        
        // CREATING THE SCORE LABEL:
        scoreLabel = SKLabelNode(text: "Score: 0") // creating the label;
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.height - 50)
        
        score = 0 // nulifying score;
        
        self.addChild(scoreLabel)
        
        // addAlien() is called at certain specific intervals:
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        // IMPLEMENTING ACCELEROMETER:
        motionManager.accelerometerUpdateInterval = 0.2 // 200 miliseconds
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            
            if let accelerometerData = data { 
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x * 0.75 + Double(self.xAccelerate) * 0.25)
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50 // setup speed;
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
        }
        else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y: player.position.y)
        }
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
