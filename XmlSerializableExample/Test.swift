//
//  Test.swift
//  XmlSerializable
//
//  Created by ixprt13 on 9/16/15.
//  Copyright © 2015 williamni. All rights reserved.
//

import Foundation

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
    /*func toXmlElem(rootName:String) -> AEXMLElement {
        let root = AEXMLElement(rootName)
        
        root.addChild(internalStruct.toXmlElem("internalStruct"))
        
        let arrElem = root.addChild(name: "arr")
        for item in arr{
            arrElem.addValueChild(name: MyStruct.getArrItemStr(), value: item)
        }
        
        return root
    }*/
    
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











