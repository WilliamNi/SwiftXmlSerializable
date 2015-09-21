//
//  Test.swift
//  XmlSerializable
//
//  Created by ixprt13 on 9/16/15.
//  Copyright © 2015 williamni. All rights reserved.
//

import Foundation

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


