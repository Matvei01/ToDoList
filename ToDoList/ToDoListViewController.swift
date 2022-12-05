//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by Matvei Khlestov on 05.12.2022.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    private var tasks: [Task] = []
    private let context = StorageManager.shared.persistentContainer.viewContext
    // MARK: - Override Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - IB Actions
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        showSaveAlert(
            title: "New Task",
            message: "Please message new task"
        )
    }
    
    @IBAction func deleteTasksButton(_ sender: UIBarButtonItem) {
        showDeleteAlert(
            title: "Deleting all tasks",
            message: "Do you really wan't to delete all the tasks?"
        )
    }
}

// MARK: - Private Methods
extension ToDoListViewController {
    private func saveTask(with title: String) {
        
        guard let entinty = NSEntityDescription.entity(forEntityName: "Task",
                                                       in: context) else { return }
        
        let taskObject = Task(entity: entinty, insertInto: context)
        taskObject.title = title
        
        do {
            try context.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func deleteAllTasks() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        if let tasks = try? context.fetch(fetchRequest) {
            for task in tasks {
                context.delete(task)
            }
        }

        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func showSaveAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            let textFild = alertController.textFields?.first
            if let newTaskTitle = textFild?.text {
                self.saveTask(with: newTaskTitle)
                self.tableView.reloadData()
            }
        }
        
        alertController.addTextField() {_ in }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {_ in }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func showDeleteAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "Delete", style: .default) {_ in
            self.tasks.removeAll()
            self.deleteAllTasks()
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {_ in }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

// MARK: - Table view data source
extension ToDoListViewController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "taskCell",
            for: indexPath
        )

        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        return cell
    }
}
