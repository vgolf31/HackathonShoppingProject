//
//  ItemListViewController.swift
//  HackathonProject
//
//  Created by Veer M on 3/23/24.
//

import UIKit

class ItemListViewController: UIViewController {
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var ScrapListButton: UIButton!
    @IBOutlet weak var ListField: UITextField!
    @IBOutlet weak var SaveListButton: UIButton!
    @IBOutlet weak var FinalPriceLabel: UILabel!
    var priceList:[Double?] = []
    override func viewDidLoad() {
        let list = self.defaults.stringArray(forKey:"grocery_list")
        let dict = self.defaults.dictionary(forKey: "priceDictionary")!
        var totalprice = 0.0
        if(list != nil){
            for item in list!{
                if let price = dict[item] as? Double {
                        totalprice = totalprice + price
                        priceList.append(price)
                    } else {
                        priceList.append(nil)
                }
            }
            self.defaults.set(priceList, forKey: "priceList")
            FinalPriceLabel.text = "Final Price: $" + String(totalprice)
        }
        tableView.delegate = self
        tableView.dataSource = self
        ListField.text = self.defaults.string(forKey: "current_name")
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func SaveListPressed(_ sender: Any) {
        guard let name = ListField.text, !name.isEmpty else {
            return
        }

        var listofstores = self.defaults.stringArray(forKey: "listofstores") ?? []
        
        if listofstores.contains(name) {
            self.defaults.set(self.defaults.stringArray(forKey:"grocery_list"), forKey: name)
        }else{
            listofstores.append(name)
            self.defaults.set(self.defaults.stringArray(forKey:"grocery_list"), forKey: name)
            self.defaults.set(listofstores, forKey: "listofstores")
        }
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        {
            present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func ScrapListButtonPressed(_ sender: Any) {
        let name = self.defaults.string(forKey: "current_name")
        var listofstores = self.defaults.stringArray(forKey: "listofstores") ?? []
        if(name != nil){
            for i in 0...(listofstores.count-1){
                if(listofstores[i] == name){
                    listofstores.remove(at: i)
                    break
                }
            }
            self.defaults.set(listofstores, forKey: "listofstores")
        }
        self.defaults.set(nil, forKey:"grocery_list")
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
        {
            present(vc, animated: false, completion: nil)
        }
    }
    func textFieldShouldReturn(_ ListField: UITextField) -> Bool {
        ListField.resignFirstResponder()
        return true
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
extension ItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var list = defaults.stringArray(forKey:"grocery_list")
        if(indexPath.row<list!.count){
            list?.remove(at: indexPath.row)
        }
        self.defaults.set(list, forKey: "grocery_list")
        tableView.reloadData()
    }
}
extension ItemListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaults.stringArray(forKey:"grocery_list")?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "basicStyleCell")
        let list = defaults.stringArray(forKey:"grocery_list")
        let pricelist = defaults.array(forKey:"priceList")
        cell.textLabel?.text = "Item \(indexPath.row+1): \(list![indexPath.row]) $\(pricelist![indexPath.row])"
        return cell
    }
}
