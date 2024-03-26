//
//  GameScene.swift
//  Space Shooter
//
//  Created by Viorel Harabaru  on 26.03.2024.
//

// testing xCode
// testing xCode x2 

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
        
        // CREATING THE PLAYER:
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: 0, y: -300)
        self.addChild(player)
        
        // CREATING THE SCORE LABEL:
        scoreLabel = SKLabelNode(text: "Score: 0") // creating the label;
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 56
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: -200, y: 500)

        score = 0 // just nulifying score;
        
        self.addChild(scoreLabel)
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
