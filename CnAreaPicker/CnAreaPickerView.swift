import UIKit

let stateKey = "state"
let citiesKey = "cities"
let cityKey = "city"
let areasKey = "areas"

let APDefaultBarTintColor = UIColor(red: 200/255, green: 22/255, blue: 35/255, alpha: 1.0)
let APDefaultTintColor = UIColor.white
///屏幕宽度
let APMAIN_WIDTH: CGFloat = {
    UIScreen.main.bounds.size.width
}()

enum PickerType: Int {
    case province
    case city
    case area
}

protocol CnAreaPickerViewDelegate: class {
    func statusChanged(areaPickerView: CnAreaPickerView, pickerView: UIPickerView, textField: UITextField, locate: CnLocation)
}

protocol CnAreaPickerDelegate: CnAreaPickerViewDelegate, CnAreaToolbarDelegate {}

public class CnAreaPickerView: UIView {
    
    var cities = [[String: AnyObject]]()
    var areas = [String]()
    var textField: UITextField!
    var pickerView:UIPickerView!
    var toolbar: CnAreaToolbar!
    var areaLevel: Int = 3
    weak var delegate: CnAreaPickerViewDelegate?
    
    static func picker<controller: UIViewController>(for controller: controller, textField: UITextField, barTintColor: UIColor = APDefaultBarTintColor, tintColor: UIColor = APDefaultTintColor, areaLevel: Int = 3) -> CnAreaPickerView where controller: CnAreaPickerDelegate {
        
        let areaPickerView = CnAreaPickerView()
        areaPickerView.delegate = controller
        areaPickerView.textField = textField
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = UIColor.white
        areaPickerView.pickerView = pickerView
        areaPickerView.areaLevel = areaLevel
        if areaLevel <= 0 || areaPickerView.areaLevel > 3 {
            areaPickerView.areaLevel = 3
        }
        pickerView.delegate = areaPickerView
        pickerView.dataSource = areaPickerView
        
        if let province = areaPickerView.provinces[0][stateKey] as? String {
            areaPickerView.locate.province = province
        }
        if areaPickerView.areaLevel >= 2 {
            areaPickerView.cities = areaPickerView.provinces[0][citiesKey] as! [[String : AnyObject]]!
            if let city = areaPickerView.cities[0][cityKey] as? String {
                areaPickerView.locate.city = city
            }
            if areaPickerView.areaLevel == 3 {
                areaPickerView.areas = areaPickerView.cities[0][areasKey] as! [String]!
                if areaPickerView.areas.count > 0 {
                    areaPickerView.locate.area = areaPickerView.areas[0]
                } else {
                    areaPickerView.locate.area = ""
                }
            }
        }
        textField.inputView = pickerView
        areaPickerView.toolbar = CnAreaToolbar.bar(for: controller, textField: textField, barTintColor: barTintColor, tintColor: tintColor)
        textField.inputAccessoryView = areaPickerView.toolbar
        
        return areaPickerView
    }
    
    private init(){
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shouldSelected(proName: String, cityName: String, areaName: String?) {
        
        if self.areaLevel >= 1 {
            for index in 0..<provinces.count {
                let pro = provinces[index]
                if pro[stateKey] as! String == proName {
                    if let province = provinces[index][stateKey] as? String {
                        locate.province = province
                    }
                    cities = provinces[index][citiesKey] as! [[String : AnyObject]]!
                    pickerView.selectRow(index, inComponent: PickerType.province.rawValue, animated: false)
                    break
                }
            }
        } else {
            locate.city = ""
            locate.area = ""
        }
        
        if self.areaLevel >= 2 {
            for index in 0..<cities.count {
                let city = cities[index]
                //            print("城市的名称是\(city[cityKey])")
                if city[cityKey] as! String == cityName {
                    if let city = cities[index][cityKey] as? String {
                        locate.city = city
                    }
                    areas = cities[index][areasKey] as! [String]!
                    pickerView.selectRow(index, inComponent: PickerType.city.rawValue, animated: false)
                    break
                }
            }
        } else {
            locate.area = ""
        }
        
        if self.areaLevel >= 3  {
            if areaName != nil {
                for (index, name) in self.areas.enumerated() {
                    //                print("区域的名称是\(name)")
                    if name == areaName! {
                        self.locate.area = self.areas[index]
                        self.pickerView.selectRow(index, inComponent: PickerType.area.rawValue, animated: false)
                        break
                    }
                }
            }
        }
    }
    
    func setCode(provinceName: String, cityName: String, areaName: String?){
        
        let url = Bundle.main.url(forResource: "addressCode", withExtension: nil)
        let data = try! Data(contentsOf: url!)
        let dict = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
        let provinces = dict["p"] as! [[String: AnyObject]]
        
        for pro in provinces {
            if pro["n"] as! String == provinceName {
                if let proCode = pro["v"] as? String {
                    locate.provinceCode = proCode //找到省编号
                }
                
                var foundCity = false
                for city in pro["c"] as! [[String: AnyObject]] {
                    if city["n"] as! String == cityName {
                        if let cityCode = city["v"] as? String {
                            locate.cityCode = cityCode  //找到城市编码
                        }
                        for area in city["d"] as! [[String: String]] {
                            if area["n"] == areaName {
                                locate.areaCode = area["v"]!
                            }
                        }
                        foundCity = true
                    }
                }
                
                //如果第二层没有找到相应的城市.那就是直辖市了,要重新找
                if !foundCity {
                    for city in pro["c"] as! [[String: AnyObject]] {
                        let areas = city["d"] as! [[String: String]] //直接查找三级区域
                        for area in areas {
                            if area["n"] == cityName {
                                locate.areaCode = area["v"]!
                                if let cityCode = city["v"] as? String {
                                    locate.cityCode = cityCode
                                }
                                break
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: - lazy
    lazy var provinces: [[String: AnyObject]] = {
        let path = Bundle.main.path(forResource: "area", ofType: "plist")
        return NSArray(contentsOfFile: path!) as! [[String: AnyObject]]
    }()
    
    lazy var locate: CnLocation = {
        return CnLocation()
    }()
    
}

extension CnAreaPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return areaLevel
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let pickerType = PickerType(rawValue: component)!
        switch pickerType {
        case .province:
            return provinces.count
        case .city:
            return cities.count
        case .area:
            return areas.count
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let pickerType = PickerType(rawValue: component)!
        switch pickerType {
        case .province:
            return provinces[row][stateKey] as! String?
        case .city:
            return cities[row][cityKey] as! String?
        case .area:
            if areas.count > 0 {
                return areas[row]
            } else {
                return ""
            }
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        print("选中了某一行")
        let pickerType = PickerType(rawValue: component)!
        switch pickerType {
        case .province:
            if let province = provinces[row][stateKey] as? String {
                locate.province = province
            }
            if self.areaLevel > 1 {
                cities = provinces[row][citiesKey] as! [[String : AnyObject]]!
                pickerView.reloadComponent(PickerType.city.rawValue)
                pickerView.selectRow(0, inComponent: PickerType.city.rawValue, animated: true)
                reloadAreaComponent(pickerView: pickerView, row: 0)
            }
        case .city:
            reloadAreaComponent(pickerView: pickerView, row: row)
        case .area:
            if areas.count > 0 {
                locate.area = areas[row]
            } else {
                locate.area = ""
            }
        }
        setCode(provinceName: locate.province, cityName: locate.city, areaName: locate.area)
        toolbar.locate = locate
        delegate?.statusChanged(areaPickerView: self, pickerView: pickerView, textField: textField, locate: locate)
    }
    
    func reloadAreaComponent(pickerView: UIPickerView, row: Int) {
        guard row <= cities.count - 1 else {
            return
        }
        if self.areaLevel > 1 {
            if let city = cities[row][cityKey] as? String {
                locate.city = city
            }
        }
        if self.areaLevel > 2 {
            areas = cities[row][areasKey] as! [String]!
            pickerView.reloadComponent(PickerType.area.rawValue)
            pickerView.selectRow(0, inComponent: PickerType.area.rawValue, animated: true)
            if areas.count > 0 {
                locate.area = areas[0]
            } else {
                locate.area = ""
            }
        }
    }
}
