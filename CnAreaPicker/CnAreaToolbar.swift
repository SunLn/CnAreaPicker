import UIKit

protocol CnAreaToolbarDelegate: class {
    func sure(areaToolbar: CnAreaToolbar, textField: UITextField, locate: CnLocation, item: UIBarButtonItem)
    func cancel(areaToolbar: CnAreaToolbar, textField: UITextField, locate: CnLocation, item: UIBarButtonItem)
}


class CnAreaToolbar: UIToolbar {
    
    weak var barDelegate: CnAreaToolbarDelegate?
    var textField: UITextField!
    
    static func bar<T: UIViewController>(for controller: T, textField: UITextField, barTintColor: UIColor, tintColor: UIColor) -> CnAreaToolbar where T: CnAreaToolbarDelegate {
        let toolBar = CnAreaToolbar()
        toolBar.textField = textField
        toolBar.barDelegate = controller
        let cancelItem = UIBarButtonItem(title: "取消", style: .plain, target: toolBar, action: #selector(areaPickerCancel(_:)))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let sureItem = UIBarButtonItem(title: "确定", style: .plain, target: toolBar, action: #selector(areaPickerSure(_:)))
        toolBar.items = [cancelItem, flexibleItem, sureItem]
        cancelItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName: tintColor,
            NSBackgroundColorAttributeName: barTintColor
            ], for: .normal)
        sureItem.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName: tintColor,
            NSBackgroundColorAttributeName: barTintColor
            ], for: .normal)
        
        toolBar.barTintColor = barTintColor
        toolBar.tintColor = tintColor
        return toolBar
    }
    
    private init(){
        super.init(frame: CGRect(x: 0, y: 0, width: APMAIN_WIDTH, height: 44))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func areaPickerCancel(_ item: UIBarButtonItem) {
        textField.resignFirstResponder()
        barDelegate?.cancel(areaToolbar: self, textField: textField, locate: locate, item: item)
    }
    
    @objc func areaPickerSure(_ item: UIBarButtonItem) {
                textField.resignFirstResponder()
        barDelegate?.sure(areaToolbar: self, textField: textField, locate: locate, item: item)
    }
    
    // MARK: - lazy
    lazy var locate: CnLocation = {
       return CnLocation()
    }()


}
