//
//  AddItemTableViewController.swift
//  Checklist
//
//  Created by Shishira on 3/10/20.
//  Copyright © 2020 Shishira. All rights reserved.
//

import UIKit

protocol ItemViewControllerDelegate : class {
    func  itemViewControllerDidCancel(_ controller: ItemTableViewController)
    func itemViewController(_ controller: ItemTableViewController, DidFinishAdding item : ChecklistItem)
    func itemViewController(_ controller: ItemTableViewController, DidFinishEditing item : ChecklistItem)
}

class ItemTableViewController: UITableViewController {
    
    weak var delegate: ItemViewControllerDelegate?
    weak var itemToEdit : ChecklistItem?

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        if let item = itemToEdit {
            textField.text = item.text
            self.title = "Edit"
            addButton.isEnabled = true
            addButton.title = "Done"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }

    @IBAction func Cancel(_ sender: Any) {
        delegate?.itemViewControllerDidCancel(self)
    }
    
    @IBAction func addItem(_ sender: Any) {
        if let item = itemToEdit , let text = textField.text {
            item.text = text
            delegate?.itemViewController(self, DidFinishEditing: item)
        }
        else
        {
            let item = ChecklistItem()
            if let textFieldText = textField.text {
                item.text = textFieldText
            }
            item.checked = false
            delegate?.itemViewController(self, DidFinishAdding: item)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension ItemTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldtext = textField.text,
              let stringRange = Range(range, in: oldtext)
        else {
            return false
        }
        
        let newText = oldtext.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty {
            addButton.isEnabled = false
        }
        else
        {
            addButton.isEnabled = true
        }
        return true
    }
}
