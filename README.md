# SwiftXmlSerializable
XML Serialization support library for iOS written in Swift language, which can help easily save/retrieve your own struct or class to/from XML. It is based on AEXML.  

Requires XCode version >= 7.0
##How to use?
###Save your struct/class to XML
Just add **XmlSavable** protocol to your own struct/class, everything else will be done for you!
```swift
struct InternalStruct: XmlSavable{
    var a:Int = 10
    var b:String = "b"
    var c:Bool   =  true
    var d:Double  = 20.20
    var e:NSDate  = NSDate()

    var optA:Int? = nil
    var optB:String? = "optB"
}
class MyClass: XmlSavable{
    var internalStruct:InternalStruct
    var arr:[String]
    var dict:[String: Int]

    required init(){
        internalStruct = InternalStruct()
        arr = [String]()
        dict = [:]
    }
}
var val1 = InternalStruct()
let val2 = MyClass()
val2.internalStruct = val1
val2.arr = ["aaa", "bbb", "ccc"]
val2.dict = ["a":1, "b":10, "c":100]
let xmlStr = try? val2.toXmlString()
print(xmlStr!)
```
Then the xmlStr will print out as:
````xml
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<MyClass>
    <internalStruct>
        <a>10</a>
        <b>b</b>
        <c>true</c>
        <d>20.2</d>
        <e>1442872934.39312</e>
        <optA isNil="1"></optA>
        <optB isNil="0">optB</optB>
    </internalStruct>
    <arr>
        <arrItem>aaa</arrItem>
        <arrItem>bbb</arrItem>
        <arrItem>ccc</arrItem>
    </arr>
    <dict>
        <b>10</b>
        <a>1</a>
        <c>100</c>
    </dict>
</MyClass>
````
You can also call toXmlData() to get XML as NSData, or call toXmlFile() to save XML as File
###Retrieve your struct/class from XML
Add **XmlRetrievable** protocol to your own struct/class, then conform **XmlRetrievable** by implementing following 2 functions:
* init()
* static func fromXmlElem(root:AEXMLElement)throws -> Self
```swift
//
//conforming XmlSerializable
extension InternalStruct{
    static func fromXmlElem(root:AEXMLElement)throws -> InternalStruct {
        var ret = InternalStruct()
        do{
            ret.a = try Int.fromXmlElem(root["a"])
            ret.b = try String.fromXmlElem(root["b"])
            ret.c = try Bool.fromXmlElem(root["c"])
            ret.d = try Double.fromXmlElem(root["d"])
            ret.e = try NSDate.fromXmlElem(root["e"])
            ret.optA = try (Int?).fromXmlElem(root["optA"])
            ret.optB = try (String?).fromXmlElem(root["optB"])
        }
        return ret
    }
}

//
//conforming XmlSerializable
extension MyClass{
    static func fromXmlElem(root:AEXMLElement)throws -> Self {
        let ret = self.init()
        do{
            ret.internalStruct = try InternalStruct.fromXmlElem(root["internalStruct"])
            ret.arr = try [String].fromXmlElem(root["arr"])
            ret.dict = try [String: Int].fromXmlElem(root["dict"])
        }
        return ret
    }
}

let val2New = try MyClass.fromXmlString(xmlStr!)
```
Then variable **val2** and **val2New** should be same.

You can also call fromXmlData() to construct your class/struct from NSData, or call fromXmlFile() to construct your class/struct from File.
##Here's the complete sample code:
```swift
struct InternalStruct: XmlSavable, XmlRetrievable{
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
    static func fromXmlElem(root:AEXMLElement)throws -> InternalStruct {
        var ret = InternalStruct()
        do{
            ret.a = try Int.fromXmlElem(root["a"])
            ret.b = try String.fromXmlElem(root["b"])
            ret.c = try Bool.fromXmlElem(root["c"])
            ret.d = try Double.fromXmlElem(root["d"])
            ret.e = try NSDate.fromXmlElem(root["e"])
            ret.optA = try (Int?).fromXmlElem(root["optA"])
            ret.optB = try (String?).fromXmlElem(root["optB"])
        }
        return ret
    }
}


class MyClass: XmlSavable, XmlRetrievable{
    var internalStruct:InternalStruct
    var arr:[String]
    var dict:[String: Int]

    required init(){
        internalStruct = InternalStruct()
        arr = [String]()
        dict = [:]
    }
}

//
//conforming XmlSerializable
extension MyClass{
    static func fromXmlElem(root:AEXMLElement)throws -> Self {
        let ret = self.init()
        do{
            ret.internalStruct = try InternalStruct.fromXmlElem(root["internalStruct"])
            ret.arr = try [String].fromXmlElem(root["arr"])
            ret.dict = try [String: Int].fromXmlElem(root["dict"])
        }
        return ret
    }
}

func compare(lVal:MyClass, rVal:MyClass) -> Bool{
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

    for (key, _) in lVal.dict {
        if lVal.dict[key] != rVal.dict[key] {return false}
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
    val1.optB = "optB_new"

    let val2 = MyClass()
    val2.internalStruct = val1
    val2.arr = ["aaa", "bbb", "ccc"]
    val2.dict = ["a":1, "b":10, "c":100]

    do {
        let xmlStr = try val2.toXmlString()
        print(xmlStr)

        let xmlFileUrl = getDocDirURL().URLByAppendingPathComponent("MyStruct.xml")
        try val2.toXmlFile(xmlUrl: xmlFileUrl)

        let val2New = try MyClass.fromXmlFile(xmlFileUrl)
        let ret = compare(val2, rVal: val2New)
        let retStr = ret ? "same" : "different"
        print("Compare original struct and retrieved struct. They are \(retStr)")

    }
    catch let error as NSError{
        print(error.localizedDescription)
    }
}
```
