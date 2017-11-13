import Foundation

public class CnLocation {
    
    var country = ""
    var province = ""
    var city = ""
    var area = ""
    var street = ""
//    var latitude: Double? //没数据
//    var longitude: Double? //没数据
    
    var provinceCode = ""
    var cityCode = ""
    var areaCode = ""
    
    func decription() {
        print("\(province): \(provinceCode) \(city): \(cityCode) \(area): \(areaCode)")
    }
    
}
