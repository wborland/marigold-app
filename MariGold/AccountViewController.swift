//
//  AccountViewController.swift
//  MariGold
//
//  Created by Pravin Sivabalan on 2/21/18.
//  Copyright © 2018 MariGold. All rights reserved.
//

import UIKit
import Alamofire

class AccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you would like to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { (action:UIAlertAction!) in
            UserDefaults.standard.removeObject(forKey: "jwt")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AccountSetupId") as UIViewController
            self.present(vc, animated: true, completion: nil)
        })
        self.present(alert, animated: true)
        
    }
    
    @IBAction func deleteAccountAction(_ sender: Any) {
        if(!Connectivity.isConnectedToInternet) {
            return createAlert(title: "Connection Error", message: "There is a connection error. Please check your internet connection or try again later.")
        }
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you would like delete your account FOREVER?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            return
        })
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action:UIAlertAction!) in
            Alamofire.request(api.rootURL + "/user/delete", method: .post, encoding: JSONEncoding.default, headers: User.header).responseJSON { response in
                if let JSON = response.result.value {
                    let data = JSON as! NSDictionary
                    if(data.object(forKey: "message") as! String == "ok") {
                        UserDefaults.standard.removeObject(forKey: "jwt")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "AccountSetupId") as UIViewController
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        self.createAlert(title: "Server Error", message: "There is a connection error. Please check your internet connection or try again later")
                    }
                }
            }
        })
        self.present(alert, animated: true)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }

}