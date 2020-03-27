//
//  TodoList.swift
//  Checklist
//
//  Created by Shishira on 3/2/20.
//  Copyright © 2020 Shishira. All rights reserved.
//

import Foundation
class TodoList {
    
    enum Priority : Int, CaseIterable {
        case high, medium, low, no
    }
    
    private var highPriorityTodolist : [ChecklistItem] = []
    private var mediumPriorityTodolist : [ChecklistItem] = []
    private var lowPriorityTodolist : [ChecklistItem] = []
    private var noPriorityTodolist : [ChecklistItem] = []
    
    init() {
        let row0Item = ChecklistItem()
        let row1Item = ChecklistItem()
        let row2Item = ChecklistItem()
        let row3Item = ChecklistItem()
        let row4Item = ChecklistItem()
        
        row0Item.text = "Take a jog"
        row1Item.text = "Watch a movie"
        row2Item.text = "Code an App"
        row3Item.text = "Walk the dog"
        row4Item.text = "Study design"
        
        
        addTodo(row0Item, with: .medium)
        addTodo(row1Item, with: .medium)
        addTodo(row2Item, with: .medium)
        addTodo(row3Item, with: .medium)
        addTodo(row4Item, with: .medium)
        
    }
    
    func addTodo(_ item: ChecklistItem, with priority: Priority) {
        switch priority {
        case .high:
            highPriorityTodolist.append(item)
        case .medium:
            mediumPriorityTodolist.append(item)
        case .low:
            lowPriorityTodolist.append(item)
        case .no:
            noPriorityTodolist.append(item)
        }
    }
    
    func todolist(for priority: Priority) -> [ChecklistItem]
    {
        switch priority {
        case .high:
            return highPriorityTodolist
        case .medium:
            return mediumPriorityTodolist
        case .low:
            return lowPriorityTodolist
        case .no:
            return noPriorityTodolist
        }
    }
    
    func addNewTodoItem() -> ChecklistItem {
        let newchecklistItem = ChecklistItem()
        newchecklistItem.text = addTitle()
        mediumPriorityTodolist.append(newchecklistItem)
        return newchecklistItem
    }
    
    func move(item: ChecklistItem, to index: Int) {
//        guard let currentIndex = todos.index(of: item) else{
//            return
//        }
//        todos.remove(at: currentIndex)
//        todos.insert(item, at: index)
    }
    
    func remove(_ item: ChecklistItem, from priority: Priority, at index: Int) {
        switch priority {
        case .high:
            highPriorityTodolist.remove(at: index)
        case .medium:
            mediumPriorityTodolist.remove(at: index)
        case .low:
            lowPriorityTodolist.remove(at: index)
        case .no:
            noPriorityTodolist.remove(at: index)
        }
    }
    
//    func remove(items : [ChecklistItem]) {
//        for item in items {
//            if let index = todos.index(of: item){
//                todos.remove(at: index)
//            }
//        }
//
//
//    }
    private func addTitle() -> String {
        let tiltes = ["Nothing todo", "Fill me out", "take a jog", "Talk to friends", "Get a job"]
        let randomNum = Int.random(in: 0 ...  tiltes.count - 1)
        return tiltes[randomNum]
    }
}
