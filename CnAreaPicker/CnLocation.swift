import Foundation

public class CnLocation {
    
    public var country = ""
    public var province = ""
    public var city = ""
    public var area = ""
    public var street = ""
//    var latitude: Double? //没数据
//    var longitude: Double? //没数据
    
    public var provinceCode = ""
    public var cityCode = ""
    public var areaCode = ""
    
    public func decription() {
        print("\(province): \(provinceCode) \(city): \(cityCode) \(area): \(areaCode)")
    }
    
    public init() {}
}
