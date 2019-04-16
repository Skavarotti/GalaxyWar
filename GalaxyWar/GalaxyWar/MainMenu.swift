//
//  MainMenu.swift
//  GalaxyWar
//
//  Created by Денис Скаваротти on 4/16/19.
//  Copyright © 2019 Денис Скаваротти. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {

    var starField: SKEmitterNode!
    var newGameButtonNode: SKSpriteNode!
    var levelButtonNode: SKSpriteNode!
    var labelLevelNode: SKLabelNode!
    
    override func didMove(to view: SKView){//
        starField = self.childNode(withName: "starfieldAnimation") as! SKEmitterNode//Элемент с экрана/self, .childNode/дочерний элемент, его название/withName и преобразуем в SKEmitterNode
        starField.advanceSimulationTime(10)//Запуск с 10 секунды
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "newGameBtn")//Заливка картинки
        
        levelButtonNode = self.childNode(withName: "levelButton") as! SKSpriteNode
        levelButtonNode.texture = SKTexture(imageNamed: "levelBtn")//Заливка картинки
        
        labelLevelNode = self.childNode(withName: "labelLevelButton") as! SKLabelNode
        
        let  userLevel = UserDefaults.standard//Отображение надписи из памяти
        if userLevel.bool(forKey: "hard"){//Если уровень трудно
            labelLevelNode.text = "Сложно"//Передача в label сложно
        } else {
            labelLevelNode.text = "Легко"
        }
    }
    //Mark 1. Ф-ия срабатывает при нажатии на экран
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first//Первое касание игрока
        
        if let location = touch?.location(in: self){//Поиск локации первого касания self/в этом же месте
            let nodesArray = self.nodes(at: location)//Массив с объектами где нажимает пользователь
            if nodesArray.first?.name == "newGameButton"{//Если newGameButton
                let transition = SKTransition.flipVertical(withDuration: 0.5)//Переход с снимацией на новую сцену с длительностью 0.5
                let gameScene = GameScene(size: UIScreen.main.bounds.size)//Характеристики сцены
                self.view?.presentScene(gameScene, transition: transition)//Создание перехода
            } else if nodesArray.first?.name == "levelButton"{//Кнопка сложность
                changeLevel()//Вызываем ф-ию смены сложности
            }
        }
    }
    func changeLevel(){
        let userLevel = UserDefaults.standard//Переменная которая записываеи в память значение
        if labelLevelNode.text == "Легко"{
            labelLevelNode.text = "Сложно"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "Легко"
            userLevel.set(false, forKey: "hard")
        }
        userLevel.synchronize()//Синхронизация
    }
}
