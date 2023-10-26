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
    var gameResult : SKLabelNode!
    var buttonUp : SKSpriteNode!
    var buttonDown : SKSpriteNode!
    var fondo: SKSpriteNode!
    var borderPadding: CGFloat = 11.0;

    //control de propiedades de pelota
    var ballVelocityX: CGFloat = 0.0;
    var ballVelocityY: CGFloat = 0.0;
    var ballVelocityIncrease: CGFloat = 0.8;
    
    //control para botones de movimiento
    var movePlayerUp = false;
    var movePlayerDown = false;

    //control propiedades de barras
    var playerVelocity: CGFloat = 8.0;
    var opponentVelocity: CGFloat = 7.0;
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
        backgroundColor = SKColor(red: 46.0 / 255.0, green: 56.0 / 255.0, blue: 49.0 / 255.0, alpha: 1.0)
        
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
        gameResult = (self.childNode(withName: "//resultado") as! SKLabelNode)
        gameStart = (self.childNode(withName: "//gameStart") as! SKLabelNode)
        buttonUp = (self.childNode(withName: "//buttonUp") as! SKSpriteNode)
        buttonDown = (self.childNode(withName: "//buttonDown") as! SKSpriteNode)
        
        fondo = (self.childNode(withName: "//field") as! SKSpriteNode)

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    //crea pelota y asigna sus velocidades
    func launchBall(fromPlayer: Bool) {
        if (gameResult.isHidden) {
            ball = SKSpriteNode(imageNamed: "ball")
            //genera la pelota al centro
            ball.position = CGPoint(x: 0.0, y: 0.0)
            ball.zPosition = 0
            
            ballVelocityX = 7.0
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
        }
    }
    
    //invierte velocidad en Y para bordes arriba/abajo
    func bounceBall() {
        if ball != nil {
            //supero el limite de a
            if ball.position.y > size.height / 2 - ball.size.height / 2 - borderPadding {
                ballVelocityY = ballVelocityY * -1
                //sonido al rebotar
                run(SKAction.playSoundFileNamed("ballSFX.mp3", waitForCompletion: false))
            }
            //paso limite abajo
            if ball.position.y < -size.height / 2 + ball.size.height / 2 + borderPadding {
                ballVelocityY = ballVelocityY * -1
                //sonido al rebotar
                run(SKAction.playSoundFileNamed("ballSFX.mp3", waitForCompletion: false))
            }
        }
    }
    
    //mueve al oponente para alcanzar posicion de pelota
    func catchBall() {
        
        //posición inical del Sprite oponente
        var newPositionY = opponent.position.y
        
        //pelota arriba del oponente
        if ball.position.y > opponent.position.y + opponent.size.height / 2 {
            newPositionY += opponentVelocity
        }
        //pelota abajo del oponente
        if ball.position.y < opponent.position.y - opponent.size.height / 2 {
            newPositionY -= opponentVelocity
        }
        
        //actualiza posiciòn del Sprite oponente
        opponent.position.y = newPositionY
    }
    
    //llamada cuando se dectó colisión entre barra y pelota
    func ballCollidedWithBar(bar: SKSpriteNode, ball: SKSpriteNode) {
        //aumenta velocidad de pelota en x
        ballVelocityX = ballVelocityX + (ballVelocityX > 0 ? ballVelocityIncrease : -ballVelocityIncrease)
        //invierte la velocidad en x (rebote)
        ballVelocityX = ballVelocityX * -1
        
        //desvía pelota en Y si rebota lejos del centro de la barra
        ballVelocityY = 10.0 * (ball.position.y - bar.position.y) / (bar.size.height / 2)
        
        //sonido al colisionar
        run(SKAction.playSoundFileNamed("ballSFX.mp3", waitForCompletion: false))
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
        gameResult.isHidden = true

        //lanzamiento inicial hacia el jugador
        launchBall(fromPlayer: false)
    }
    
    //valida si ya ha terminado el juego
    func gameOver() {
        var fin = false
        if scorePlayer == 3 {
            gameResult.text = "Ganaste !!"
            fin = true
            run(SKAction.playSoundFileNamed("winSFX.mp3", waitForCompletion: false))
        } else if scoreOponent == 3 {
            gameResult.text = "Perdiste :["
            fin = true
            run(SKAction.playSoundFileNamed("loseSFX.mp3", waitForCompletion: false))
        }
        if fin {
            //reinicia posicion de barras
            player.position.y = 0.0
            opponent.position.y = 0.0
            
            //muestra resultado y botón "Comenzar"
            gameStart.text = "Revancha"
            gameStart.isHidden = false
            gameResult.isHidden = false
        }
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
        let touch = touches.first!
        //la partida está en curso
        if gameStart.isHidden {
            if buttonUp.contains(touch.location(in: self)) {
                movePlayerUp = false
            }
            if buttonDown.contains(touch.location(in: self)) {
                movePlayerDown = false
            }
        }
    }
    
    //se ejecuta cada frame
    override func update(_ currentTime: TimeInterval) {
        //solo ejecuta codigo si la partida ha comenzado
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
                
                //mueve al oponente para atrapar la pelota
                catchBall()
                
                //detecta si la pelota ha salido de pantalla
                if ball.position.x < -fondo.size.width / 2 - ball.size.width / 2 {
                    //salio del lado del jugador, punto para oponente
                    ball.removeFromParent()
                    scoreOponent += 1
                    scoreOpponentLabel.text = String(scoreOponent)
                    run(SKAction.playSoundFileNamed("scoredSFX.mp3", waitForCompletion: false))
                    gameOver()
                    launchBall(fromPlayer: true)
                } else if ball.position.x > fondo.size.width / 2 + ball.size.width / 2 {
                    //salio del lado del oponente, punto para jugador
                    ball.removeFromParent()
                    scorePlayer += 1
                    scorePlayerLabel.text = String(scorePlayer)
                    run(SKAction.playSoundFileNamed("scoredSFX.mp3", waitForCompletion: false))
                    gameOver()
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
