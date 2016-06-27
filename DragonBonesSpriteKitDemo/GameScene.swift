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
        node.playAnimation("idle")
        node.position = CGPoint(x: -200, y: 0)
        self.addChild(node)
        
        let JSONPath2 = NSBundle.mainBundle().pathForResource("skeleton2", ofType: "json")!
        let loader2 = EDArmatureLoader(filePath: JSONPath2)
        let node2 = loader2.loadNode(named: "class1_earth")
        node2.playAnimation("idle")
        node2.position = CGPoint(x: 200, y: 0)
        self.addChild(node2)
        
    }
    
}
