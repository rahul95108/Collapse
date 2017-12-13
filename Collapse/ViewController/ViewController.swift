
import UIKit

struct Pincode {
    let description: String
    var pincode: String
}

class ViewController: UIViewController {
    
    var person: Pincode?
    
    // MARK: - UIView Life Cycle Methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        self.callGetApi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Webservice Delegate Methods -
    
    func callGetApi(){
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: NSURL(string: PINCODE_URL)! as URL)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let dict = json as! NSDictionary
                print(dict)
            }
        }
        task.resume()
    }
}

