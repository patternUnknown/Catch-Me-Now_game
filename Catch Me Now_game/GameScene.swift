//
//  GameScene.swift
//  Catch Me Now_game
//
//  Created by DDDD on 29/02/2020.
//  Copyright © 2020 MeerkatWorks. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let backgroundImage = SKSpriteNode(imageNamed: "background")
        backgroundImage.position = CGPoint(x: 512, y: 384)
        backgroundImage.blendMode = .replace //ignoring any transparencies
        backgroundImage.zPosition = -1  //makes this backgroundImage be placed behind everything else
        addChild(backgroundImage)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)  // adding physics simulation
        physicsWorld.contactDelegate = self  //a delegate called when bodies collide
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSloth(at: CGPoint(x: 128, y: 0), isGood: true)      // a green slot
        makeSloth(at: CGPoint(x: 384, y: 0), isGood: false)     // a red slot
        makeSloth(at: CGPoint(x: 640, y: 0), isGood: true)      //a green slot
        makeSloth(at: CGPoint(x: 896, y: 0), isGood: false)     //a red slot
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }  //identifying any first touch that he user has made
        let locationUserTap = touch.location(in: self)  //find the location where the user had tapped
        
        let objects = nodes(at: locationUserTap)
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                //creating the objects here
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in:0...1), green: CGFloat.random(in:0...1), blue: CGFloat.random(in:0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 1...3)
                box.position = locationUserTap
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
            } else {
                
        let ball = SKSpriteNode(imageNamed: "candyRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody?.restitution = 0.4 //how bounchy will the ball be
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0  //notification of every single bounce, given the body interacts with everything
        ball.position = locationUserTap
        ball.name = "ball"
        addChild(ball)
            }
        }
    }

func makeBouncer(at positionBouncer: CGPoint) {
    //adding bouncers for the balls to bounce from
    let bouncer = SKSpriteNode(imageNamed: "bouncer")  //getting the bouncer from the assets library
    bouncer.position = positionBouncer
    bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
    bouncer.physicsBody?.isDynamic = false
    addChild(bouncer)
}

func makeSloth(at positionSlot: CGPoint, isGood: Bool) {
    var slotBase: SKSpriteNode
    var slotGlow: SKSpriteNode
    
    if isGood {
        slotBase = SKSpriteNode(imageNamed: "slotBaseGood")  //the green slotBase
        slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
        slotBase = SKSpriteNode(imageNamed: "bucketGreen")
        //TODO: the bucket should be in fron of the glow
        slotBase.name = "good"
    } else {
        slotBase = SKSpriteNode(imageNamed: "slotBaseBad")  //the red slotBase
        slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
        slotBase.name = "bad"
    }
    
    slotBase.position = positionSlot
    slotGlow.position = positionSlot
    
    slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
    slotBase.physicsBody?.isDynamic = false
    
    addChild(slotBase)
    addChild(slotGlow)
    
    let spin = SKAction.rotate(byAngle: .pi, duration: 10) //making it spin by 180*
    let spinForever = SKAction.repeatForever(spin) //making it always spin
    slotGlow.run(spinForever)
}

func collision(between ball: SKNode, object: SKNode) {
    if object.name == "good" {
        destroy(ball: ball)
        score += 1  //add one if good
    } else if object.name == "bad" {
        destroy(ball: ball)
        score -= 1
    }
}

func destroy(ball: SKNode) {
    ball.removeFromParent()
}

func didBegin(_ contact: SKPhysicsContact) {
    guard let nodeA = contact.bodyA.node else { return }
    guard let nodeB = contact.bodyB.node else { return }
    
    if nodeA.name == "ball" {
        collision(between: nodeA, object: nodeB)
    } else if nodeB.name == "ball" {
        collision(between: nodeB, object: nodeA)
    }
}
}
