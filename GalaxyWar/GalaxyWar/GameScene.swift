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
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered. Ф-ия срабатывает каждый фрейм в игре. Фрейм объединяет в одном окне информацию с нескольких страниц
        
    }
}
