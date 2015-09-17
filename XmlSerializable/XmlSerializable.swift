

import Foundation

//
//Xml Serialization protocol
//
protocol XmlCommon{
    
}

protocol XmlSavable:XmlCommon{
    func toXmlElem(rootName:String) -> AEXMLElement
}

protocol XmlRetrievable:XmlCommon{
    static func fromXmlElem(root:AEXMLElement) -> Self?
}

protocol XmlSerializable: XmlSavable, XmlRetrievable{
    
}

//
//Xml Serialization protocol extension
//
extension XmlCommon{
    static func getArrItemStr() -> String {
        return "arrItem"
    }
}

extension XmlSavable{
    func toXmlDoc(rootName:String? = nil) -> AEXMLDocument{
        let xml = AEXMLDocument()
        xml.addChild(toXmlElem(rootName ?? String(self.dynamicType)))
        return xml
    }
    
    func toXmlString(rootName:String? = nil, compact:Bool = false) -> String {
        var xml:AEXMLDocument
        let rootName_t = rootName ?? String(self.dynamicType)
        xml = toXmlDoc(rootName_t)
        
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
            return NSData()
        }
    }
    
    func toXmlFile(rootName:String? = nil, compact:Bool = false, xmlUrl:NSURL) -> Bool{
        return toXmlData(rootName, compact: compact).writeToURL(xmlUrl, atomically: true)
    }
}

extension XmlRetrievable{
    static func fromXmlDoc(xml:AEXMLDocument) -> Self?{
        let root = xml.root
        return fromXmlElem(root)
    }
    
    static func fromXmlData(xmlData:NSData) -> Self?{
        var error:NSError?
        guard let xmlDoc = AEXMLDocument(xmlData: xmlData, error: &error) else{

            return nil
        }
        return fromXmlDoc(xmlDoc)
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





//
//Extending AEXML functionalities
//
enum AEXMLError:ErrorType{
    case Common(String)
}
/*
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
*/

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
                xmlValue = String(format: "%f", doubleVal)
            }
        case let strVal as String:
            xmlValue = strVal
        case let boolVal as Bool:
            xmlValue = boolVal ? "true" : "false"
        case let dateVal as NSDate:
            /*let fmt = NSDateFormatter()
            fmt.dateFormat = "yyyyMMdd_HHmmss"
            xmlValue = fmt.stringFromDate(dateVal)*/
            xmlValue = "\(dateVal.timeIntervalSince1970)"
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


/*
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
*/
