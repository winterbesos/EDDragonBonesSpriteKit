//
//  GameScene.swift
//  DragonBonesSpriteKit
//
//  Created by Salo on 16/6/23.
//  Copyright (c) 2016年 eitdesign. All rights reserved.
//

import SpriteKit
import EDDragonBonesSpriteKit

class GameScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        let JSONPath = NSBundle.mainBundle().pathForResource("skeleton", ofType: "json")!
        let loader = EDArmatureLoader(filePath: JSONPath)
        let node = loader.loadNode(named: "injuredfarmer")
        node.repeatAnimation("idle")
        node.position = CGPoint(x: -300, y: -50)
        self.addChild(node)
        
        let JSONPath2 = NSBundle.mainBundle().pathForResource("skeleton2", ofType: "json")!
        let loader2 = EDArmatureLoader(filePath: JSONPath2)
        let node2 = loader2.loadNode(named: "class1_earth")
        node2.repeatAnimation("idle")
        node2.position = CGPoint(x: 200, y: -10)
        self.addChild(node2)

        let JSONPath3 = NSBundle.mainBundle().pathForResource("monkey", ofType: "json")!
        let loader3 = EDArmatureLoader(filePath: JSONPath3)
        let node3 = loader3.loadNode(named: "monkey_1_01")
        node3.repeatAnimation("idle")
        node2.position = CGPoint(x: 300, y: 100)
        self.addChild(node3)
        
        let JSONPath4 = NSBundle.mainBundle().pathForResource("bird_2", ofType: "json")!
        let loader4 = EDArmatureLoader(filePath: JSONPath4)
        let node4 = loader4.loadNode(named: "bird_2")
        node4.repeatAnimation("idle")
        node4.position = CGPoint(x: 300, y: -200)
        self.addChild(node4)
        
    }
    
}
