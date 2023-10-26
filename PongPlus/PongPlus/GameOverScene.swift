//
//  GameOverScene.swift
//  PongPlus
//
//  Created by Alumno on 26/10/23.
//

import SpriteKit

class GameOverScene: SKScene {
  init(size: CGSize, won:Bool) {
    super.init(size: size)
    
    // 1
    backgroundColor = SKColor(red: 46 / 255.0, green: 58 / 255.0, blue: 59 / 255.0, alpha: 1)
    
    // 2
    let message = won ? "Ganaste!" : "Perdiste :["
    
    // 3
    let label = SKLabelNode(fontNamed: "Verdana")
    label.text = message
    label.fontSize = 40
      label.fontColor = SKColor.white
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    
    // 4
    run(SKAction.sequence([
      SKAction.wait(forDuration: 3.0),
      SKAction.run() { [weak self] in
        // 5
        guard let `self` = self else { return }
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
      }
      ])
    )
  }
  
  // 6
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
