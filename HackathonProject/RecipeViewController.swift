import UIKit

class RecipeViewController: UIViewController {

    @IBOutlet weak var recipeInsert: UITextField!
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var TextScroll: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Call function to fetch recipe
    }
    
    @IBAction func SubmitPressed(_ sender: Any) {
        let food = recipeInsert.text!
        fetchRecipe(for: food) { ingredientLines in
            // Handle the fetched data (ingredientLines) here
            let result = ingredientLines
            DispatchQueue.main.async {
                // Clear the existing text in the text view
                self.TextScroll.text = ""
                // Append each element of ingredientLines to the text view
                for ingredient in result {
                    self.TextScroll.text += "\(ingredient)\n"
                }
            }
        }
    }
    func fetchRecipe(for foodItem: String, completion: @escaping ([String]) -> Void) {
        // Construct the API endpoint URL
        let appID = "e606053e"
        let appKey = "80a36c51e92f2e0859609a45bedbd21f"
        let baseURL = "https://api.edamam.com/search"
        let queryString = "?q=\(foodItem)&app_id=\(appID)&app_key=\(appKey)"
        let urlString = baseURL + queryString
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Create a URL session
        let session = URLSession.shared
        
        // Create a data task for the URL session
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP response status code: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Parse the JSON data
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                if let hits = json?["hits"] as? [[String: Any]], let firstHit = hits.first {
                    if let recipe = firstHit["recipe"] as? [String: Any], let ingredientLines = recipe["ingredientLines"] as? [String] {
                        // Call completion handler with fetched data
                        completion(ingredientLines)
                    } else {
                        print("No recipe found in JSON response")
                    }
                } else {
                    print("No hits found in JSON response")
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Start the data task
        task.resume()
    }

}
