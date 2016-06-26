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
    
    init(filePath: String) {
        
        let JSONData = NSData(contentsOfFile: filePath)!
        let json = JSON(data: JSONData)
        
        let skeleton = EDSkeleton(json: json)
        
        for armature in skeleton.armature {
            armatureConfig[armature.name] = armature
        }
    }
    
    func loadNode(named name: String) -> EDArmatureNode {
        return self.loadRequireArmature(name)
    }
    
    private func loadRequireArmature(name: String) -> EDArmatureNode {
        return EDArmatureNode(armature: armatureConfig[name]!, loader: self)
    }

}

extension SKAction {
    
    class func boneFrameAction(frame: [EDSkeleton.Armature.Animation.Bone.Frame], duration: NSTimeInterval) -> SKAction {
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
        let sequenceAction = SKAction.sequence(sequenceActionArray)
        sequenceAction.duration = duration
        return SKAction.repeatActionForever(sequenceAction)
    }
    
    class func slotFrameAction(frame: [EDSkeleton.Armature.Animation.Slot.Frame], node: EDSlotNode, duration: NSTimeInterval) -> SKAction {
        var sequenceActionArray: [SKAction] = []
        
        for theFrame in frame {
            var actionArray: [SKAction] = []
            let displayAction = node.displayAction(theFrame.displayIndex)
            
            let duration = theFrame.duration
            if theFrame.displayIndex != -1 {
                let alphaAction = SKAction.fadeAlphaTo(theFrame.color.alpha, duration: duration)
                actionArray.append(alphaAction)
            } else {
                actionArray.append(SKAction.waitForDuration(duration))
            }
            actionArray.append(displayAction)
            let groupAction = SKAction.group(actionArray)
            sequenceActionArray.append(groupAction)
        }
        let sequenceAction = SKAction.sequence(sequenceActionArray)
        sequenceAction.duration = duration
        return SKAction.repeatActionForever(sequenceAction)
    }
    
}

class EDSlotNode: SKNode {
    
    func displayAction(index: Int) -> SKAction {
        var actionArray: [SKAction] = []
        for idx in 0 ..< self.children.count {
            let isCurrent = (idx == index)
            let node = self.children[idx]
        
            let displayAction = SKAction.runBlock({
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
            })
            actionArray.append(displayAction)
        }
        
        return SKAction.group(actionArray)
    }
    
    init(slot: EDSkeleton.Armature.Slot) {
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
    
    init(armature: EDSkeleton.Armature, loader: EDArmatureLoader, parentTransform: EDSkeleton.Armature.Transform? = nil) {
        
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
        
        for skin in armature.skin {
            for slot in skin.slot {
                let node = slotDictionary[slot.name]!
                for i in 0 ..< slot.display.count {
                    let display = slot.display[i]
                    switch display.type {
                    case .image:
                        let components = display.name.componentsSeparatedByString("/")
                        let atlasName = components[0]
                        let textureName = components[1].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
                        let atlas = SKTextureAtlas(named: atlasName)
                        let texture = atlas.textureNamed(textureName)
                        
                        let spriteNode = EDDisplayNode(parentTransform: display.transform, texture: texture)
                        node.addChild(spriteNode)
                    case .armature:
                        let armatureNode = loader.loadRequireArmature(display.name)
                        armatureNode.parentTransform = display.transform
                        node.addChild(armatureNode)
                    }
                }
            }
        }
        
        for animation in armature.animation {
            boneAnimationDictionary[animation.name] = [:]
            slotAnimationDictionary[animation.name] = [:]
            for bone in animation.bone {
                let action = SKAction.boneFrameAction(bone.frame, duration: animation.duration)
                boneAnimationDictionary[animation.name]![bone.name] = action
            }
            
            for slot in animation.slot {
                let node = slotDictionary[slot.name]!
                let action = SKAction.slotFrameAction(slot.frame, node: node, duration: animation.duration)
                slotAnimationDictionary[animation.name]![slot.name] = action
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
