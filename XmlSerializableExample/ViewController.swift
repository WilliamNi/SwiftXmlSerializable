

import UIKit



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        testXmlSerializable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDocDirURL() -> NSURL {
        let fileMgr = NSFileManager.defaultManager()
        let docDir = try! fileMgr.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        return docDir
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

}

