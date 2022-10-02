//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Anton Saltykov on 01.10.2022.
//

import Foundation
import CoreData


class StorageManager {

    static let shared = StorageManager();
    private let context: NSManagedObjectContext

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func fetchTasks() -> [Task] {
        let fetchRequest = Task.fetchRequest()

        do {
            let taskList = try context.fetch(fetchRequest)
            return taskList
        } catch {
            print("Failed to fetch data", error)
            return []
        }
    }

    func saveTask(_ taskName: String) -> Task {
        let task = Task(context: context)
        task.name = taskName
        saveContext()
        return task
    }

    func delete(task: Task) {
        context.delete(task)
        saveContext()
    }

    func update(task: Task, with name: String) {
        task.name = name
        saveContext()
    }

    private init() {
        context = persistentContainer.viewContext
    }

}
