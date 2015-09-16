

import Foundation


//
//Xml Serialization protocol
//
protocol XmlCommon{
    static var defaultRootName:String {get}
}

extension XmlCommon{
    static func getArrItemStr() -> String {
        return "arrItem"
    }
}


protocol XmlSavable:XmlCommon{
    func toXml(rootName:String) -> AEXMLDocument
}
extension XmlSavable{
    func toXml() -> AEXMLDocument{
        return toXml(Self.defaultRootName)
    }
    
    func toXmlString(rootName:String? = nil, compact:Bool = false) -> String {
        var xml:AEXMLDocument
        let rootName_t = rootName ?? Self.defaultRootName
        xml = toXml(rootName_t)
        
        if compact == true {
            return xml.xmlStringCompact
        }
        else{
            return xml.xmlString
        }
    }
    
    func toXmlData(rootName:String? = nil, compact:Bool = false) -> NSData {
        if let data = toXmlString(rootName, compact: compact).dataUsingEncoding(NSUTF8StringEncoding){
            return data
        }
        else{
            Log.severe("Cannot convert String to NSData")
            return NSData()
        }
    }
    
    func toXmlFile(rootName:String? = nil, compact:Bool = false, xmlUrl:NSURL) -> Bool{
        return toXmlData(rootName, compact: compact).writeToURL(xmlUrl, atomically: true)
    }
}

protocol XmlRetrievable:XmlCommon{
    static func fromXml(xml:AEXMLDocument) -> Self?
}
extension XmlRetrievable{
    static func fromXmlRoot(xmlRootElem:AEXMLElement) -> Self?{
        let xmlDoc = AEXMLDocument()
        xmlDoc.addChild(xmlRootElem)
        return fromXml(xmlDoc)
    }
    
    static func fromXmlData(xmlData:NSData) -> Self?{
        var error:NSError?
        guard let xmlDoc = AEXMLDocument(xmlData: xmlData, error: &error) else{
            Log.error("Fail to parse XML data")
            return nil
        }
        return fromXml(xmlDoc)
    }
    
    static func fromXmlString(xmlStr:String) -> Self?{
        if let data = xmlStr.dataUsingEncoding(NSUTF8StringEncoding){
            return fromXmlData(data)
        }
        else {
            return nil
        }
    }
    
    static func fromXmlFile(xmlUrl:NSURL) -> Self?{
        if let data = NSData(contentsOfURL: xmlUrl) {
            return fromXmlData(data)
        }
        else{
            return nil
        }
    }
}

protocol XmlSerializable: XmlSavable, XmlRetrievable{
    
}



//
//Extending AEXML functionalities
//
enum AEXMLError:ErrorType{
    case Common(String)
}
extension AEXMLError{
    func log(logAsWarn:Bool = false) -> AEXMLError{
        var str = "throw AEXMLError: "
        switch self{
        case .Common(let msg):
            str += "Common(\(msg))"
        }
        if logAsWarn {
            Log.warning(str)
        }
        else{
            Log.error(str)
        }
        return self
    }
}

extension AEXMLElement{
    public var available:Bool {
        return (self.name != AEXMLElement.errorElementName)
    }
    
    public var element:AEXMLElement?{
        return available ? self : nil
    }
    
    /*
    public var valueIsNil: Bool {
    let isNilAttr = self.attributes["isNil"]
    if let attr = (isNilAttr as? String) {
    if attr == "1" {
    return true
    }
    }
    
    return false
    }
    
    public var stringOptValue: String? { return valueIsNil ? nil : (value ?? String()) }
    public var boolOptValue: Bool? { return valueIsNil ? nil : (stringValue.lowercaseString == "true" || Int(stringValue) == 1 ? true : false) }
    public var intOptValue: Int? { return valueIsNil ? nil : (Int(stringValue) ?? 0) }
    public var doubleOptValue: Double? { return valueIsNil ? nil : ((stringValue as NSString).doubleValue) }
    */
    
    //
    //getter functions will throw error if cannot get value or value type is not correct
    //
    public func getStringVal() throws -> String {
        guard self.available else { throw AEXMLError.Common("").log(true) }
        guard let ret = self.value else { throw AEXMLError.Common("").log(true) }
        return ret
    }
    public func getBoolVal() throws -> Bool {
        let strVal = try getStringVal()
        if (strVal.lowercaseString == "true" || Int(strVal) == 1) {return true}
        if (strVal.lowercaseString == "false" || Int(strVal) == 0) {return true}
        throw AEXMLError.Common("").log(true)
    }
    public func getIntVal() throws -> Int {
        let strVal = try getStringVal()
        guard let temp = Int(strVal) else {throw AEXMLError.Common("").log(true)}
        return temp
    }
    public func getDoubleVal() throws -> Double {
        let strVal = try getStringVal()
        guard let temp = Double(strVal) else {throw AEXMLError.Common("").log(true)}
        return temp
    }
    public func getDateVal() throws -> NSDate {
        let strVal = try getStringVal()
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyyMMdd_HHmmss"
        guard let temp = fmt.dateFromString(strVal) else {throw AEXMLError.Common("").log(true)}
        return temp
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
        
        throw AEXMLError.Common("").log(true)
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
                xmlValue = String(format: "%f", doubleVal)
            }
        case let strVal as String:
            xmlValue = strVal
        case let boolVal as Bool:
            xmlValue = boolVal ? "true" : "false"
        case let dateVal as NSDate:
            let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyyMMdd_HHmmss"
            xmlValue = fmt.stringFromDate(dateVal)
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


class Log{
    static func warning(msg:String){
        print("Warning: " + msg)
    }
    static func error(msg:String){
        print("Error: " + msg)
    }
    static func severe(msg:String){
        print("Severe Error: " + msg)
    }
}
