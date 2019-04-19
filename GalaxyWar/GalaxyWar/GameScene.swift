//
//  GameScene.swift
//  GalaxyWar
//
//  Created by Денис Скаваротти on 4/15/19.
//  Copyright © 2019 Денис Скаваротти. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion//Для отслеживания акселерометра

class GameScene: SKScene, SKPhysicsContactDelegate {// SKPhysicsContactDelegate отслеживает контакт с чем-то (физ. св-ва обьекта)
    var startfield: SKEmitterNode!//Отвечет за запуск звездного поля. SKEmitterNode - анимация
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!//Счет. Надпись для экрана
    var score: Int = 0{//Записываем счет и обновляем надпись на экране
        didSet{
            scoreLabel.text = "Счет: \(score)"
        }
    }
    
    var gameTimer: Timer! //Таймер вызова ф-ии в которой находятся враги. Для создания врагов через определенный промежуток времени
    var aliens = ["alien1", "alien2", "alien3"]//Массив картинок для отображения врагов
    let alienCategory: UInt32 = 0x1 << 2//Создание значений с уникальным ID
    let bulletCategory: UInt32 = 0x1 << 1//Также уникальное ID но отличное от alienCategory
    let playerCategoty: UInt32 = 0
    let motionManeger = CMMotionManager()//Для управления акселерометром
    var xAccelerate: CGFloat = 0//Акселерометр по Х(сила отклонения)
    
    //Mark 1 Работа с полем, игроком, физикой и экраном
    override func didMove(to view: SKView) {
        //Mark 1.1 Работа с космическим полем
        startfield = SKEmitterNode(fileNamed: "Starfield")//Передали анимацию в переменную
        startfield.position = CGPoint(x: 0, y: 1472)//Позиция starfield на экране. CGPoint класс
        startfield.advanceSimulationTime(10)//Убирается пустота в начале анимации. Включить с какой секунды отображать
        startfield.zPosition = -2 //Чтобы задний фон всегда был позади, снизу.
        self.addChild(startfield)//Добавляется объект на экран
        
        //Mark 1.2 Работа с игроком
        player = SKSpriteNode(imageNamed: "shuttle")//Передали sprite/изображение
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 200)//Позиция на экране.
        player.setScale(1.5)///Увеличение в 1.5 раза размера на экране игрока
        self.addChild(player)//Добавление игрока на экран
        
      //Mark 1.3 Прикосновение игрока с врагом
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)//Физ. размер игрока для попадания в него в виде Квадрата/rectangleOf
        player.physicsBody?.isDynamic = true//Отслеживание прикосновения динамическое
        player.physicsBody?.categoryBitMask = playerCategoty//Передали уникальное ID игроку
        player.physicsBody?.contactTestBitMask = alienCategory//Контакт. Прикоснулся ли враг alienCategory к игроку playerCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true//Здесь игрок физически соприкасается с врагом и отслеживается
        func startsWhenTouched(_ contact: SKPhysicsContact) {//Ф-ия вызывается при прикосновении
            var alienBody: SKPhysicsBody
            var playerBody: SKPhysicsBody
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{//Проверка. Если bodyA больше чем BodyB то это игрок (playerCategory=0), если меньше то враг (alienCategory=2). См верх кода
                playerBody = contact.bodyA
                alienBody = contact.bodyB
            }else{//Если иначе, меньше то:
                playerBody = contact.bodyB
                alienBody = contact.bodyA
            }
            if (alienBody.categoryBitMask & alienCategory) != 0 && (playerBody.categoryBitMask & playerCategoty) != 0 {//Если игрок и враг прикоснултсь вызываем ф-ию collisionElements
                collisionPlayer(playerNode: playerBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
            }
        }
        func collisionPlayer(playerNode: SKSpriteNode, alienNode: SKSpriteNode){//Дополнительная ф-ия принимает игрока и врага
            let explosion = SKEmitterNode(fileNamed: "Vzriv")//При соприкосновении анимация взрыва
            explosion?.position = playerNode.position//Позиция запуска анимации
            self.addChild(explosion!)//Добавиление взрыва на экран
            self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))//Добавление звука
            playerNode.removeFromParent()//Удаление после прикосновения
            alienNode.removeFromParent()
        
//НАДО ПЕРЕЙТИ В ЭКРАН МЕНЮ
        }
        
        //Mark 1.4 Работа с физическими свойствами
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)//Отключаем гравитацию
        self.physicsWorld.contactDelegate = self//Отслеживает соприкосновения с игроком
        
        //Mark 1.5 Характеристик для надписи на экране scoreLabel
        scoreLabel = SKLabelNode(text: "Счет: 0")//Изначально счет 0
        scoreLabel.fontName = "AppleSDGothicNeo-Thin"//Характеристики шрифта
        scoreLabel.fontSize = 60//Размер шрифта
        scoreLabel.fontColor = UIColor.white//Цвет шрифта
        scoreLabel.position = CGPoint(x: 120, y: UIScreen.main.bounds.height - 100)//CGPoint(x: 100, y: self.frame.size.height - 60)Позиция на экране. Берется высота и от нее отмается 60px
        score = 0//Сама переменная = 0
        self.addChild(scoreLabel)//Добавление на экран scoreLabel/счет
        
        //Mark 1.6 Управлению сложностью игры
        var timeInterval = 0.75//Временной интервал
        if UserDefaults.standard.bool(forKey: "hard"){
            timeInterval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        //gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)//Инициализация переменной. timeInterval/интервал вызова ф-ии,target/цель, selector/ф-ия которая вызывается, userInfo/информация игрока которая должна быть показана, repeats/будет ли действие повторяться. Это время появления врагов
        
        //Mark 1.7 Работа с акселерометром
        motionManeger.accelerometerUpdateInterval = 0.2//accelerometerUpdateInterval/Как часто проверять значение
        motionManeger.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in//Если есть данные с акселерометра то
            if let accelerometrData = data {//Берем данные из data
                let acceleration = accelerometrData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25//Передаем все данные в переменную xAccelerate через конвертацию в CGFloat
            }
        }
    }
    
        //Mark 1.7 Движение игрока
        override func didSimulatePhysics(){//Данные из xAccelerate для движения игрока
            player.position.x += xAccelerate * 50 //Позициия по Х и *50 чтобь увеличить само число для iPhone, для iPad нужно больше
            if player.position.x < 0 {//Запрет на выход за рамки экрана
                player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)//Тогда даем новую позицию c другой стороны экрана
            } else if player.position.x > UIScreen.main.bounds.width{
             player.position = CGPoint(x: 20, y: player.position.y)//Если вылетает в другую сторону
        }
    }

    //Mark 2 Работа с врагами
    @objc func addAlien(){//Ф-ия вызова врагов. @objc Означает работу с объектами
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]//Перебор массива aliens и создание случайного врага. И это все в виде строки передается в массив aliens
        
        //Mark 2.1 Отображение врага на экране
        let alien = SKSpriteNode(imageNamed: aliens[0])//SKSpriteNode/картинка и первая картинка из массива aliens
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))//Позиция случайно созданых врагов от lowestValue до highestValue. Будет на случайном числе отображаться
        let pos = CGFloat(randomPos.nextInt())//Конвертер в CGFloat число из randomPos.nextInt()
        alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)//Присваивается позиция для созданных объектов. 800 Чтобы появление врага было выше экрана
        //alien.setScale(2)//Увеличение в 2 раза размера на экране врагов
        
        //Mark 2.2 Физика врага
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)//Физ. размер врага для попадания в него в виде Квадрата/rectangleOf
        alien.physicsBody?.isDynamic = true//Отслеживание прикосновения динамическое
        
        //Mark 2.3 Отслеживание соприкосновения. Каждому врагу нужен индивидульный ID по которому его можно отследить
        alien.physicsBody?.categoryBitMask = alienCategory//Передали уникальное ID врагу
        alien.physicsBody?.contactTestBitMask = bulletCategory//Контакт. Прикоснулся ли выстрел bulletCategory к врагу alienCategory
        alien.physicsBody?.collisionBitMask = 0
        self.addChild(alien)//Добавили на экран alien
        
        //Mark 2.4 Движение врагов вниз, на игрока
        let animDuration: TimeInterval = 6//Скорость проигрывания анимации, спуск вниз
        var actions = [SKAction]()//Массив для действий чтобы двигать к финальной точке и удалять врагов
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))//.move/Куда двигаются враги, -800/за экраном iphone, duration/скорость анимации
        actions.append(SKAction.removeFromParent())//При выходе за пределы экрана враг удаляется
        alien.run(SKAction.sequence(actions))//Запуск врага на экране с помощью массива actions
    }
    
    //Mark 3 Работа с выстрелами
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()//При нажатии на экран вызывается ф-ия
    }
    func fireBullet(){
        self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))//При выстреле проигрыш звука. False потому что после проигрыша нет действий
        let bullet = SKSpriteNode(imageNamed: "torpedo")//Отбражение выстрела
        
        //Mark 3.1 Позиция выстрела
        bullet.position = player.position//Позиция выстрела = позиции игрока
        bullet.position.y += 5 //Добавляем к позиции 5px чтобы выстрел был выше
        
        //Mark 3.2 Физика выстрела
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)//Физ. размер врага для попадания в него в виде Круга/circleOfRadius и размер делим на 2
        bullet.physicsBody?.isDynamic = true//Отслеживание прикосновения динамическое
        
        //Mark 3.3 Отслеживание соприкосновения. Каждому выстрелу нужен индивидульный ID по которому его можно отследить
        bullet.physicsBody?.categoryBitMask = bulletCategory//Передали уникальное ID выстрела
        bullet.physicsBody?.contactTestBitMask = alienCategory//Контакт. Прикоснулся ли враг bulletCategory к врагу alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true//Здесь выстрел физически соприкасается с врагом и отслеживается
        //bullet.setScale(2)
        self.addChild(bullet)//Добавили на экран bullet
        
        //Mark 3.4 Движение выстрела в верх, от игрока
        let animDuration: TimeInterval = 0.7//Скорость проигрывания анимации, полет в верх
        var actions = [SKAction]()//Массив для действий чтобы двигать к финальной точке и удалять выстрел
        actions.append(SKAction.move(to: CGPoint(x: player.position.x , y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))//.move/Куда двигаются выстрелы, player.position.x/от игрока в верх до 800, duration/скорость анимации
        actions.append(SKAction.removeFromParent())//При выходе за пределы экрана выстрел удаляется
        bullet.run(SKAction.sequence(actions))//Запуск выстрела на экране с помощью массива actions
        bullet.zPosition = -1 //Чтобы задний фон выстрела был под игроком и выше поля.
    }
    
    //Mark 4 Отслеживание соприкосновения. Продолжение Mark 3.3
    func didBegin(_ contact: SKPhysicsContact) {//Ф-ия вызывается при прикосновении
        var alienBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{//Проверка. Если bodyA больше чем BodyB то это выстрел (bulletCategory=0), если меньше то враг (alienCategory=1). См верх кода
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        }else{//Если иначе, меньше то:
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        
        //Mark 4.1 Проверка кто с кем соприкоснулся
        if (alienBody.categoryBitMask & alienCategory) != 1 && (bulletBody.categoryBitMask & bulletCategory) != 1 {//Если враг и выстрел вызываем ф-ию collisionElements
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
        }
    }
    func collisionElements(bulletNode: SKSpriteNode, alienNode: SKSpriteNode){//Дополнительная ф-ия для Mark 4.1. Принимает выстрел и врага
        let explosion = SKEmitterNode(fileNamed: "Vzriv")//При соприкосновении анимация взрыва
        explosion?.position = alienNode.position//Позиция запуска анимации
        
        //Mark 4.2 Анимация и звук взрыва
        self.addChild(explosion!)//Добавиление взрыва на экран
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))//Добавление звука
        
        //Mark 4.3 Удаление врага и выстрела после соприкосновения
        bulletNode.removeFromParent()//Удаление
        alienNode.removeFromParent()
        
        //Mark 4.4
        self.run(SKAction.wait(forDuration: 2)){//Удаляется с задержкой на экране 2 сек.
            explosion?.removeFromParent()//После проигрыша удаляем
        }
        score += 5//Добавляем к перемноой score 5 едениц
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered. Ф-ия срабатывает каждый фрейм в игре. Фрейм объединяет в одном окне информацию с нескольких страниц
    }
}
