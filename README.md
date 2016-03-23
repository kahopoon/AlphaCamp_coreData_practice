# AlphaCamp_coreData_practice

![Alt text](screenshot/mainScreen.png?raw=true "main screen")

check CoreData at project create, input all necessary entity and attributes, create NSManagedObject subclass for entity, and not focus on ViewController code.

## Import
```swift
import CoreData
```
remember to import CoreData first XD

## Declare on outlets
```swift
@IBOutlet weak var textfieldISBN, textfieldBookName, textfieldAuthor, textfieldPrice: UITextField!
@IBOutlet weak var addButton, queryallButton, queryoneButton, updateButton, deleteButton: UIButton!
@IBOutlet weak var textviewShowAll: UITextView!

var currentBook:Book!
```
here we have 4 UITextField, 5 UIButton, 1 UITextView. and here we also declare currentBook for pointer/indicator for us to manipulate some function like deleting on specific record.

## AppDelegate shortcut
```swift
let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
```
shortcut for AppDelegate and it's CoreData stack function, easy call for later on code...

## viewDidLoad
```swift
override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        buttonBeauty([addButton, queryallButton, queryoneButton, updateButton, deleteButton])
        textviewShowAll.layer.cornerRadius = 5
    }
    
func buttonBeauty(buttons:[UIButton]) {
        for button in buttons {
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
```
nothing special to start, just defined some UIButton appearance changes, wrapped them as array to buttonBeauty function, they all now with rounded corner and white color border :) 

## helper function
before we get started with button's action, let's introdue our helper functions like buttonBeauty.

``` swift
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
```
In bookPrint, we get Book rows in array, for each and for all, we concatenate data into single string, separate by new line and put it on test view, with white color text and 14 font size

```swift
    func inputValid() -> Bool {
        return (textfieldBookName.text != "" && textfieldAuthor.text != "" && textfieldPrice.text != "" && textfieldISBN.text != "")
    }
```
This function will return true if user has inputted at all textfields.

```swift    
    func warningMessage(msg: String) {
        let alert = UIAlertController(title: "Warning", message: msg, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
```
Pop up warning with variable string

```swift
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
```
search function, by this you may now easily make search by different attribute 's value like isbn/book name/author/price...that used on button query action. and extra reason is, I have to use this on button add action as I would like to check if ISBN duplicated with existing records...

```swift
    func clearUI() {
        view.endEditing(true)
        textfieldISBN.text?.removeAll()
        textfieldPrice.text?.removeAll()
        textfieldAuthor.text?.removeAll()
        textfieldBookName.text?.removeAll()
        textviewShowAll.text?.removeAll()
    }
```
call to dismiss keyboard, clear textfield data.

## action for add record button
```swift
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
```
This add button function will first check either any input field is empty or ISBN has been found in existing records, pop up appropriate warning message. insert record only if everything alrite.

```swift
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
```
most straight forward one, let name as the sortDescriptor at sorting, display all records, if no record found, pop up no data message.

```swift
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
```
query single row function, it get results from help of searchRowBy function, if return result is empty, pop up not found warning, else return result back on text field and save on class variable 'currentBook' (because we could have it edit and update later)

```swift
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
```
on before, we save query result into variable currentBook, more than data assignment, it act as an pointer/indicator to tell which specific record is. And back to this function, it check if all text fields are not empty, then corresponding text fields' data will replace with currentBook's data, when the data come save, it overwrite and update the existing record with pointer identification

```swift
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
```
simply use the concept above, use currentBook as pointer, if the pointer is not null, delete object with corresponding address and clear the pointer(as become useless after), else return warning message saying nothing has been deleted.

## some screenshots
`record added / duplicated warning / input incomplete warning`
![Alt text](screenshot/addComplete.png?raw=true "record added")
![Alt text](screenshot/addDuplicate.png?raw=true "duplicated warning")
![Alt text](screenshot/addIncomplete.png?raw=true "input incomplete warning")

`query all records / query single record`
![Alt text](screenshot/queryAll.png?raw=true "query all records")
![Alt text](screenshot/queryOne.png?raw=true "query single records")

`update record row / before deletion`
![Alt text](screenshot/updateRow.png?raw=true "update record row")
![Alt text](screenshot/beforeDelete.png?raw=true "before deletion")
