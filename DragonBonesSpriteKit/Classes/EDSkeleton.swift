//
//  Skeleton.swift
//  DragonBonesSpriteKit
//
//  Created by Salo on 16/6/23.
//  Copyright © 2016年 eitdesign. All rights reserved.
//

import SpriteKit
import SwiftyJSON

struct EDSkeleton {
    struct Armature {
        struct Transform {
            let scX: CGFloat
            let scY: CGFloat
            let zRotation: CGFloat
            let position: CGPoint
            
            init(json: JSON) {
                let skX = json["skX"].double ?? 0
                let skY = json["skY"].double ?? 0
                let x = CGFloat(json["x"].double ?? 0)
                let y = -CGFloat(json["y"].double ?? 0)
                scX = CGFloat(json["scX"].double ?? 1)
                scY = CGFloat(json["scY"].double ?? 1)
                zRotation = -CGFloat(((skX + skY) / 2 ?? 0) * M_PI) / 180
                position = CGPoint(x: x, y:y)
            }
            
            init(scX: CGFloat, scY: CGFloat, zRotation: CGFloat, position: CGPoint) {
                self.scX = scX
                self.scY = scY
                self.zRotation = zRotation
                self.position = position
            }
        }
        
        struct Bone {
            var transform: Transform
            var name: String
            var parent: String?
            
            init(json: JSON) {
                transform = Transform(json: json["transform"])
                name = json["name"].string!
                parent = json["parent"].string
            }
        }
        
        struct Action {
            var gotoAndPlay: String
        }
        
        struct IK {
            
        }
        
        struct Skin {
            struct Slot {
                struct Display {
                    enum Type: String {
                        case image
                        case armature
                    }
                    
                    let type: Type
                    let transform: Transform
                    let name: String
                    
                    init(json: JSON) {
                        type = Type(rawValue: json["type"].string!)!
                        name = json["name"].string!
                        transform = Transform(json: json["transform"])
                    }
                    
                }
                
                let display: [Display]
                let name: String
                
                init(json: JSON) {
                    var theDisplay: [Display] = []
                    for item in json["display"].array ?? [] {
                        theDisplay.append(Display(json: item))
                    }
                    display = theDisplay
                    name = json["name"].string!
                }
                
            }
            
            let name: String
            let slot: [Slot]
            
            init(json: JSON) {
                name = json["name"].string!
                var theSolt: [Slot] = []
                for item in json["slot"].array ?? [] {
                    theSolt.append(Slot(json: item))
                }
                slot = theSolt
            }
            
        }
        
        struct Animation {
            
            struct Bone {
                struct Frame {
                    var tweenEasing: Int?
                    var transform: Transform
                    var duration: Int
                }
                
                var frame: [Frame]
                var name: String
            }
            
            struct Slot {
                struct Frame {
                    struct Color {
                        
                    }
                    
                    var tweenEasing: Int?
                    var color: Color
                    var duration: Int
                }
                
                var name: String
                var frame: [Frame]
            }
            
            struct FFD {
                
            }
            
            var bone: [Bone]
            var duration: Int
            var frame: [AnyObject] // todo
            var playTimes: Int
            var slot: [Slot]
            var name: String
            var ffd: [FFD]
        }
        
        struct Slot {
            let name: String
            let parent: String
            let z: Int
            
            init(json: JSON) {
                name = json["name"].string!
                parent = json["parent"].string!
                z = json["z"].int ?? 0
            }
        }
        
        let type: String
        let name: String
        let frameRate: Int
        let bone: [Bone]
        let skin: [Skin]
        let slot: [Slot]
        
        
        // todo
        var defaultActions: [Action]?
        var ik: [IK]?
        var animation: [Animation]?
        
        init(json: JSON) {
            frameRate = json["frameRate"].int ?? 24
            name = json["name"].string!
            type = json["type"].string!
            var theBone: [Bone] = []
            for item in json["bone"].array ?? [] {
                theBone.append(Bone(json: item))
            }
            bone = theBone
            var theSkin: [Skin] = []
            for item in json["skin"].array ?? [] {
                theSkin.append(Skin(json: item))
            }
            skin = theSkin
            var theSlot: [Slot] = []
            for item in json["slot"].array ?? [] {
                theSlot.append(Slot(json: item))
            }
            slot = theSlot
        }
    }

    var frameRate: Int
    var version: String?
    var isGlobal: Int
    var name: String
    var armature: [Armature]
    
    init(json: JSON) {
        frameRate = json["frameRate"].int ?? 24
        version = json["version"].string
        isGlobal = json["isGlobal"].int ?? 0
        name = json["name"].string!
        armature = []
        for item in json["armature"].array ?? [] {
            armature.append(Armature(json: item))
        }
    }
}


