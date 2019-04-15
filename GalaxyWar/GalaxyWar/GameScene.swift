//
//  GameScene.swift
//  GalaxyWar
//
//  Created by Денис Скаваротти on 4/15/19.
//  Copyright © 2019 Денис Скаваротти. All rights reserved.
//

import SpriteKit
import GameplayKit

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
    
    let alienCategory: UInt32 = 0x1 << 1//Создание значений с уникальным ID
    let bulletCategory: UInt32 = 0x1 << 0//Также уникальное ID но отличное от alienCategory
    
    //Mark 1 Работа с полем, игроком, физикой и экраном
    override func didMove(to view: SKView) {
        //Mark 1.1 Работа с космическим полем
        startfield = SKEmitterNode(fileNamed: "Starfield")//Передали анимацию в переменную
        startfield.position = CGPoint(x: 0, y: 1472)//Позиция starfield на экране. CGPoint класс
        startfield.advanceSimulationTime(10)//Убирается пустота в начале анимации. Включить с какой секунды отображать
        startfield.zPosition = -1 //Чтобы задний фон всегда был позади, снизу.
        self.addChild(startfield)//Добавляется объект на экран
        
        //Mark 1.2 Работа с игроком
        player = SKSpriteNode(imageNamed: "shuttle")//Передали sprite/изображение
        player.position = CGPoint(x: 0, y: -300)//Позиция на экране.
        player.setScale(2)///Увеличение в 2 раза размера на экране игрока
        self.addChild(player)//Добавили игрока на экран
        
        //Mark 1.3 Работа с физическими свойствами
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)//Отключаем гравитацию
        self.physicsWorld.contactDelegate = self//Отслеживает соприкосновения с игроком
        
        //Mark 1.4 Характеристик для надписи на экране scoreLabel
        scoreLabel = SKLabelNode(text: "Счет: 0")//Изначально счет 0
        scoreLabel.fontName = "AppleSDGothicNeo-Thin"//Характеристики шрифта
        scoreLabel.fontSize = 60//Размер шрифта
        scoreLabel.fontColor = UIColor.white//Цвет шрифта
        scoreLabel.position = CGPoint(x: -200, y: 500)//CGPoint(x: 100, y: self.frame.size.height - 60)Позиция на экране. Берется высота и от нее отмается 60px
        score = 0//Сама переменная = 0
        self.addChild(scoreLabel)//Добавили на экран scoreLabel/счет
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)//Инициализация переменной. timeInterval/интервал вызова ф-ии,target/цель, selector/ф-ия которая вызывается, userInfo/информация игрока которая должна быть показана, repeats/будет ли действие повторяться. Это время появления врагов
    }
    //Mark 2 Работа с врагами
    @objc func addAlien(){//Ф-ия вызова врагов. @objc Означает работу с объектами
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]//Перебор массива aliens и создание случайного врага. И это все в виде строки передается в массив aliens
        
        //Mark 2.1 Отображение врага на экране
        let alien = SKSpriteNode(imageNamed: aliens[0])//SKSpriteNode/картинка и первая картинка из массива aliens
        let randomPos = GKRandomDistribution(lowestValue: -350, highestValue: 350)//Позиция случайно созданых врагов от lowestValue до highestValue. Будет на случайном числе отображаться
        let pos = CGFloat(randomPos.nextInt())//Конвертер в CGFloat число из randomPos.nextInt()
        alien.position = CGPoint(x: pos, y: 800)//Присваивается позиция для созданных объектов. 800 Чтобы появление врага было выше экрана
        alien.setScale(2)//Увеличение в 2 раза размера на экране врагов
        
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
        actions.append(SKAction.move(to: CGPoint(x: pos, y: -800), duration: animDuration))//.move/Куда двигаются враги, -800/за экраном iphone, duration/скорость анимации
        actions.append(SKAction.removeFromParent())//При выходе за пределы экрана враг удаляется
        alien.run(SKAction.sequence(actions))//Запуск врага на экране с помощью массива actions
        
    }
    
    //Mark 3 Работа с выстрелами
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()//При нажатии на экран вызывается ф-ия
    }
    func fireBullet(){
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))//При выстреле проигрыш звука. False потому что после проигрыша нет действий
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
        bullet.setScale(2)
        self.addChild(bullet)//Добавили на экран bullet
        
        //Mark 3.4 Движение выстрела в верх, от игрока
        let animDuration: TimeInterval = 0.3//Скорость проигрывания анимации, полет в верх
        var actions = [SKAction]()//Массив для действий чтобы двигать к финальной точке и удалять выстрел
        actions.append(SKAction.move(to: CGPoint(x: player.position.x , y: 800), duration: animDuration))//.move/Куда двигаются выстрелы, player.position.x/от игрока в верх до 800, duration/скорость анимации
        actions.append(SKAction.removeFromParent())//При выходе за пределы экрана выстрел удаляется
        bullet.run(SKAction.sequence(actions))//Запуск выстрела на экране с помощью массива actions
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered. Ф-ия срабатывает каждый фрейм в игре. Фрейм объединяет в одном окне информацию с нескольких страниц
    }
}
