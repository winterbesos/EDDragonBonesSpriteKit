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
            
            init(json: JSON, defaultTransform: Transform) {
                let offsetSkX = json["skX"].double ?? 0
                let offsetSkY = json["skY"].double ?? 0
                let offsetX = CGFloat(json["x"].double ?? 0)
                let offsetY = -CGFloat(json["y"].double ?? 0)
                let offsetScX = CGFloat(json["scX"].double ?? 1)
                let offsetScY = CGFloat(json["scY"].double ?? 1)
                let offsetZRotation = -CGFloat(((offsetSkX + offsetSkY) / 2 ?? 0) * M_PI) / 180
                
                scX = defaultTransform.scX * offsetScX
                scY = defaultTransform.scY * offsetScY
                zRotation = defaultTransform.zRotation + offsetZRotation
                position = CGPoint(x: defaultTransform.position.x + offsetX, y: defaultTransform.position.y + offsetY)
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
            let gotoAndPlay: String
            init(json: JSON) {
                gotoAndPlay = json["gotoAndPlay"].string!
            }
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
            
            struct Slot {
                struct Frame {
                    struct Color {
                        let alpha: CGFloat
                        init(json: JSON) {
                            alpha = CGFloat(json["aM"].int ?? 100) / 100
                        }
                    }
                    
                    let tweenEasing: Bool
                    let color: Color
                    let displayIndex: Int
                    let duration: NSTimeInterval
                }
                
                let name: String
                let frame: [Frame]
                
                init(json: JSON, frameRate: Int) {
                    name = json["name"].string!
                    var theFrame: [Frame] = []
                    
                    var lastItem: JSON?
                    let frameJSON = json["frame"].array ?? []
                    for item in frameJSON {
                        let color = Frame.Color(json: item["color"])
                        let duration: NSTimeInterval
                        let tweenEasing: Bool
                        if let lastItem = lastItem {
                            duration = 1.0 / NSTimeInterval(frameRate) * NSTimeInterval(lastItem["duration"].int!)
                            tweenEasing = (lastItem["tweenEasing"].int != nil) // if not int is no
                        } else {
                            duration = 0
                            tweenEasing = false
                        }
                        
                        let frame = Frame(tweenEasing: tweenEasing,
                                          color: color,
                                          displayIndex: item["displayIndex"].int ?? 0,
                                          duration: duration)
                        theFrame.append(frame)
                        
                        lastItem = item
                    }
                    
                    // supplyment last frame
                    let lastDuration = frameJSON.last!["duration"].int!
                    if lastDuration != 0 {
                        let firstFrame = theFrame.first!
                        let frame = Frame(tweenEasing: false,
                                          color: firstFrame.color,
                                          displayIndex: firstFrame.displayIndex,
                                          duration: 1.0 / NSTimeInterval(frameRate) * NSTimeInterval(lastDuration))
                        theFrame.append(frame)
                    }
                    
                    frame = theFrame
                }
            }
            
            struct Bone {
                struct Frame {
                    let tweenEasing: Bool
                    let transform: Transform
                    let duration: NSTimeInterval
                }
                
                let frame: [Frame]
                let name: String
                
                init(json: JSON, boneTransforms: [String: Transform], frameRate: Int) {
                    name = json["name"].string!
                    var theFrame: [Frame] = []
                    
                    var lastItem: JSON?
                    let frameJSON = json["frame"].array ?? []
                    
                    for item in frameJSON {
                        let transform = Transform(json: item["transform"], defaultTransform: boneTransforms[name]!)
                        let duration: NSTimeInterval
                        let tweenEasing: Bool
                        
                        if let lastItem = lastItem {
                            duration = 1.0 / NSTimeInterval(frameRate) * NSTimeInterval(lastItem["duration"].int!)
                            tweenEasing = (lastItem["tweenEasing"].int != nil)  // if not int is no
                        } else {
                            tweenEasing = false
                            duration = 0
                        }
                        
                        let frame = Frame(tweenEasing: tweenEasing,
                                          transform: transform,
                                          duration: duration)
                        theFrame.append(frame)
                        
                        lastItem = item
                    }
                    
                    // supplyment last frame
                    let lastDuration = frameJSON.last!["duration"].int!
                    if lastDuration != 0 {
                        let frame = Frame(tweenEasing: false,
                                          transform: theFrame.first!.transform,
                                          duration: 1.0 / NSTimeInterval(frameRate) * NSTimeInterval(lastDuration))
                        theFrame.append(frame)
                    }
                    
                    frame = theFrame
                }
                
            }
            
            struct Frame {
                let tweenEasing: Bool
                let event: String?
                let duration: NSTimeInterval
            }
            
            struct FFD {
                
            }
            
            let playTimes: Int?
            let slot: [Slot]
            let bone: [Bone]
            let duration: NSTimeInterval
            let name: String
            let frame: [Frame]
            
            // todo:
            var ffd: [FFD]?
            
            init(json: JSON, boneTransforms: [String: Transform], frameRate: Int) {
                name = json["name"].string!
                playTimes = json["playTimes"].int
                duration = 1.0 / NSTimeInterval(frameRate) * Double(json["duration"].int!)
                var theSlot: [Slot] = []
                for item in json["slot"].array ?? [] {
                    theSlot.append(Slot(json: item, frameRate: frameRate))
                }
                slot = theSlot
                
                var theBone: [Bone] = []
                for item in json["bone"].array ?? [] {
                    theBone.append(Bone(json: item, boneTransforms: boneTransforms, frameRate: frameRate))
                }
                bone = theBone
                
                var theFrame: [Frame] = []
                var lastItem: JSON?
                let frameJSON = json["frame"].array ?? []
                
                var cDuration: NSTimeInterval = 0
                for item in frameJSON {
                    
                    let duration: NSTimeInterval
                    let tweenEasing: Bool
                    let event: String? = item["event"].string
                    
                    if let lastItem = lastItem {
                        duration = 1.0 / NSTimeInterval(frameRate) * NSTimeInterval(lastItem["duration"].int!)
                        tweenEasing = (lastItem["tweenEasing"].int != nil)  // if not int is no
                    } else {
                        tweenEasing = false
                        duration = 0
                    }
                    
                    let frame = Frame(tweenEasing: tweenEasing,
                                      event: event,
                                      duration: duration)
                    theFrame.append(frame)
                    
                    cDuration += duration
                    lastItem = item
                }
                
                // supplyment last frame
                if frameJSON.count != 0 {
                    if cDuration < duration {
                        let frame = Frame(tweenEasing: false,
                                          event: nil,
                                          duration: duration - cDuration)
                        theFrame.append(frame)
                    }
                }
                
                frame = theFrame
            }
        }
        
        struct Slot {
            let name: String
            let parent: String
            let z: Int
            let displayIndex: Int
            
            init(json: JSON) {
                name = json["name"].string!
                parent = json["parent"].string!
                z = json["z"].int ?? 0
                displayIndex = json["displayIndex"].int ?? 0
            }
        }
        
        let type: String
        let name: String
        let frameRate: Int
        let bone: [Bone]
        let skin: [Skin]
        let slot: [Slot]
        let animation: [Animation]
        let defaultActions: [Action]
        
        // todo
        var ik: [IK]?
        
        init(json: JSON) {
            var boneTransforms: [String: Transform] = [:]
            
            frameRate = json["frameRate"].int ?? 24
            name = json["name"].string!
            type = json["type"].string!
            var theBone: [Bone] = []
            for item in json["bone"].array ?? [] {
                let bone = Bone(json: item)
                boneTransforms[bone.name] = bone.transform
                theBone.append(bone)
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
            var theAnimation: [Animation] = []
            for item in json["animation"].array ?? [] {
                theAnimation.append(Animation(json: item, boneTransforms: boneTransforms, frameRate: frameRate))
            }
            animation = theAnimation
            var theDefaultActions: [Action] = []
            for item in json["theDefaultActions"].array ?? [] {
                theDefaultActions.append(Action(json: item))
            }
            defaultActions = theDefaultActions
            
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


