# SwiftXmlSerializable
XML Serialization help lib for iOS written in Swift, which is based upon AEXML.

##How to use:
Your data type need to conform XmlSerializable protocol, or conform XmlSavable/XmlRetrievable protocol if need only save/retrieve xml.
```swift
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
```

##Sample code
```swift
struct InternalStruct: XmlSerializable{
    var a:Int = 10
    var b:String = "b"
    var c:Bool   =  true
    var d:Double  = 20.20
    var e:NSDate  = NSDate()
    
    var optA:Int? = nil
    var optB:String? = "optB"
}
//
//conforming XmlSerializable
extension InternalStruct{
    func toXmlElem(rootName:String) -> AEXMLElement {
        let root = AEXMLElement(rootName)
        
        root.addValueChild(name: "a", value: a)
        root.addValueChild(name: "b", value: b)
        root.addValueChild(name: "c", value: c)
        root.addValueChild(name: "d", value: d)
        root.addValueChild(name: "e", value: e)
        root.addOptValueChild(name: "optA", value: optA)
        root.addOptValueChild(name: "optB", value: optB)
        
        return root
    }
    
    static func fromXmlElem(root:AEXMLElement) -> InternalStruct? {
        var ret = InternalStruct()
        
        do{
            ret.a = try root["a"].getIntVal()
            ret.b = try root["b"].getStringVal()
            ret.c = try root["c"].getBoolVal()
            ret.d = try root["d"].getDoubleVal()
            ret.e = try root["e"].getDateVal()
            ret.optA = try root["optA"].getIntOptVal()
            ret.optB = try root["optB"].getStringOptVal()
        }
        catch{
            return nil
        }
        
        return ret
    }
}


struct MyStruct: XmlSerializable{
    var internalStruct:InternalStruct = InternalStruct()
    var arr:[String] = [String]()
}
//
//conforming XmlSerializable
extension MyStruct{
    func toXmlElem(rootName:String) -> AEXMLElement {
        let root = AEXMLElement(rootName)
        
        root.addChild(internalStruct.toXmlElem("internalStruct"))
        
        let arrElem = root.addChild(name: "arr")
        for item in arr{
            arrElem.addValueChild(name: MyStruct.getArrItemStr(), value: item)
        }
        
        return root
    }
    
    static func fromXmlElem(root:AEXMLElement) -> MyStruct? {
        var ret = MyStruct()
        
        do{
            guard let internalStruct = InternalStruct.fromXmlElem(root["internalStruct"]) else {return nil}
            ret.internalStruct = internalStruct
            
            guard let arr = root["arr"][MyStruct.getArrItemStr()].all else {return nil}
            for item in arr{
                ret.arr.append(try item.getStringVal())
            }
        }
        catch{
            return nil
        }
        
        return ret
    }
}

func compare(lVal:MyStruct, rVal:MyStruct) -> Bool{
    if lVal.internalStruct.a != rVal.internalStruct.a {return false}
    if lVal.internalStruct.b != rVal.internalStruct.b {return false}
    if lVal.internalStruct.c != rVal.internalStruct.c {return false}
    if lVal.internalStruct.d != rVal.internalStruct.d {return false}
    if (lVal.internalStruct.e.timeIntervalSince1970 - rVal.internalStruct.e.timeIntervalSince1970) > 0.01 {return false}
    if lVal.internalStruct.optA != rVal.internalStruct.optA {return false}
    if lVal.internalStruct.optB != rVal.internalStruct.optB {return false}
    
    for var i = 0; i < lVal.arr.count; i++ {
        if lVal.arr[i] != rVal.arr[i] {return false}
    }
    
    return true
}

func testXmlSerializable(){
    var val1 = InternalStruct()
    val1.a = 100
    val1.b = "bbb"
    val1.c = false
    val1.d = 200.232
    val1.e = NSDate()
    val1.optA = nil
    val1.optB = "optB"
    
    var val2 = MyStruct()
    val2.internalStruct = val1
    val2.arr = ["aaa", "bbb", "ccc"]
    
    let xmlStr = val2.toXmlString()
    print(xmlStr)
    
    let xmlFileUrl = getDocDirURL().URLByAppendingPathComponent("MyStruct.xml")
    val2.toXmlFile(xmlUrl: xmlFileUrl)
    
    if let val2New = MyStruct.fromXmlFile(xmlFileUrl){
        let ret = compare(val2, rVal: val2New)
        let retStr = ret ? "same" : "different"
        print("Compare original struct and retrieved struct. They are \(retStr)")
    }
    else{
        print("Cannot load Xml file from \(xmlFileUrl)")
    }
}
```
