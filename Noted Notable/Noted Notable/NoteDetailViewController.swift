//
//  NoteDetailViewController.swift
//  Noted Notable
//
//  Created by Carson Yan on 2019-03-31.
//  Copyright © 2019 Carson Yan. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  var note: Note?
  @IBOutlet weak var noteTitle: UITextField!
  @IBOutlet weak var noteBody: UITextView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

      self.title = note?.title

        // Do any additional setup after loading the view.
      
      if let val = note {
        
        noteTitle.text = val.title
        noteBody.text = val.body
        
      }
    }
  
  
  @IBAction func deleteBtn(_ sender: UIButton) {
//    if let val = self.note {
//      self.context.delete(val)
//      self.saveNotes()
//    }
  }
  
  func saveNotes() {
    // wrap our try statement below in a do/catch block so we can handle any errors
    do {
      // save our context
      try context.save()
    } catch {
      print("Error saving context \(error)")
    }
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
