//
//  SearchViewController.swift
//  MariGold
//
//  Created by Pravin Sivabalan on 4/17/18.
//  Copyright © 2018 MariGold. All rights reserved.
//

import UIKit
import Alamofire

struct Drug {
    var cui: String
    var name: String
    var tty: String
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var spinner: UIView!
    var drugNames: [String] = []
    var drugs: [Drug] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let symptom = searchBar.text else {
            self.searchBar.endEditing(true)
            return
        }
        
        if symptom == "" {
            self.searchBar.endEditing(true)
            return
        }
        
        let body: [String: Any] = [
            "symptom": symptom
        ]
        
        self.spinner = UIViewController.displaySpinner(onView: self.tableView)

        let req = Alamofire.request(api.rootURL + "/meds/search", method: .post, parameters: body, encoding: JSONEncoding.default, headers: User.header)
        req.responseJSON { resp in
            self.searchBar.endEditing(true)
            
            UIViewController.removeSpinner(spinner: self.spinner)
            
            guard let data = resp.result.value else {
                return
            }
            
            guard let json = data as? NSDictionary else {
                print("Could not read in data as JSON")
                return
            }
            
            guard let message = json["message"] as? String else {
                print("Could not get message")
                return
            }
            
            if (message != "ok") {
                print(resp)
                self.createAlert(title: "Lookup", message: "Could not find drugs to help with your symptom")
            }
            
            guard let drugs = json["drugs"] as? [AnyObject] else {
                print("Could not read in matches")
                return
            }
            self.readDrugs(drugs: drugs)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drugNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = drugNames[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        if identifier == "displayDrugDetails" {
            guard let indexPath = tableView.indexPathForSelectedRow else { NSLog("Could not get index path of selected medication"); return }
            let nextVC = segue.destination as! SearchDetailsTableViewController
            nextVC.Cui = drugs[indexPath.row].cui
            nextVC.MedName = drugNames[indexPath.row]
        }
    }
    
    func readDrugs(drugs: [Any]) {
        self.drugNames.removeAll()
        self.drugs.removeAll()
        for drug in drugs {
            let obj = drug as! NSDictionary
            let name = obj["name"] as! String
            let cui = obj["cui"] as! String
            let tty = obj["tty"] as! String
            self.drugNames.append(name)
            self.drugs.append(Drug(cui: cui, name: name, tty: tty))
        }
        tableView.reloadData()
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}
