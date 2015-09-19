

import Foundation

//
//Xml Serialization protocol
//
protocol XmlCommon{
}

protocol XmlSavable:XmlCommon{
    func toXmlElem(rootName:String) throws -> AEXMLElement
}

protocol XmlRetrievable:XmlCommon{
    init()
    //static func fromXmlElem(root:AEXMLElement) -> Self?
    static func fromXmlElem(root:AEXMLElement)throws -> Self
    mutating func setVarForName(name:String, value:Any) throws
}

protocol XmlSerializable: XmlSavable, XmlRetrievable{
    
}




//
//
//
extension Int:XmlRetrievable{
    func toXmlElem(rootName:String) -> AEXMLElement{
        return AEXMLElement(rootName, value: String(self))
    }
    static func fromXmlElem(root:AEXMLElement)throws -> Int{
        return try root.getIntVal()
    }
    mutating func setVarForName(name:String, value:Any) throws{
        guard let val = (value as? Int) else{
            throw AEXMLError.Common("")
        }
        self = val
    }
}
extension String:XmlRetrievable{
    func toXmlElem(rootName:String) -> AEXMLElement{
        return AEXMLElement(rootName, value: (self))
    }
    static func fromXmlElem(root:AEXMLElement)throws -> String{
        return try root.getStringVal()
    }
    mutating func setVarForName(name:String, value:Any) throws{
        guard let val = (value as? Int) else{
            throw AEXMLError.Common("")
        }
        self = val
    }
}
extension Bool:XmlRetrievable{
    func toXmlElem(rootName:String) -> AEXMLElement{
        return AEXMLElement(rootName, value: String(self))
    }
    static func fromXmlElem(root:AEXMLElement)throws -> Bool{
        return try root.getBoolVal()
    }
    mutating func setVarForName(name:String, value:Any) throws{
        guard let val = (value as? Int) else{
            throw AEXMLError.Common("")
        }
        self = val
    }
}
extension Double:XmlRetrievable{
    func toXmlElem(rootName:String) -> AEXMLElement{
        return AEXMLElement(rootName, value: String(self))
    }
    static func fromXmlElem(root:AEXMLElement)throws -> Double{
        return try root.getDoubleVal()
    }
    mutating func setVarForName(name:String, value:Any) throws{
        guard let val = (value as? Int) else{
            throw AEXMLError.Common("")
        }
        self = val
    }
}

extension NSDate:XmlRetrievable{
    func toXmlElem(rootName:String) -> AEXMLElement{
        return AEXMLElement(rootName, value: String(self.timeIntervalSince1970))
    }
    static func fromXmlElem(root:AEXMLElement)throws -> NSDate{
        return try root.getDateVal()
    }
    mutating func setVarForName(name:String, value:Any) throws{
        guard let val = (value as? Int) else{
            throw AEXMLError.Common("")
        }
        self = val
    }
}
extension Optional:XmlSavable{
    func toXmlElem(rootName:String)throws -> AEXMLElement{
        var attributes: [NSObject : AnyObject] = [NSObject : AnyObject]()
        var ret:AEXMLElement
        switch self{
        case .None:
            attributes["isNil"] =  "0"
            ret = AEXMLElement(rootName, value: "")
        case .Some(let value):
            attributes["isNil"] =  "1"
            ret = try Optional.objToXmlElem(value, rootName: rootName)
        }
        return ret
    }
}


extension Array:XmlSavable{
    func toXmlElem(rootName:String)throws -> AEXMLElement{
        let ret = AEXMLElement(rootName)
        for item in self{
            ret.addChild(try Array.objToXmlElem(item, rootName: Array.getArrItemStr()))
        }
        return ret
    }
}

extension Dictionary:XmlSavable{
    func toXmlElem(rootName: String) throws -> AEXMLElement {
        let ret = AEXMLElement(rootName)
        for (key, value) in self{
            guard let keyStr = key as? String else{
                throw AEXMLError.Common("")
            }
            ret.addChild(try Dictionary.objToXmlElem(value, rootName: keyStr))
        }
        return ret
    }
}

extension Set:XmlSavable{
    func toXmlElem(rootName:String)throws -> AEXMLElement{
        let ret = AEXMLElement(rootName)
        for item in self{
            ret.addChild(try Set.objToXmlElem(item, rootName: Set.getSetItemStr()))
        }
        return ret
    }
}



//
//Xml Serialization protocol extension
//
extension XmlCommon{
    static func getArrItemStr() -> String {
        return "arrItem"
    }
    static func getSetItemStr() -> String {
        return "setItem"
    }
}

extension XmlSavable{
    static func objToXmlElem(obj:Any, rootName:String) throws -> AEXMLElement{
        switch obj {
        case let temp as XmlSavable:
            return try temp.toXmlElem(rootName)
        default:
            throw AEXMLError.Common("")
        }
    }
    
    func toXmlElem(rootName:String)throws -> AEXMLElement{
        let root = AEXMLElement(rootName)
        let children = Mirror(reflecting: self).children
        for i in (children.startIndex)..<(children.endIndex) {
            let child = children[i]
            let value = child.value
            guard let label = child.label else{
                throw AEXMLError.Common("")
            }
            
            root.addChild(try Self.objToXmlElem(value, rootName: label))
        }
        return root
    }
    
    func toXmlDoc(rootName:String? = nil)throws -> AEXMLDocument{
        let xml = AEXMLDocument()
        xml.addChild(try toXmlElem(rootName ?? String(self.dynamicType)))
        return xml
    }
    
    func toXmlString(rootName:String? = nil, compact:Bool = false)throws -> String {
        var xml:AEXMLDocument
        let rootName_t = rootName ?? String(self.dynamicType)
        xml = try toXmlDoc(rootName_t)
        
        if compact == true {
            return xml.xmlStringCompact
        }
        else{
            return xml.xmlString
        }
    }
    
    func toXmlData(rootName:String? = nil, compact:Bool = false)throws -> NSData {
        if let data = try toXmlString(rootName, compact: compact).dataUsingEncoding(NSUTF8StringEncoding){
            return data
        }
        else{
            throw AEXMLError.Common("")
        }
    }
    
    func toXmlFile(rootName:String? = nil, compact:Bool = false, xmlUrl:NSURL)throws -> Bool{
        return try toXmlData(rootName, compact: compact).writeToURL(xmlUrl, atomically: true)
    }
}

extension XmlRetrievable{
    static func fromXmlElem(root:AEXMLElement)throws -> Self{
        let ret = Self()
        
        let children = Mirror(reflecting: ret).children
        for i in (children.startIndex)..<(children.endIndex) {
            let child = children[i]
            let value = child.value
            guard let label = child.label else{
                throw AEXMLError.Common("")
            }
            
            guard let elem = root[label].element else{
                throw AEXMLError.Common("")
            }
            
            switch value{
            case let temp as XmlRetrievable:
                try ret.setVarForName(label, value: try temp.dynamicType.fromXmlElem(elem))
            default:
                throw AEXMLError.Common("")
            }
        }
        
        return ret
    }
    
    static func fromXmlDoc(xml:AEXMLDocument)throws -> Self{
        let root = xml.root
        return try fromXmlElem(root)
    }
    
    static func fromXmlData(xmlData:NSData)throws -> Self{
        var error:NSError?
        guard let xmlDoc = AEXMLDocument(xmlData: xmlData, error: &error) else{
            throw AEXMLError.Common("")
        }
        return try fromXmlDoc(xmlDoc)
    }
    
    static func fromXmlString(xmlStr:String)throws -> Self{
        if let data = xmlStr.dataUsingEncoding(NSUTF8StringEncoding){
            return try fromXmlData(data)
        }
        else {
            throw AEXMLError.Common("")
        }
    }
    
    static func fromXmlFile(xmlUrl:NSURL)throws -> Self{
        if let data = NSData(contentsOfURL: xmlUrl) {
            return try fromXmlData(data)
        }
        else{
            throw AEXMLError.Common("")
        }
    }
}





//
//Extending AEXML functionalities
//
enum AEXMLError:ErrorType{
    case Common(String)
}


extension AEXMLElement{
    public var available:Bool {
        return (self.name != AEXMLElement.errorElementName)
    }
    
    public var element:AEXMLElement?{
        return available ? self : nil
    }
    
    //
    //getter functions will throw error if cannot get value or value type is not correct
    //
    public func getStringVal() throws -> String {
        guard self.available else { throw AEXMLError.Common("") }
        guard let ret = self.value else { throw AEXMLError.Common("") }
        return ret
    }
    public func getBoolVal() throws -> Bool {
        let strVal = try getStringVal()
        if (strVal.lowercaseString == "true" || Int(strVal) == 1) {return true}
        if (strVal.lowercaseString == "false" || Int(strVal) == 0) {return false}
        throw AEXMLError.Common("")
    }
    public func getIntVal() throws -> Int {
        let strVal = try getStringVal()
        guard let temp = Int(strVal) else {throw AEXMLError.Common("")}
        return temp
    }
    public func getDoubleVal() throws -> Double {
        let strVal = try getStringVal()
        guard let temp = Double(strVal) else {throw AEXMLError.Common("")}
        return temp
    }
    public func getDateVal() throws -> NSDate {
        /*let strVal = try getStringVal()
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyyMMdd_HHmmss"
        guard let temp = fmt.dateFromString(strVal) else {throw AEXMLError.Common("").log(true)}
        return temp
        */
        return NSDate(timeIntervalSince1970: (try getDoubleVal()))
    }
    
    
    private func optIsNil() throws -> Bool {
        let isNilAttr = self.attributes["isNil"]
        if let attr = (isNilAttr as? String) {
            if attr == "1" {
                return true
            }
            else if attr == "0"{
                return false
            }
        }
        
        throw AEXMLError.Common("")
    }
    public func getStringOptVal() throws -> String? {
        return (try optIsNil()) ? nil : (try self.getStringVal())
    }
    public func getBoolOptVal() throws -> Bool? {
        return (try optIsNil()) ? nil : (try self.getBoolVal())
    }
    public func getIntOptVal() throws -> Int? {
        return (try optIsNil()) ? nil : (try self.getIntVal())
    }
    public func getDoubleOptVal() throws -> Double? {
        return (try optIsNil()) ? nil : (try self.getDoubleVal())
    }
    public func getDateOptVal() throws -> NSDate? {
        return (try optIsNil()) ? nil : (try self.getDateVal())
    }
    
    
    //
    // Help funciton to easily add xml value element
    //
    public func addValueChild(name name: String, value: Any, attributes: [NSObject : AnyObject] = [NSObject : AnyObject](), doublePrecision:Int? = nil) -> AEXMLElement {
        var xmlValue:String = ""
        switch value {
        case let intVal as Int:
            xmlValue = String(intVal)
        case let doubleVal as Double:
            if let precision = doublePrecision {
                xmlValue = String(format: "%.\(precision)f", doubleVal)
            }
            else{
                xmlValue = String(doubleVal)
            }
        case let strVal as String:
            xmlValue = strVal
        case let boolVal as Bool:
            xmlValue = boolVal ? "true" : "false"
        case let dateVal as NSDate:
            /*let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyyMMdd_HHmmss"
            xmlValue = fmt.stringFromDate(dateVal)*/
            xmlValue = String(dateVal.timeIntervalSince1970)
        default:
            return AEXMLElement(AEXMLElement.errorElementName, value: "Value type must be Int, Double, String, Bool or NSDate.")
        }
        let child = AEXMLElement(name, value: xmlValue, attributes: attributes)
        return addChild(child)
    }
    
    public func addOptValueChild(name name: String, value: Any?, var attributes: [NSObject : AnyObject] = [NSObject : AnyObject](), doublePrecision:Int? = nil) -> AEXMLElement {
        if let val = value {
            attributes["isNil"] =  "0"
            return addValueChild(name: name, value: val, attributes: attributes, doublePrecision: doublePrecision)
        }
        else{
            attributes["isNil"] =  "1"
            return addValueChild(name: name, value: "", attributes: attributes, doublePrecision: doublePrecision)
        }
    }
}


