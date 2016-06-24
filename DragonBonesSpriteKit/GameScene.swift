//
//  GameScene.swift
//  DragonBonesSpriteKit
//
//  Created by Salo on 16/6/23.
//  Copyright (c) 2016年 eitdesign. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        
        let JSONPath = NSBundle.mainBundle().pathForResource("skeleton", ofType: "json")!
        let atlasName = "injuredfarmer_F"
        let atlasDictionary = ["injuredfarmer_F": SKTextureAtlas(named: atlasName)]
        let loader = EDArmatureLoader(filePath: JSONPath, atlasDictionary: atlasDictionary)
        
        let node = loader.loadNode(withName: "injuredfarmer")
        node.playAnimation("idle")
        self.addChild(node)
        
    }
}
