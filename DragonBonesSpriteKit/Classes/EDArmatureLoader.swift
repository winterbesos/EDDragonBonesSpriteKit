//
//  ArmatureLoader.swift
//  DragonBonesSpriteKit
//
//  Created by Salo on 16/6/24.
//  Copyright © 2016年 eitdesign. All rights reserved.
//

import SpriteKit
import SwiftyJSON

class EDArmatureLoader {
    
    var armatureConfig: [String: EDSkeleton.Armature] = [:]
    let atlasDictionary: [String: SKTextureAtlas]
    
    init(filePath: String, atlasDictionary: [String: SKTextureAtlas]) {
        self.atlasDictionary = atlasDictionary
        
        let JSONData = NSData(contentsOfFile: filePath)!
        let json = JSON(data: JSONData)
        
        let skeleton = EDSkeleton(json: json)
        
        for armature in skeleton.armature {
            armatureConfig[armature.name] = armature
        }
    }
    
    func loadNode(withName name: String) -> SKNode {
        return self.loadRequireArmature(name)
    }
    
    private func loadRequireArmature(name: String) -> SKNode {
        return SKNode(armature: armatureConfig[name]!, atlasDictionary: self.atlasDictionary, loader: self)
    }

}

extension SKNode {
    
    var transform: EDSkeleton.Armature.Transform {
        set {
            self.xScale = CGFloat(newValue.scX)
            self.yScale = CGFloat(newValue.scY)
            self.position = newValue.position
            self.zRotation = newValue.zRotation
        }
        
        get {
            return EDSkeleton.Armature.Transform(scX: self.xScale,
                                               scY: self.yScale,
                                               zRotation: self.zRotation,
                                               position: self.position)
        }
    }
    
    convenience init(slot: EDSkeleton.Armature.Slot) {
        self.init()
        
        self.name = slot.name
        self.zPosition = CGFloat(slot.z)
    }
    
    convenience init(bone: EDSkeleton.Armature.Bone) {
        self.init()
        
        self.name = bone.name
        self.transform = bone.transform
    }
    
    convenience init(armature: EDSkeleton.Armature, atlasDictionary: [String: SKTextureAtlas], loader: EDArmatureLoader) {
        self.init()
        
        self.name = armature.name
        
        var boneDictionary: [String: SKNode] = [:]
        var slotDictionary: [String: SKNode] = [:]
        
        for bone in armature.bone {
            let boneNode = SKNode(bone: bone)
            
            let parentNode: SKNode
            if let parentName = bone.parent {
                parentNode = boneDictionary[parentName]!
            } else {
                parentNode = self
            }
            parentNode.addChild(boneNode)
            boneDictionary[bone.name] = boneNode
        }
        
        for slot in armature.slot {
            let slotNode = SKNode(slot: slot)
            let parentNode = boneDictionary[slot.parent]!
            parentNode.addChild(slotNode)
            slotDictionary[slot.name] = slotNode
        }
        
        for skin in armature.skin {
            for slot in skin.slot {
                for display in slot.display {
                    let node = slotDictionary[slot.name]!
                    node.transform = display.transform
                    
                    switch display.type {
                    case .image:
                        let components = display.name.componentsSeparatedByString("/")
                        let atlasName = components[0]
                        let textureName = components[1]
                        let atlas = atlasDictionary[atlasName]!
                        let texture = atlas.textureNamed(textureName)
                        
                        let spriteNode = SKSpriteNode(texture: texture)
                        node.addChild(spriteNode)
                    case .armature:
                        node.addChild(loader.loadRequireArmature(display.name))
                    }
                }
            }
        }
    }
}
