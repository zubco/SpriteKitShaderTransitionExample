//
//  SKScene+ShaderTransition.swift
//  ShaderSceneTransitionExample
//
//  Created by Deon Botha on 15/07/2015.
//  Copyright (c) 2015 Deon Botha. All rights reserved.
//

import Foundation
import SpriteKit

//private let totalAnimationDuration = 1.0
private let kNodeNameTransitionShaderNode = "kNodeNameTransitionShaderNode"
private let kNodeNameFadeColourOverlay = "kNodeNameFadeColourOverlay"
private var presentationStartTime: CFTimeInterval = -1
private var shaderChoice = -1

extension SKScene {
    
    private var transitionShader: SKShader? {
        get {
            if let shaderContainerNode = self.childNode(withName: kNodeNameTransitionShaderNode) as? SKSpriteNode {
                return shaderContainerNode.shader
            }
            
            return nil
        }
    }
    
    private func createShader(shaderName: String, transitionDuration: TimeInterval) -> SKShader {
        var shader = SKShader(fileNamed:shaderName)
        var u_size = SKUniform(name: "u_size", float: GLKVector3Make(Float(UIScreen.main.scale * size.width), Float(UIScreen.main.scale * size.height), Float(0)))
        var u_fill_colour = SKUniform(name: "u_fill_colour", float: GLKVector4Make(131.0 / 255.0, 149.0 / 255.0, 255.0 / 255.0, 1.0))
        var u_border_colour = SKUniform(name: "u_border_colour", float: GLKVector4Make(104.0 / 255.0,119.0 / 255.0,204.0 / 255.0, 1.0))
        var u_total_animation_duration = SKUniform(name: "u_total_animation_duration", float: Float(transitionDuration))
        var u_elapsed_time = SKUniform(name: "u_elapsed_time", float: Float(0))
        shader.uniforms = [u_size, u_fill_colour, u_border_colour, u_total_animation_duration, u_elapsed_time]
        return shader
    }
    
    func presentScene(scene: SKScene?, shaderName: String, transitionDuration: TimeInterval) {
        // Create shader and add it to the scene
        var shaderContainer = SKSpriteNode(imageNamed: "dummy")
        shaderContainer.name = kNodeNameTransitionShaderNode
        shaderContainer.zPosition = 9999 // something arbitrarily large to ensure it's in the foreground
        shaderContainer.position = CGPoint(x:size.width / 2, y: size.height / 2)
        shaderContainer.size = CGSize(width:size.width,height: size.height)
        shaderContainer.shader = createShader(shaderName: shaderName, transitionDuration:transitionDuration)
        self.addChild(shaderContainer)
        
        // remove the shader from the scene after its animation has completed.
        let delayTime = DispatchTime.now() + transitionDuration
        
        
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            var fadeOverlay = SKShapeNode(rect: CGRect(x:0,y: 0, width:self.size.width, height: self.size.height))
            fadeOverlay.name = kNodeNameFadeColourOverlay
            fadeOverlay.fillColor = SKColor(red: 131.0 / 255.0, green: 149.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
            fadeOverlay.zPosition = shaderContainer.zPosition
            scene!.addChild(fadeOverlay)
            self.view?.presentScene(scene)
        }
        
        // Reset the time presentScene was called so that the elapsed time from now can
        // be calculated in updateShaderTransitions(currentTime:)
        presentationStartTime = -1
    }
    
    func updateShaderTransition(currentTime: CFTimeInterval) {
        if let shader = self.transitionShader {
            let elapsedTime = shader.uniformNamed("u_elapsed_time")!
            if (presentationStartTime < 0) {
                presentationStartTime = currentTime
            }
            elapsedTime.floatValue = Float(currentTime - presentationStartTime)
        }
    }
    
    
    // this function is called by the scene being transitioned to when it's ready to have the view faded in to the scene i.e. loading is complete, etc.
    func completeShaderTransition() {
        if let fadeOverlay = self.childNode(withName: kNodeNameFadeColourOverlay) {
            fadeOverlay.run(SKAction.sequence([SKAction.fadeAlpha(to: 0, duration: 0.3), SKAction.removeFromParent()]))
        }
    }
    
    
    
}
