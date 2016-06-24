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
    
    func loadNode(withName name: String) -> EDArmatureNode {
        return self.loadRequireArmature(name)
    }
    
    private func loadRequireArmature(name: String) -> EDArmatureNode {
        return EDArmatureNode(armature: armatureConfig[name]!, atlasDictionary: self.atlasDictionary, loader: self)
    }

}

extension SKAction {
    
    class func boneFrameAction(frame: [EDSkeleton.Armature.Animation.Bone.Frame]) -> SKAction {
        var sequenceActionArray: [SKAction] = []
        for theFrame in frame {
            let duration = theFrame.duration
            
            let positionAction = SKAction.moveTo(theFrame.transform.position, duration: duration)
            let scaleXAction = SKAction.scaleXTo(theFrame.transform.scX, duration: duration)
            let scaleYAction = SKAction.scaleYTo(theFrame.transform.scY, duration: duration)
            let zRotationAction = SKAction.rotateToAngle(theFrame.transform.zRotation, duration: duration)
            let groupAction = SKAction.group([positionAction, scaleXAction, scaleYAction, zRotationAction])
            sequenceActionArray.append(groupAction)
        }
        return SKAction.repeatActionForever(SKAction.sequence(sequenceActionArray))
    }
    
    class func slotFrameAction(frame: [EDSkeleton.Armature.Animation.Slot.Frame]) -> SKAction {
        var sequenceActionArray: [SKAction] = []
        for theFrame in frame {
            let duration = theFrame.duration
            let alphaAction = SKAction.fadeAlphaTo(theFrame.color.alpha, duration: duration)
            let displayIndex = theFrame.displayIndex
            let textureAction = SKAction.customActionWithDuration(duration, actionBlock: { (node: SKNode, elapsedTime: CGFloat) in
                if let node = node as? EDSlotNode {
                    node.displayIndex = displayIndex
                }
            })
            let groupAction = SKAction.group([alphaAction, textureAction])
            sequenceActionArray.append(groupAction)
        }
        return SKAction.repeatActionForever(SKAction.sequence(sequenceActionArray))
    }
    
}

class EDSlotNode: SKNode {
    var displayIndex: Int {
        didSet {
            self.reloadDisplayIndex()
        }
    }
    
    func reloadDisplayIndex() {
        for idx in 0 ..< self.children.count {
            let isCurrent = (idx == self.displayIndex)
            let node = self.children[idx]
            if isCurrent {
                switch node {
                case let n as EDArmatureNode:
                    self.transform = n.parentTransform!
                case let n as EDDisplayNode:
                    self.transform = n.parentTransform
                default:()
                }
            }
            node.hidden = !isCurrent
        }
    }
    
    init(slot: EDSkeleton.Armature.Slot) {
        self.displayIndex = slot.displayIndex
        
        super.init()
        
        self.name = slot.name
        self.zPosition = CGFloat(slot.z)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EDDisplayNode: SKSpriteNode {
    
    var parentTransform: EDSkeleton.Armature.Transform
    
    init(parentTransform: EDSkeleton.Armature.Transform, texture: SKTexture) {
        self.parentTransform = parentTransform
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EDArmatureNode: SKNode {
    
    var parentTransform: EDSkeleton.Armature.Transform?
    
    private var boneAnimationDictionary: [String: [String: SKAction]] = [:]
    private var slotAnimationDictionary: [String: [String: SKAction]] = [:]
    private var boneDictionary: [String: SKNode] = [:]
    private var slotDictionary: [String: EDSlotNode] = [:]
    
    init(armature: EDSkeleton.Armature, atlasDictionary: [String: SKTextureAtlas], loader: EDArmatureLoader, parentTransform: EDSkeleton.Armature.Transform? = nil) {
        
        self.parentTransform = parentTransform
        
        super.init()
        
        self.name = armature.name
        
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
            let slotNode = EDSlotNode(slot: slot)
            let parentNode = boneDictionary[slot.parent]!
            parentNode.addChild(slotNode)
            slotDictionary[slot.name] = slotNode
        }
        
        for animation in armature.animation {
            boneAnimationDictionary[animation.name] = [:]
            slotAnimationDictionary[animation.name] = [:]
            for bone in animation.bone {
                let action = SKAction.boneFrameAction(bone.frame)
                boneAnimationDictionary[animation.name]![bone.name] = action
            }
            
            for slot in animation.slot {
                let action = SKAction.slotFrameAction(slot.frame)
                slotAnimationDictionary[animation.name]![slot.name] = action
            }
        }
        
        for skin in armature.skin {
            for slot in skin.slot {
                let node = slotDictionary[slot.name]!
                for display in slot.display {
                    switch display.type {
                    case .image:
                        let components = display.name.componentsSeparatedByString("/")
                        let atlasName = components[0]
                        let textureName = components[1]
                        let atlas = atlasDictionary[atlasName]!
                        let texture = atlas.textureNamed(textureName)
                        
                        let spriteNode = EDDisplayNode(parentTransform: display.transform, texture: texture)
                        node.addChild(spriteNode)
                    case .armature:
                        let armatureNode = loader.loadRequireArmature(display.name)
                        armatureNode.parentTransform = display.transform
                        node.addChild(armatureNode)
                    }
                }
                node.reloadDisplayIndex()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playAnimation(name: String) {
        if let animation = self.boneAnimationDictionary[name] {
            for (_, node) in self.boneDictionary {
                if let action = animation[node.name!] {
                    node.runAction(action)
                }
            }
        }
        
        if let animation = self.slotAnimationDictionary[name] {
            for (_, node) in self.slotDictionary {
                if let action = animation[node.name!] {
                    node.runAction(action)
                }
            }
        }
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
    
    convenience init(bone: EDSkeleton.Armature.Bone) {
        self.init()
        
        self.name = bone.name
        self.transform = bone.transform
    }
    
}
