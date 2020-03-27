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
    var tabledata : [[ChecklistItem?]?]!
    
    @IBAction func deleteRows(_ sender: Any) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            var items = [ChecklistItem]()
            for indexPath in selectedRows {
                items.append(todoList.todos[indexPath.row])
            }
            todoList.remove(items: items)
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
        
        let sectionTitlesCount = UILocalizedIndexedCollation.current().sectionTitles.count
        var allSections = [[ChecklistItem?]?](repeating: nil, count: sectionTitlesCount)
        var sectionNumber = 0
        let collation = UILocalizedIndexedCollation.current()
        
        for item in todoList.todos {
            sectionNumber = collation.section(for: item, collationStringSelector: #selector(getter:ChecklistItem.text))
            if allSections[sectionNumber] == nil{
                allSections[sectionNumber] = [ChecklistItem?]()
            }
            allSections[sectionNumber]!.append(item)
        }
        tabledata = allSections
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
    }

    @IBAction func addNewChecklistItem(_ sender: Any) {
        let row = todoList.todos.count
        todoList.addNewTodoItem()
        
        
        let indexpath = IndexPath.init(row: row, section: 0)
        tableView.insertRows(at: [indexpath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return todoList.todos.count
        return tabledata[section] == nil ? 0 : tabledata[section]!.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .insert:
            todoList.addNewTodoItem()
            tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete:
            todoList.todos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .none:
            print("did nothing")
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for:   indexPath)
//        let item = todoList.todos[indexPath.row]
        if let item = tabledata[indexPath.section]?[indexPath.row] {
            configureText(for: cell, with: item)
            configureCheckmark(for: cell, with : item)
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tabledata.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return UILocalizedIndexedCollation.current().sectionTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UILocalizedIndexedCollation.current().sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        if let cell = tableView.cellForRow(at: indexPath){
            let item = todoList.todos[indexPath.row]
            item.toggleChecked()
            configureCheckmark(for : cell, with: item)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        todoList.move(item: todoList.todos[sourceIndexPath.row], to: destinationIndexPath.row)
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
                     let indexpath = tableView.indexPath(for: cell) {
                    let item = todoList.todos[indexpath.row]
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
        let rowIndex = todoList.todos.count
        todoList.todos.append(item)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func itemViewController(_ controller: ItemTableViewController, DidFinishEditing item: ChecklistItem) {
        navigationController?.popViewController(animated: true)
        if let index = todoList.todos.index(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
    }
}

