//
//  ViewController.swift
//  Checklist
//
//  Created by Shishira on 1/22/20.
//  Copyright © 2020 Shishira. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController {
    
    var todoList : TodoList

    private func priorityForSectionIndex(_ index: Int) -> TodoList.Priority? {
        return TodoList.Priority(rawValue: index)
    }
    
    @IBAction func deleteRows(_ sender: Any) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                if let priority = priorityForSectionIndex(indexPath.section){
                    let todos = todoList.todolist(for: priority)
                    let item = todos[indexPath.row]
                    todoList.remove(item, from: priority, at: indexPath.row)
                }
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        todoList = TodoList()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Checklist"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
    }

    @IBAction func addNewChecklistItem(_ sender: Any) {
        let row = todoList.todolist(for: .medium).count
        _ = todoList.addNewTodoItem()
        
        let indexpath = IndexPath.init(row: row, section: TodoList.Priority.medium.rawValue)
        tableView.insertRows(at: [indexpath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return todoList.todos.count
        if let priority = priorityForSectionIndex(section) {
            return todoList.todolist(for: priority).count
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .insert:
            _ = todoList.addNewTodoItem()
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            if let priority = priorityForSectionIndex(indexPath.section) {
                let items = todoList.todolist(for: priority)
                let item = items[indexPath.row]
                todoList.remove(item, from: priority, at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .none:
            print("did nothing")
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for:   indexPath)
//        let item = todoList.todos[indexPath.row]
        if let priority = priorityForSectionIndex(indexPath.section) {
            let items = todoList.todolist(for: priority)
            let item = items[indexPath.row]
            configureText(for: cell, with: item)
            configureCheckmark(for: cell, with : item)
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return TodoList.Priority.allCases.count
    }
    
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return UILocalizedIndexedCollation.current().sectionTitles
//    }
//
//    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index)
//    }
//
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String? = nil
        if let priority = priorityForSectionIndex(section) {
            switch priority {
            case .high : title = "High Priority"
            case .medium : title = "Medium Priority"
            case .low : title = "Low Priority"
            case .no : title = "No Priority"
            }
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath){
            if let priority = priorityForSectionIndex(indexPath.section) {
                let items = todoList.todolist(for: priority)
                let item = items[indexPath.row]
                item.toggleChecked()
                configureCheckmark(for : cell, with: item)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let srcPriority = priorityForSectionIndex(sourceIndexPath.section),
            let destPriority = priorityForSectionIndex(destinationIndexPath.section)
        {
            let item = todoList.todolist(for: srcPriority)[sourceIndexPath.row]
            todoList.move(item: item, from: srcPriority, at: sourceIndexPath.row, to: destPriority, at: destinationIndexPath.row)
        }
        tableView.reloadData()
    }
    
    func configureText(for cell: UITableViewCell, with item:ChecklistItem) {
        if let checklistCell = cell as? ChecklistTableViewCell {
            checklistCell.checklistText.text = item.text
        }
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item:ChecklistItem) {
        guard let checklistCell = cell as? ChecklistTableViewCell else {
            return
        }
        if item.checked
        {
            checklistCell.checkmarkLabel.text = "✔︎"
        }
        else
        {
            checklistCell.checkmarkLabel.text = ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItemSegue" {
            if let addItemTableViewController = segue.destination as? ItemTableViewController {
                addItemTableViewController.delegate = self
            }
        }
        if segue.identifier == "EditItemSegue" {
            if let addItemTableViewController = segue.destination as? ItemTableViewController {
                addItemTableViewController.delegate = self
                if let cell = sender as? UITableViewCell,
                     let indexpath = tableView.indexPath(for: cell),
                     let priority = priorityForSectionIndex(indexpath.section){
                    let item = todoList.todolist(for: priority)[indexpath.row]
                    addItemTableViewController.itemToEdit = item
                }
            }
        }
    }
}

extension ChecklistViewController: ItemViewControllerDelegate {
    func itemViewControllerDidCancel(_ controller: ItemTableViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func itemViewController(_ controller: ItemTableViewController, DidFinishAdding item: ChecklistItem) {
        navigationController?.popViewController(animated: true)
        todoList.addTodo(item, with: .medium)
        let rowIndex = todoList.todolist(for: .medium).count - 1
        let indexPath = IndexPath(row: rowIndex, section: TodoList.Priority.medium.rawValue)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func itemViewController(_ controller: ItemTableViewController, DidFinishEditing item: ChecklistItem) {
        navigationController?.popViewController(animated: true)
        for priority in TodoList.Priority.allCases {
            let currentItems = todoList.todolist(for: priority)
            if let index = currentItems.index(of: item)
            {
                let indexPath = IndexPath(row: index, section: priority.rawValue)
                if let cell = tableView.cellForRow(at: indexPath) {
                    configureText(for: cell, with: item)
                }
            }
        }
    }
}

