//
//  Skeleton.swift
//  DragonBonesSpriteKit
//
//  Created by Salo on 16/6/23.
//  Copyright © 2016年 eitdesign. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Skeleton {
    struct Armature {
        struct Transform {
            var skX: Double
            var skY: Double
            var y: Double
            var x: Double
            var scX: Double
            var scY: Double
            
            init(json: JSON) {
                skX = json["skX"].double ?? 0
                skY = json["skY"].double ?? 0
                x = json["x"].double ?? 0
                y = json["y"].double ?? 0
                scX = json["skY"].double ?? 0
                scY = json["skY"].double ?? 0
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
            struct Solt {
                struct Display {
                    var type: String
                    var transform: Transform
                    var name: String
                }
                
                var display: [Display]
            }
            
            var name: String
            var solt: [Solt]
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
            var name: String
            var parent: String
            var z: Int
        }
        
        var type: String
        var name: String
        var frameRate: Int
        var bone: [Bone]
        
        
        // todo
        var defaultActions: [Action]?
        var ik: [IK]?
        var skin: [Skin]?
        var animation: [Animation]?
        var slot: [Slot]?
        
        init(json: JSON) {
            frameRate = json["frameRate"].int ?? 24
            name = json["name"].string!
            type = json["type"].string!
            bone = []
            for item in json["bone"].array ?? [] {
                bone.append(Bone(json: item))
            }
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


