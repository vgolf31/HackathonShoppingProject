//
//  OptimalStoresViewController.swift
//  HackathonProject
//
//  Created by Veer M on 3/23/24.
//

import UIKit
import CoreLocation

class OptimalStoresViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    var storearr:[String] = []
    var distancearr:[Double] = []
    var sorted_storearr:[String] = []
    var sorted_distancearr:[Double] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        locationManager.requestWhenInUseAuthorization()
        // Call the function to fetch store details
        getStoreDetails { result in
            switch result {
            case .success(let json):
                // Handle JSON response here
                if let stores = json as? [[String: Any]] {
                    for store in stores {
                        if let address = store["Address"] as? String {
                            // Calculate distance
                            self.calculateDistance(from: address)
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.sorted_distancearr = self.distancearr.sorted()
            for distance in self.sorted_distancearr{
                for primary in 0...(self.distancearr.count-1){
                    if(distance == self.distancearr[primary]){
                        self.sorted_storearr.append(self.storearr[primary])
                        break
                    }
                }
            }
            self.defaults.set(self.sorted_storearr, forKey: "stores")
            self.defaults.set(self.sorted_distancearr, forKey: "distances")
            self.tableView.reloadData()
        }
        
        // Do any additional setup after loading the view.
    }
    func calculateDistance(from destinationAddress: String) {
            guard let currentLocation = locationManager.location else {
                print("Unable to fetch current location")
                return
            }

            // Convert destination address to coordinates
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(destinationAddress) { placemarks, error in
                if let error = error {
                    print("Geocoding error: \(error)")
                    return
                }
            
                if let destinationLocation = placemarks?.first?.location {
                    // Calculate distance
                    let distance = currentLocation.distance(from: destinationLocation)
                    print("Distance from \(destinationAddress): \(distance) meters")
                    self.storearr.append(destinationAddress)
                    self.distancearr.append(distance)
                } else {
                    print("Unable to find coordinates for \(destinationAddress)")
                }
            }
        }
    func getStoreDetails(completion: @escaping (Result<Any, Error>) -> Void) {
        // API URL
        let urlString = "https://apimdev.wakefern.com/mockexample/V1/getStoreDetails"
        
        // Create URL object
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add headers
        request.setValue("4ae9400a1eda4f14b3e7227f24b74b44", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create URLSession object
        let session = URLSession.shared
        
        // Create data task
        let task = session.dataTask(with: request) { (data, response, error) in
            // Check for errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check if response contains data
            guard let responseData = data else {
                completion(.failure(NSError(domain: "Did not receive data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                // Parse JSON data
                let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
        }
        
        // Start the data task
        task.resume()
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
extension OptimalStoresViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
extension OptimalStoresViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaults.stringArray(forKey: "stores")?.count ?? 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "basicStyleCell")
        let list1 = defaults.stringArray(forKey:"stores") ?? ["Please Wait"]
        let list2 = (defaults.array(forKey:"distances") as? [Double]) ?? [0.0]
        cell.textLabel?.text = "\(indexPath.row+1): \(list1[indexPath.row]) | \(round(list2[indexPath.row]/1000)) km"
        return cell
    }
}
