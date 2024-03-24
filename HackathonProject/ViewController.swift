//
//  ViewController.swift
//  HackathonProject
//
//  Created by Veer M on 3/23/24.
//

import UIKit

class ViewController: UIViewController {
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var AddListButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getItemDetails()
        tableView.delegate = self
        tableView.dataSource = self
    }
    func getItemDetails() {
            // Construct the URL
            guard let url = URL(string: "https://apimdev.wakefern.com/mockexample/V1/getItemDetails") else {
                print("Invalid URL")
                return
            }
            
            // Create the URL request
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("4ae9400a1eda4f14b3e7227f24b74b44", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create URLSession task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Check for errors
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                // Check if data is received
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                // Parse the JSON response
                do {
                    guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                                        print("JSON data format is incorrect")
                                        return
                                    }
                                    
                    var departmentDictionary = [String: [String]]()
                    var priceDictionary = [String: Double]()
                    // Iterate through each element in the JSON array
                    for item in jsonArray {
                        if let department = item["Department"] as? String,
                           let description = item["Description"] as? String, let priceString = item["Price"] as? String {
                            let priceWithoutCurrency = priceString.replacingOccurrences(of: "$", with: "")
                            if let price = Double(priceWithoutCurrency) {
                                priceDictionary[description] = price
                                if var descriptions = departmentDictionary[department] {
                                    descriptions.append(description)
                                    departmentDictionary[department] = descriptions
                                } else {
                                    departmentDictionary[department] = [description]
                                }
                            }
                            else {
                                print("Error: Unable to parse price for \(description)")
                            }
                            
                        }
                    }
                    print(priceDictionary)
                    self.defaults.set(departmentDictionary, forKey: "departmentsDictionary")
                    self.defaults.set(priceDictionary, forKey: "priceDictionary")
                    // Here you can handle the JSON response, parse it, and use the data as needed.
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            // Start the URLSession task
            task.resume()
        }
    
    @IBAction func AddListButtonPressed(_ sender: Any) {
        self.defaults.set(nil, forKey: "grocery_list")
        self.defaults.set(nil, forKey: "current_name")
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemListViewController") as? ItemListViewController
        {
            present(vc, animated: false, completion: nil)
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stores = defaults.stringArray(forKey:"listofstores")
        let name = stores![indexPath.row]
        self.defaults.set(name, forKey: "current_name")
        self.defaults.set(self.defaults.stringArray(forKey: name), forKey: "grocery_list")
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemListViewController") as? ItemListViewController
        {
            present(vc, animated: false, completion: nil)
        }
    }
}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaults.stringArray(forKey:"listofstores")?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "basicStyleCell")
        let list = defaults.stringArray(forKey:"listofstores")
        cell.textLabel?.text = list![indexPath.row]
        return cell
    }
}
