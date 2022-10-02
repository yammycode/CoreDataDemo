//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 29.09.2022.
//

import UIKit
import CoreData

final class TaskListViewController: UITableViewController {
    
    // MARK: - private properties
    private let storage = StorageManager.shared
    private let cellID = "task"
    private var taskList: [Task] = []

    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskList = storage.fetchTasks()
        tableView.reloadData()
    }

    // MARK: - Private methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
}

// MARK: - Table view settings
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            storage.delete(task: taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        showAlert(with: "Edit task", and: "What do you want to do?", from: task)
    }
}

// MARK: - Alert extension
extension TaskListViewController {
    private func showAlert(with title: String, and messege: String, from task: Task? = nil) {
        let alert = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }

        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            guard let task else { return }
            self.update(task: task, with: taskName)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        task == nil ? alert.addAction(saveAction) : alert.addAction(updateAction)

        alert.addAction(cancelAction)

        alert.addTextField { textField in
            if task == nil {
                textField.placeholder = "New Task"
            } else {
                textField.placeholder = "Edit Task"
                textField.text = task?.name
            }
        }

        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let task = storage.saveTask(taskName)
        taskList.append(task)

        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }

    private func update(task: Task, with name: String) {
        storage.update(task: task, with: name)
        tableView.reloadData()
    }
}
