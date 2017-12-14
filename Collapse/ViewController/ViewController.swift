
import UIKit

struct Pincode {
    let description: String
    var pincode: String
}

class ViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var person: Pincode?
    var count = NSInteger()
    var selectedCount = NSInteger()
    let picker = UIPickerView()
    
    var arrData = NSMutableArray()
    var dictData = NSMutableDictionary()
    
    let pickerData = ["One","Two","Three","Four"]
    
    @IBOutlet weak var txtItem: UITextField!
    @IBOutlet weak var tbView: UITableView!
    
    // MARK: - UIView Life Cycle Methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCount = 999
        txtItem.inputView = picker
        picker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableView Methods -
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70))
        headerView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        headerView.layer.borderColor = UIColor(white: 0.5, alpha: 1.0).cgColor
        headerView.layer.borderWidth = 1.0
        
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 5, y: 5, width: tableView.frame.size.width - 5, height: 18)
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        headerLabel.text = pickerData[section]
        headerLabel.textAlignment = .left
        headerView.addSubview(headerLabel)
        
        headerView.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(self.sectionHeaderWasTouched(_:)))
        headerView.addGestureRecognizer(headerTapGesture)
        
        return headerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let str = pickerData[section]
        let total = self.dictData.allKeys.count
        if total > 0 {
            if let _ = self.dictData[str] {
                return 28
            }
            else{
                return 0
            }
        }
        else{
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == selectedCount {
            return 82
        }
        else{
            return 0
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int{
        return pickerData.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let str = pickerData[section]
        let total = self.dictData.allKeys.count
        if total > 0 {
            if let _ = self.dictData[str] {
                let arr = self.dictData.value(forKey: str) as! NSArray
                return arr.count
            }
            else{
                return 0
            }
        }
        else{
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        let str = pickerData[indexPath.section]
        
        let arr = self.dictData.value(forKey: str) as! NSArray
        if arr.count > 0{
            let dict = arr.object(at: indexPath.row) as! NSDictionary
            let strTitle = String(format: "%@ %@", (dict.value(forKey: "first_name") as? String)!, (dict.value(forKey: "last_name") as? String)!)
            cell.lblTitle.text = strTitle
            
            let strURL = dict.value(forKey: "avatar") as? String
            let url = NSURL(string: strURL!)
            let request = URLRequest(url:url! as URL)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() {
                    cell.imgView.image = image
                }
                }.resume()
        }
        return cell
    }
    
    // MARK: - Section Header Touch Method -
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view
        let section    = headerView?.tag
        if section == selectedCount {
            selectedCount = 999
        }
        else{
            selectedCount = section!
        }
        self.tbView.reloadData()
    }
    
    // MARK: - Pickerview Delegate Methods -
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtItem.text = pickerData[row]
        count = row + 1
        self.view.endEditing(true)
        if let _ = self.dictData[self.txtItem.text!] {
            self.tbView.reloadData()
        }
        else{
            let url = String(format: "%@%x", URL, count)
            callGetApi(url: url)
        }
    }
    
   //  MARK: - Webservice Delegate Methods -

    func callGetApi(url:String){
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let request = URLRequest(url: NSURL(string: url)! as URL)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) -> Void in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let dict = json as! NSDictionary
                self.arrData = NSMutableArray()
                DispatchQueue.main.async { [unowned self] in
                    let arr = dict.value(forKey: "data") as! NSArray
                    for i in 0..<arr.count{
                        let dictData = arr.object(at: i)
                        self.arrData.add(dictData)
                    }
                    self.dictData.setValue(self.arrData, forKey: self.txtItem.text!)
                    self.tbView.reloadData()
                }
            }
        }
        task.resume()
    }
}
