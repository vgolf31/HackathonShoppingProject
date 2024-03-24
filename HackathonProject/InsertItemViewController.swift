//
//  InsertItemViewController.swift
//  HackathonProject
//
//  Created by Veer M on 3/23/24.
//

import UIKit

class InsertItemViewController: UIViewController {
    
    @IBOutlet weak var CategoryButton: UIButton!
    @IBOutlet weak var ItemButton: UIButton!
    
    @IBOutlet weak var CategoryMenu: UIMenu!
    @IBOutlet weak var ItemMenu: UIMenu!
    @IBOutlet weak var InsertItemButton: UIButton!

    
    let defaults = UserDefaults.standard
    var arr:[String?] = []
    var innerarr:[String?] = []
    var dict = [String:Any?]()
    override func viewDidLoad() {
        super.viewDidLoad()
        dict = self.defaults.dictionary(forKey: "departmentsDictionary")!
        let keysArray = Array(dict.keys)
        arr = keysArray
        
        var menuItems = [UIAction]()
        
        for item in arr {
            let menuItem = UIAction(title: item!, handler: { _ in
                self.CategoryButton.setTitle(item, for: .normal)
                self.ItemButton.setTitle("Specific Item", for: .normal)
                self.innerarr = self.dict[item!] as? [String?] ?? []
                var menuItems1 = [UIAction]()
                for item1 in self.innerarr {
                    let menuItem1 = UIAction(title: item1!, handler: { _ in
                        self.ItemButton.setTitle(item1, for: .normal)
                        print(self.dict[item1!])
                    })
                    menuItems1.append(menuItem1)
                }
                let menu1 = UIMenu(title: "Choose", children: menuItems1)
                
                // Assign menu to dropdown button
                self.ItemButton.menu = menu1
            })
            menuItems.append(menuItem)
        }
        
        // Create menu with menu items
        let menu = UIMenu(title: "Choose", children: menuItems)
        
        // Assign menu to dropdown button
        CategoryButton.menu = menu
    }
    
    @IBAction func InsertionButtonPressed(_ sender: Any) {
        if(CategoryButton.currentTitle != "Category" && ItemButton.currentTitle != "Specific Item"){
            var currentitemarray = self.defaults.array(forKey: "grocery_list")
            if(currentitemarray == nil){
                let new_currentitemarray:[String] = [ItemButton.currentTitle!]
                self.defaults.set(new_currentitemarray, forKey: "grocery_list")
            } else{
                currentitemarray?.append(ItemButton.currentTitle)
                self.defaults.set(currentitemarray, forKey: "grocery_list")
            }
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemListViewController") as? ItemListViewController
            {
                present(vc, animated: false, completion: nil)
            }
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
