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
    
    // MARK: - Override Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    // MARK: - Private Methods
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func saveTask(with title: String) {
        
        let context = getContext()
        
        guard let entinty = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        let taskObject = Task(entity: entinty, insertInto: context)
        taskObject.title = title
        
        do {
            try context.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - IB Actions
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "New Task",
            message: "Please message new task",
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
        
        let deleteAction = UIAlertAction(title: "Don't save", style: .default) {_ in
            let context = self.getContext()
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
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)

        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = task.title
        
        return cell
    }
}
