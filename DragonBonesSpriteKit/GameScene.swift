//
//  GameScene.swift
//  DragonBonesSpriteKit
//
//  Created by Salo on 16/6/23.
//  Copyright (c) 2016年 eitdesign. All rights reserved.
//

import SpriteKit
import SwiftyJSON

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        self.addChild(myLabel)
        
        let JSONPath = NSBundle.mainBundle().pathForResource("skeleton", ofType: "json")!
        let JSONData = NSData(contentsOfFile: JSONPath)!
        let json = JSON(data: JSONData)
        
//        let skeleton = Skeleton(json: json)
        let armature = Skeleton.Armature(json: json)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
