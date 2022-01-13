//
//  ViewController.swift
//  ToBuyList
//
//  Created by administrator on 12/01/2022.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class GroceryListTableViewController: UITableViewController {
  // MARK: Constants
  let listToUsers = "ListToUsers"
  let ref = Database.database().reference(withPath: "grocery-items")
  var refObservers: [DatabaseHandle] = []

  let usersRef = Database.database().reference(withPath: "online")
  var usersRefObservers: [DatabaseHandle] = []

  // MARK: Properties
  var items: [GroceryItem] = []
  var user: User?
  var onlineUserCount = UIBarButtonItem()
  var handle: AuthStateDidChangeListenerHandle?

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.allowsMultipleSelectionDuringEditing = false

    onlineUserCount = UIBarButtonItem(
      title: "1",
      style: .plain,
      target: self,
      action: #selector(onlineUserCountDidTouch))
    onlineUserCount.tintColor = .black
    navigationItem.leftBarButtonItem = onlineUserCount
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let completed = ref
      .queryOrdered(byChild: "completed")
      .observe(.value) { snapshot in
        var newItems: [GroceryItem] = []
        for child in snapshot.children {
          if
            let snapshot = child as? DataSnapshot,
            let groceryItem = GroceryItem(snapshot: snapshot) {
            newItems.append(groceryItem)
          }
        }
        self.items = newItems
        self.tableView.reloadData()
      }
    refObservers.append(completed)

    handle = Auth.auth().addStateDidChangeListener { _, user in
      guard let user = user else { return }
      self.user = User(authData: user)

      let currentUserRef = self.usersRef.child(user.uid)
      currentUserRef.setValue(user.email)
      currentUserRef.onDisconnectRemoveValue()
    }

    let users = usersRef.observe(.value) { snapshot in
      if snapshot.exists() {
        self.onlineUserCount.title = snapshot.childrenCount.description
      } else {
        self.onlineUserCount.title = "1"
      }
    }
    usersRefObservers.append(users)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    refObservers.forEach(ref.removeObserver(withHandle:))
    refObservers = []
    usersRefObservers.forEach(usersRef.removeObserver(withHandle:))
    usersRefObservers = []
    guard let handle = handle else { return }
    Auth.auth().removeStateDidChangeListener(handle)
  }

  // MARK: UITableView Delegate methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    let groceryItem = items[indexPath.row]

    cell.textLabel?.text = groceryItem.name
    cell.detailTextLabel?.text = groceryItem.addedByUser

    toggleCellCheckbox(cell, isCompleted: groceryItem.completed)

    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let groceryItem = items[indexPath.row]
      groceryItem.ref?.removeValue()
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let groceryItem = items[indexPath.row]
    let toggledCompletion = !groceryItem.completed
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    groceryItem.ref?.updateChildValues(["completed": toggledCompletion])
  }

  func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = .black
      cell.detailTextLabel?.textColor = .black
    } else {
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = .gray
      cell.detailTextLabel?.textColor = .gray
    }
  }

  // MARK: Add Item
  @IBAction func addItemDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(
      title: "Grocery Item",
      message: "Add an Item",
      preferredStyle: .alert)

    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
      guard
        let textField = alert.textFields?.first,
        let text = textField.text,
        let user = self.user
      else { return }

      let groceryItem = GroceryItem(
        name: text,
        addedByUser: user.email,
        completed: false)

      let groceryItemRef = self.ref.child(text.lowercased())
      groceryItemRef.setValue(groceryItem.toAnyObject())
    }

    let cancelAction = UIAlertAction(
      title: "Cancel",
      style: .cancel)

    alert.addTextField()
    alert.addAction(saveAction)
    alert.addAction(cancelAction)

    present(alert, animated: true, completion: nil)
  }

  @objc func onlineUserCountDidTouch() {
    performSegue(withIdentifier: listToUsers, sender: nil)
  }
}
