import UIKit
import Flutter
import MobileCoreServices

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "getBatteryLevel" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let path:String = call.arguments as! String;
        self.receiveBatteryLevel(result: result,path: path )
  
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    // 3 实现相应的函数

        @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {

           var showMessage = ""

           if error != nil{

              showMessage = "保存失败"

           }else{

              showMessage = "保存成功"

           }

   print("encode result: \(showMessage)")

           

     

        }
 func getAllFilePath(_ dirPath: String) -> [String]? {
     var filePaths = [String]()
     
     do {
         let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
         
         for fileName in array {
             var isDir: ObjCBool = true
             
             let fullPath = "\(dirPath)/\(fileName)"
             
             if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                 if !isDir.boolValue {
                     filePaths.append(fullPath)
                 }
             }
         }
         
     } catch let error as NSError {
         print("get file path error: \(error)")
     }
     
     return filePaths;
 }
    private func receiveBatteryLevel(result: FlutterResult,path:String) {
//      let secondVC = UIStoryboard(name: "Spotlight", bundle: nil).instantiateViewController(withIdentifier: "spotlight") as UIViewController
//      self.window.rootViewController?.present(secondVC, animated: true, completion: nil)
         let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let gifPath =  docs[0] as String + "/"+String(Int(Date.init().timeIntervalSince1970)) + ".gif"
let paths = getAllFilePath(path)
        let imageArray: NSMutableArray = NSMutableArray()
        for i in paths! {
            print(i)
                   let image = UIImage.init(named: i)
                   if image != nil {
                       imageArray.add(image!)
                  
                   }
            
               }
       let ok = saveGifToDocument(imageArray: imageArray, gifPath)
        if(ok){
            UIImageWriteToSavedPhotosAlbum(UIImage.init(named: gifPath)!, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        result(Int(1))
    }
    // 3.设置GIF属性，利用ImageIO编码GIF文件
    func saveGifToDocument(imageArray images: NSArray, _ gifPath: String) -> Bool {
        guard images.count > 0 &&
             gifPath.utf8CString.count > 0 else {
            return false
        }
        let url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, gifPath as CFString, .cfurlposixPathStyle, false)
        let destion = CGImageDestinationCreateWithURL(url!, kUTTypeGIF, images.count, nil)
        
        // 设置gif图片属性
        // 设置每帧之间播放的时间0.1
        let delayTime = [kCGImagePropertyGIFDelayTime as String:1]
        let destDic   = [kCGImagePropertyGIFDictionary as String:delayTime]
        // 依次为gif图像对象添加每一帧属性
        for image in images {
            CGImageDestinationAddImage(destion!, (image as AnyObject).cgImage!!, destDic as CFDictionary?)
            print("kkkkkkkk\(images.count)")
        }
        
        let propertiesDic: NSMutableDictionary = NSMutableDictionary()
        propertiesDic.setValue(kCGImagePropertyColorModelRGB, forKey: kCGImagePropertyColorModel as String)
        propertiesDic.setValue(16, forKey: kCGImagePropertyDepth as String)         // 设置图片的颜色深度
        propertiesDic.setValue(1, forKey: kCGImagePropertyGIFLoopCount as String)   // 设置Gif执行次数
        
//        let gitDestDic = [kCGImagePropertyGIFDictionary as String:propertiesDic]    // 为gif图像设置属性
//        CGImageDestinationSetProperties(destion!, gitDestDic as CFDictionary?)
        CGImageDestinationFinalize(destion!)
        return true
    }
}
