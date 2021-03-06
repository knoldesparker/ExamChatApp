//
//  SecondViewController.swift
//  ExamChatApp
//
//  Created by Tommy Mikkelsen on 31/05/2019.
//  Copyright © 2019 Casper Sillemann. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseUI


var groceryListId = " "
class SecondViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var groceryListItem = [NotebookItem]()
    var groceryList: Notebook?
    var quantityValue: Int!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addItemBtn: UIBarButtonItem!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        print("new view")
        checkForUpdates()
        getData()
        self.tableView.tableFooterView = UIView(frame: .zero)

        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        print(groceryListId)
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        
    }
    
    
    func checkForUpdates() {
        db.collection("notebook").document(groceryListId).collection("items").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("Error adding snapshot listener \(error!.localizedDescription)")
                return
            }
            self.getData()
            print("setting new data")
        }
    }
    
    func getData(){
        db.collection("notebook").document(groceryListId).collection("items").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR: reading documents \(error!.localizedDescription)")
                return
            }
            self.groceryListItem = []
            for document in querySnapshot!.documents {
                let groceryListItemData = NotebookItem(dictionary: document.data())
                groceryListItemData.name = document.get("name") as! String
                self.groceryListItem.append(groceryListItemData)
            }
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func addItemBtnPressed(_ sender: Any) {
        print("add btn pressed")
        
        let ac = UIAlertController(title: "Enter item to list", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            self.addItem(itemName: answer.text!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
        
    }
    
    func addItem(itemName:String){
        let item = NotebookItem(name: itemName, quantity: 1, notes: "", postingUserID: user!.uid)
        let notebookRef = self.db.collection("notebook").document(groceryListId).collection("items")
        notebookRef.document().setData(item.dictionary){ err in
            if err != nil {
                print("issue here")
            }else{
                print("Document was saved")
            }
        }
        
    }
    
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        print("pressing share btn")
    }
    
    
}
extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryListItem.count

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "popupsegue"{
            let popVC = segue.destination as! PopuoViewController // identifies the target controller
            popVC.parentVC = self // knows where it comes from
            popVC.preferredContentSize = CGSize(width: 300, height: 300)
            popVC.presentationController?.delegate = self
            popVC.groceryListId = groceryListId //sends the id for the list over
            
        
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 300, height: tableView.contentSize.height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = groceryListItem[indexPath.row].name
        return cell
    }
    
    
    
}
