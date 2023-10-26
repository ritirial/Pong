//
//  GameScene.swift
//  PongPlus
//
//  Created by Victor Javier Lozano Cortés on 25/10/23.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let none     : UInt32 = 0
    static let all      : UInt32 = UInt32.max
    
    static let bar   : UInt32 = 0b1
    static let ball : UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scorePlayer = 0
    var scoreOponent = 0
    var player: SKSpriteNode!
    var opponent: SKSpriteNode!
    var ball: SKSpriteNode!
    var scorePlayerLabel: SKLabelNode!
    var scoreOpponentLabel: SKLabelNode!
    var gameStart : SKLabelNode!
    var buttonUp : SKLabelNode!
    var buttonDown : SKLabelNode!
    var borderPadding: CGFloat = 11.0;

    //control de propiedades de pelota
    var ballVelocityX: CGFloat = 0.0;
    var ballVelocityY: CGFloat = 0.0;
    var ballVelocityIncrease: CGFloat = 0.6;
    
    //control para botones de movimiento
    var movePlayerUp = false;
    var movePlayerDown = false;

    //control propiedades de barras
    var playerVelocity: CGFloat = 6.0;
    var opponentVelocity: CGFloat = 10.0;
    var opponentReactionTime: CGFloat = 1 / 60;
    
    //random de min a max personalizados
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: 0.0 ... 1.0) * (max - min) + min
    }
    
    //positivo/negativo
    func randomSign() -> Int {
        let signs = [1, -1]
        return signs.randomElement()!
    }
    
    //escena es visible, primer codigo
    override func didMove(to view: SKView) {
        //asigna propiedades a barra del jugador
        player = (self.childNode(withName: "//player") as! SKSpriteNode)
        player.zPosition = 0
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.bar
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true

        //asigna propiedades a barra del oponente
        opponent = (self.childNode(withName: "//opponent") as! SKSpriteNode)
        opponent.zPosition = 0
        opponent.physicsBody = SKPhysicsBody(rectangleOf: opponent.size)
        opponent.physicsBody?.isDynamic = true
        opponent.physicsBody?.categoryBitMask = PhysicsCategory.bar
        opponent.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        opponent.physicsBody?.collisionBitMask = PhysicsCategory.none
        opponent.physicsBody?.usesPreciseCollisionDetection = true

        //asigna objetos de labels
        scorePlayerLabel = (self.childNode(withName: "//scorePlayer") as! SKLabelNode)
        scoreOpponentLabel = (self.childNode(withName: "//scoreOpponent") as! SKLabelNode)
        
        //asigna objetos de botones
        gameStart = (self.childNode(withName: "//gameStart") as! SKLabelNode)
        buttonUp = (self.childNode(withName: "//buttonUp") as! SKLabelNode)
        buttonDown = (self.childNode(withName: "//buttonDown") as! SKLabelNode)

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    //crea pelota y asigna sus velocidades
    func launchBall(fromPlayer: Bool) {
        ball = SKSpriteNode(imageNamed: "ball")
        //genera la pelota al centro
        ball.position = CGPoint(x: 0.0, y: 0.0)
        ball.zPosition = 0
        
        //ballVelocityX = random(min: 4.0, max: 6.0) * CGFloat(randomSign())
        //ballVelocityY = random(min: 0.0, max: 6.0) * CGFloat(randomSign())
        ballVelocityX = 4.0
        //decide quien lanza pelota
        if !fromPlayer {
            ballVelocityX = ballVelocityX * -1
        }
        ballVelocityY = 0.0
        
        //asigna fisica
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.bar
        ball.physicsBody?.collisionBitMask = PhysicsCategory.none
        ball.physicsBody?.usesPreciseCollisionDetection = true
        
        //instancia
        addChild(ball)
        
        //cambia la posición acorde a velocidad
        //let move = SKAction.move(to: CGPoint(x: ball.position.x + ballVelocityX, y: ball.position.y + ballVelocityY), duration: TimeInterval(0.001))
        //mueve la pelota, luego checa si ha tocado bordes
        //ball.run(SKAction.repeatForever(SKAction.sequence([move, SKAction.run(bounceBall)])))
    }
    
    //invierte velocidad en Y para bordes arriba/abajo
    func bounceBall() {
        //paso limite arriba
        if ball != nil {
            if ball.position.y > size.height / 2 - ball.size.height / 2 - borderPadding {
                ballVelocityY = ballVelocityY * -1
            }
            //paso limite abajo
            if ball.position.y < -size.height / 2 + ball.size.height / 2 + borderPadding {
                ballVelocityY = ballVelocityY * -1
            }
        }
    }
    
    //mueve al oponente para alcanzar posicion de pelota
    func catchBall() {
        if ball != nil {
            var newPositionY = opponent.position.y
            //paso limite arriba
            if ball.position.y > opponent.position.y + opponent.size.height / 2 {
                newPositionY += opponentVelocity
            }
            //paso limite abajo
            if ball.position.y < opponent.position.y - opponent.size.height / 2 {
                newPositionY -= opponentVelocity
            }
            
            let move = SKAction.move(to: CGPoint(x: opponent.position.x, y: newPositionY), duration: TimeInterval(opponentReactionTime))
            opponent.run(move)
        }
    }
    
    //llamada cuando se dectò colisiòn entre barra y pelota
    func ballCollidedWithBar(bar: SKSpriteNode, ball: SKSpriteNode) {
        //aumenta velocidad en x
        ballVelocityX = ballVelocityX + ballVelocityIncrease
        //invierte la velocidad en x (rebote)
        ballVelocityX = ballVelocityX * -1
        
        //desvia pelota en Y dependiendo de distancia al centro de la barra
        ballVelocityY = 6.0 * (ball.position.y - bar.position.y) / (bar.size.height / 2)
    }
    
    //listener de colisiones
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.bar && contact.bodyB.categoryBitMask == PhysicsCategory.ball {
            ballCollidedWithBar(bar: contact.bodyA.node as! SKSpriteNode, ball: contact.bodyB.node as! SKSpriteNode)
        }
    }
    
    //reinicia todos los valores para preparar la partida
    func startGame() {
        //reinicia contadores
        scorePlayer = 0
        scoreOponent = 0
        scorePlayerLabel.text = String(scorePlayer)
        scoreOpponentLabel.text = String(scoreOponent)
        
        //reinicia posicion de barras
        player.position.y = 0.0
        opponent.position.y = 0.0
        
        //oculta boton "Comenzar"
        gameStart.isHidden = true
        
        //lanza pelota
        //run(SKAction.run(launchBall))
        //lanzamiento inicial hacia el jugador
        launchBall(fromPlayer: false)
        //activar movimiento oponente
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(catchBall), SKAction.wait(forDuration: opponentReactionTime)])))
    }
    
    
    func gameOver() {
        
    }
    
    //listener para touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        //se presiono el boton "Comenzar"
        if !gameStart.isHidden && gameStart.contains(touch.location(in: self)) {
            startGame()
        }
        //la partida está en curso
        if gameStart.isHidden {
            if buttonUp.contains(touch.location(in: self)) {
                movePlayerUp = true
            }
            if buttonDown.contains(touch.location(in: self)) {
                movePlayerDown = true
            }
        }
    }
    
    //listener para drag
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //listener para soltar touch
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //la partida está en curso
            if gameStart.isHidden {
                if buttonUp.contains(touch.location(in: self)) {
                    movePlayerUp = true
                }
                if buttonDown.contains(touch.location(in: self)) {
                    movePlayerDown = true
                }
            }
        }
    }
    
    //se ejecuta cada frame
    override func update(_ currentTime: TimeInterval) {
        //solo ejecuta codigo si la partida ha conezado
        if gameStart.isHidden {
            //valida si el usuario esta manteniendo el boton de mover arriba
            if movePlayerUp {
                if player.position.y < size.height / 2 - player.size.height / 2 - borderPadding {
                    player.position.y += playerVelocity
                }
            }
            //valida si el usuario esta manteniendo el boton de mover abajo
            if movePlayerDown {
                if player.position.y > -size.height / 2 + player.size.height / 2 + borderPadding {
                    player.position.y -= playerVelocity
                }
            }
            
            //valida que hay una pelota instanciada
            if ball != nil {
                //detecta si la pelota ha salido de pantalla
                if ball.position.x < -size.width / 2 - ball.size.width / 2 {
                    //salio del lado del jugador, punto para oponente
                    ball.removeFromParent()
                    scoreOponent += 1
                    scoreOpponentLabel.text = String(scoreOponent)
                    launchBall(fromPlayer: true)
                } else if ball.position.x > size.width / 2 + ball.size.width / 2 {
                    //salio del lado del oponente, punto para jugador
                    ball.removeFromParent()
                    scorePlayer += 1
                    scorePlayerLabel.text = String(scorePlayer)
                    launchBall(fromPlayer: false)
                } else {
                    //no ha salido, sigue moviendo
                    ball.position.x += ballVelocityX
                    ball.position.y += ballVelocityY
                    
                    bounceBall()
                }
            }
        }
    }
}
