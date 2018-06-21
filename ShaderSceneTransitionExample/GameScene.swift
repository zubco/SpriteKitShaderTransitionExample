//
//  GameScene.swift
//  ShaderSceneTransitionExample
//
//  Created by Deon Botha on 13/07/2015.
//  Copyright (c) 2015 Deon Botha. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = SKColor.white
        
        var label = SKLabelNode(text: "Scene 1")
        label.fontColor = SKColor.black
        label.fontSize = 32
        label.position = CGPoint(x:size.width / 2,y: size.height / 2)
        self.addChild(label)
        
        label = SKLabelNode(text: "tap to transition")
        label.fontColor = SKColor.black
        label.fontSize = 24
        label.position = CGPoint(x:size.width / 2,y: size.height / 2 - 50)
        self.addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        // fake some loading delay then finish the shader transition
        let delayTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.completeShaderTransition()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.presentScene(scene: GameScene2(size: self.size), shaderName: "retro_transition_fade_from_top.fsh", transitionDuration: 1.0)
    }
   
    override func update(_ currentTime: CFTimeInterval) {
        self.updateShaderTransition(currentTime: currentTime)
    }
}
