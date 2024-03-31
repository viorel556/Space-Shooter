//
//  MainMenu.swift
//  Space Shooter
//
//  Created by Viorel Harabaru  on 30.03.2024.
//

import SpriteKit

class MainMenu: SKScene {
    
    var starfield: SKEmitterNode!
    
    var newGameBtnNode: SKSpriteNode!
    var levelBtnNode: SKSpriteNode!
    var labelLevelNode: SKLabelNode!
    
    override func didMove(to view: SKView) {
        
        // Initialization of our variables:
        starfield = self.childNode(withName: "starfieldAnim") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameBtnNode = self.childNode(withName: "newGameBtn") as? SKSpriteNode
        newGameBtnNode.texture = SKTexture(imageNamed: "button_new_game")
        
        levelBtnNode = self.childNode(withName: "levelBtn") as? SKSpriteNode
        levelBtnNode.texture = SKTexture(imageNamed: "button_dificulty")
        
        labelLevelNode = self.childNode(withName: "labelLevelBtn") as? SKLabelNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameBtn" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
}
