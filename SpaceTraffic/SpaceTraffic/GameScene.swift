//
//  GameScene.swift
//  SpaceTraffic
//
//  Created by Al Manigsaca on 7/22/19.
//  Copyright © 2019 Al Manigsaca. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let ship = SKSpriteNode(imageNamed: "ship1")
    
    var lastUpdateTime : TimeInterval = 0
    var dt             : TimeInterval = 0
    
    let shipMovePointsPerSec   : CGFloat = 800.0
    let shipRotateRadiansPerSec : CGFloat = 2.0 * π
    let cargoMovePointsPerSec  : CGFloat = 800.0
    
    var velocity   = CGPoint.zero
    var invincible = false
    var lastTouchLocation : CGPoint?
    
    let playableRect  : CGRect
    let shipAnimation : SKAction
    
    override init(size: CGSize) {
        let maxAspectRatio : CGFloat = 16.0/8.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var shipTextures : [SKTexture] = []
        shipTextures.append(SKTexture(imageNamed: "ship1"))
        shipTextures.append(SKTexture(imageNamed: "ship2"))
        shipTextures.append(SKTexture(imageNamed: "ship3"))
        shipTextures.append(SKTexture(imageNamed: "ship4"))
        shipTextures.append(SKTexture(imageNamed: "ship3"))
        shipTextures.append(SKTexture(imageNamed: "ship2"))
        shipAnimation = SKAction.animate(with: shipTextures, timePerFrame: 0.1)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let backgroundTop = SKSpriteNode(imageNamed: "backgroundTop1")
        let backgroundMed = SKSpriteNode(imageNamed: "backgroundMed1")
        let backgroundBot = SKSpriteNode(imageNamed: "backgroundBot1")
        
        backgroundTop.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundMed.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundBot.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        backgroundTop.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundMed.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundBot.position = CGPoint(x: size.width/2, y: size.height/2)
        
        backgroundTop.zPosition = -1
        backgroundMed.zPosition = -2
        backgroundBot.zPosition = -3
        
        addChild(backgroundTop)
        addChild(backgroundMed)
        addChild(backgroundBot)
        
        ship.position = CGPoint(x: ship.size.width/2, y: size.height/2)
        ship.zPosition = 100
        addChild(ship)
        ship.run(SKAction.repeatForever(shipAnimation))
        debugDrawPlayableArea()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0 { dt  = currentTime - lastUpdateTime } else { dt = 0 }
        lastUpdateTime = currentTime
        
        if let lastTouchLocation = lastTouchLocation {
            let diff = lastTouchLocation - ship.position
            if diff.length() <= shipMovePointsPerSec * CGFloat(dt) {
                ship.position = lastTouchLocation
                velocity = CGPoint.zero
            } else {
                move(sprite: ship, velocity: velocity)
                rotate(sprite: ship, direction: velocity)
            }
        }
        // Check if ship hits the edge
        boundsCheckShip()
    }
    
    func move(sprite : SKSpriteNode, velocity : CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveShipToward(location : CGPoint) {
        let offset = CGPoint(x: location.x - ship.position.x,
                             y: location.y - ship.position.y)
        // Get the unit vector
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length),
                                y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * shipMovePointsPerSec,
                           y: direction.y * shipMovePointsPerSec)
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(shipRotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func shortestAngleBetween(angle1 : CGFloat, angle2 : CGFloat) -> CGFloat {
        let twoπ = π  * 2.0
        var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
        if angle >= π {
            angle = angle - twoπ
        }
        if angle <= -π {
            angle = angle + twoπ
        }
        return angle
    }
    
    func sceneTouched( touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
        moveShipToward(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func boundsCheckShip() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
    
        if ship.position.x <= bottomLeft.x {
            ship.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if ship.position.x >= topRight.x {
            ship.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if ship.position.y <= bottomLeft.y {
            ship.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if ship.position.y >= topRight.y {
            ship.position.y = topRight.y
            velocity.y = -velocity.y
        }
    
    }
    
    //********* Debug Code
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
}
