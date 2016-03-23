//
//  ViewController.swift
//  CDTest
//
//  Created by Ka Ho on 23/3/2016.
//  Copyright © 2016 Ka Ho. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var textfieldISBN, textfieldBookName, textfieldAuthor, textfieldPrice: UITextField!
    @IBOutlet weak var addButton, queryallButton, queryoneButton, updateButton, deleteButton: UIButton!
    @IBOutlet weak var textviewShowAll: UITextView!
    
    var currentBook:Book!
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buttonBeauty([addButton, queryallButton, queryoneButton, updateButton, deleteButton])
        textviewShowAll.layer.cornerRadius = 5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addBook(sender: AnyObject) {
        if inputValid() && searchRowBy("isbn", value: textfieldISBN.text!).isEmpty {
            let saveBook = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: self.managedObjectContext) as! Book
            saveBook.isbn = textfieldISBN.text
            saveBook.author = textfieldAuthor.text
            saveBook.name = textfieldBookName.text
            saveBook.price = NSDecimalNumber(string: textfieldPrice.text!)
            appDelegate.saveContext()
            clearUI()
            bookPrint([saveBook])
        } else if !searchRowBy("isbn", value: textfieldISBN.text!).isEmpty {
            warningMessage("Duplicate ISBN! Insert aborted!")
        } else {
            warningMessage("Incomplete input!")
        }
    }
    
    @IBAction func queryAll(sender: AnyObject) {
        let fetchRequest = NSFetchRequest(entityName: "Book")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            clearUI()
            let books = try (managedObjectContext.executeFetchRequest(fetchRequest) as? [Book])!
            if books.isEmpty {
                warningMessage("No Books Data!")
            } else {
                bookPrint(books)
            }
        } catch {
            //
        }
    }
    
    @IBAction func queryOne(sender: AnyObject) {
        if textfieldISBN.text != "" {
            let results = searchRowBy("isbn", value: textfieldISBN.text!)
            if results.isEmpty {
                warningMessage("Search not found!")
            } else {
                currentBook = results.first
                clearUI()
                
                textfieldISBN.text = currentBook?.isbn
                textfieldBookName.text = currentBook?.name
                textfieldPrice.text = String((currentBook?.price)!)
                textfieldAuthor.text = currentBook?.author
            }
            
        } else {
            warningMessage("Please enter ISBN to search!")
        }
    }
 
    @IBAction func updateBook(sender: AnyObject) {
        
        if inputValid() {
            currentBook?.isbn = textfieldISBN.text
            currentBook?.name = textfieldBookName.text
            currentBook?.author = textfieldAuthor.text
            currentBook?.price = NSDecimalNumber(string: textfieldPrice.text)
            
            appDelegate.saveContext()
            bookPrint([currentBook])
            clearUI()
        } else {
            warningMessage("Input incomplete!")
        }
    }
    
    @IBAction func deleteBook(sender: AnyObject) {
        if currentBook != nil {
            managedObjectContext.deleteObject(currentBook!)
            appDelegate.saveContext()
            currentBook = nil
            clearUI()
        } else {
            warningMessage("Sorry but I don't know what to delete!")
        }
    }
    
    func bookPrint(books:[Book]) {
        var allShow = ""
        for book in books {
            var rowShow = ""
            rowShow += "ISBN: " + book.isbn! + "\n"
            rowShow += "Book Name: " + book.name! + "\n"
            rowShow += "Author: " + book.author! + "\n"
            rowShow += "Price: " + String(book.price!) + "\n\n"
            allShow += rowShow
        }
        textviewShowAll.text = allShow
        textviewShowAll.textColor = UIColor.whiteColor()
        textviewShowAll.font = UIFont(name: "ArialMT", size: 14)
    }
    
    func buttonBeauty(buttons:[UIButton]) {
        for button in buttons {
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    func inputValid() -> Bool {
        return (textfieldBookName.text != "" && textfieldAuthor.text != "" && textfieldPrice.text != "" && textfieldISBN.text != "")
    }
    
    func warningMessage(msg: String) {
        let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func searchRowBy(method: String, value: String) -> [Book] {
        var result:[Book]!
        let fetchRequest = NSFetchRequest(entityName: "Book")
        let fetchPredicate = NSPredicate(format: method + "== %@", value)
        fetchRequest.predicate = fetchPredicate
        
        do {
            if let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Book] {
                result = fetchResults
            }
        } catch {
            //
        }
        return result
    }
    
    func clearUI() {
        view.endEditing(true)
        textfieldISBN.text?.removeAll()
        textfieldPrice.text?.removeAll()
        textfieldAuthor.text?.removeAll()
        textfieldBookName.text?.removeAll()
        textviewShowAll.text?.removeAll()
    }
}

