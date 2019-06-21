//
//  NoteTableViewController.swift
//  Noted Notable
//
//  Created by Carson Yan on 2019-03-26.
//  Copyright © 2019 Carson Yan. All rights reserved.
//
import CoreData
import UIKit
import SwipeCellKit

class NoteTableViewController: UITableViewController, SwipeTableViewCellDelegate {
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  var notes = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNotes()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
  
  @IBAction func addNoteBtnTapped(_ sender: UIBarButtonItem) {
    // we need this in order to access the text field data outside of the 'addTextField' scope below
    var tempTextField = UITextField()
    var tempTextField2 = UITextField()

    // create a UIAlertController object
    let alertController = UIAlertController(title: "Add New Note", message: "", preferredStyle: .alert)

    // create a UIAlertAction object
    let alertAction = UIAlertAction(title: "Done", style: .default) { (action) in
      // create a new item from our Item core data entity (we pass it the context)
      let newNote = Note(context: self.context)

      // if the text field text is not nil
      if let text = tempTextField.text,
         let body = tempTextField2.text {
        // set the item attributes
        newNote.title = text
        newNote.body = body
        // append the item to our items array
        self.notes.append(newNote)

        // call our saveItems() method which saves our context and reloads the table
        self.saveNotes()
      }
    }
    
    alertController.addTextField { (textField) in
      textField.placeholder = "Title"
      tempTextField = textField
    }
    
    alertController.addTextField { (textField2) in
      textField2.placeholder = "Note Details"
      tempTextField2 = textField2
    }

    // Add the action we created above to our alert controller
    alertController.addAction(alertAction)
    // show our alert on screen
    present(alertController, animated: true, completion: nil)
  }
  
  func saveNotes() {
    // wrap our try statement below in a do/catch block so we can handle any errors
    do {
      // save our context
      try context.save()
    } catch {
      print("Error saving context \(error)")
    }
    
    // reload our table to reflect any changes
    tableView.reloadData()
  }
  
  func loadNotes() {
    // create a new fetch request of type NSFetchRequest<Item> - you must provide a type
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    
    // wrap our try statement below in a do/catch block so we can handle any errors
    do {
      // fetch our items using our fetch request, save them in our items array
      notes = try context.fetch(fetchRequest)
    } catch {
      print("Error fetching notes: \(error)")
    }
    
    // reload our table to reflect any changes
    tableView.reloadData()
  }

    // MARK: - Table view data source
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return notes.count
    }
  
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! SwipeTableViewCell
      
      cell.delegate = self
      
      let note = notes[indexPath.row]
      
      cell.textLabel?.text = note.title
      return cell
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let noteDetailViewController = segue.destination as? NoteDetailViewController,
        let index = self.tableView.indexPathForSelectedRow?.row {
        noteDetailViewController.note = notes[index]
      }
    }
  
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    
    // initialize a SwipeAction object
    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in
      // delete the item from our context
      self.context.delete(self.notes[indexPath.row])
      // remove the item from the items array
      self.notes.remove(at: indexPath.row)
      
      // save our context
      self.saveNotes()
    }
    
    // customize the action appearance
    deleteAction.image = UIImage(named: "trash")
    
    return [deleteAction]
  }
}




// MARK: Search Bar Methods
extension NoteTableViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    // if our search text is nil we should not execute any more code and just return
    guard let searchText = searchBar.text else { return }
    searchItems(searchText: searchText)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.count > 0 {
      searchItems(searchText: searchText)
    } else if searchText.count == 0 {
      // show the full list of items
      loadNotes()
    }
  }
  
  // this method's use is restricted to this file
  fileprivate func searchItems(searchText: String) {
    // our fetch request for items
    let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
    
    // a predicate allows us to create a filter or mapping for our items
    // [c] means ignore case
    let predicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
    
    // the sort descriptor allows us to tell the request how we want our data sorted
    let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    
    // set the predicate and sort descriptors for on the request
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // retrieve the items with the request we created
    do {
      notes = try context.fetch(fetchRequest)
    } catch {
      print("Error fetching items: \(error)")
    }
    
    // reload our table with our new data
    tableView.reloadData()
  }
}
