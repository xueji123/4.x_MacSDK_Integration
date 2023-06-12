//
//  ViewController.swift
//  mac_test
//
//  Created by FYX on 2023/6/5.
//

//import Cocoa
//
//class ViewController: NSViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//    override var representedObject: Any? {
//        didSet {
//        // Update the view, if already loaded.
//        }
//    }
//
//
//}


import AppKit
import AgoraRtcKit
class ViewController: NSViewController {
    
    
    
    // 定义 localView 变量
    var localView: NSView!
    // 定义 remoteView 变量
    var remoteView: NSView!
    // 定义 agoraKit 变量
    var agoraKit: AgoraRtcEngineKit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 当加载视图后，你可以进行其他设置。
        // 初始化视频窗口
        initView()
        // 当调用声网 API 时，以下函数会被调用
        initializeAgoraEngine()
        
       var ver =  AgoraRtcEngineKit.getSdkVersion()
        print("version: \(ver)")
        setupLocalVideo()
        joinChannel()
        
        
        
        var ret1: [AgoraRtcDeviceInfo] = []
        ret1 = agoraKit.enumerateDevices(.audioRecording) ?? []
        for items in ret1 {
            print("Recording device deviceId: \(String(describing: items.deviceId)) deviceName: \(String(describing: items.deviceName)) type: \(items.type)")
            
            //                    print("Recording device deviceName: \(String(describing: items.deviceName))")
            //                    print("Recording device type: \(items.type)")
        }
        
        
        //         for item in ret1 as! Array<Any> {
        //             print("ret1: devicename: \((item as AnyObject).deviceName) deviceId: \((item as AnyObject).deviceId) type: \((item as AnyObject).type?)")
        //         }
        
        //        let ret2 =  agoraKit?.enumerateDevices(.audioPlayout)
        
        var ret2: [AgoraRtcDeviceInfo] = []
        ret2 = agoraKit.enumerateDevices(.audioPlayout) ?? []
        for items in ret2 {
            print("Playout device deviceId: \(String(describing: items.deviceId)) deviceName: \(String(describing: items.deviceName)) type: \(items.type)")
            //                    print("Playout device deviceName: \(String(describing: items.deviceName))")
            //                    print("Playout device types: \(items.type)")
        }
        //
        //         for item in ret2 as! Array<Any> {
        //             print("              ")
        //             print("ret2: devicename: \((item as AnyObject).deviceName) deviceId: \((item as AnyObject).deviceId)")
        //         }
    }
    
    // 设置视频窗口布局
    override func viewDidLayout() {
        super.viewDidLayout()
        remoteView.frame = self.view.bounds
        localView.frame = CGRect(x: self.view.bounds.width - 200, y: 0, width: 90, height: 160)
    }
    
    func initView() {
        // 初始化远端视频窗口。只有当远端用户为主播时，才会显示视频画面
        remoteView = NSView()
        self.view.addSubview(remoteView)
        // 初始化本地视频窗口。只有当本地用户为主播时，才会显示视频画面
        localView = NSView()
        self.view.addSubview(localView)
    }
    
    
    func initializeAgoraEngine(){
        let config = AgoraRtcEngineConfig()
        
        // Swift
        //        let logConfig = AgoraLogConfig()
        // 将日志过滤器等级设置为 ERROR
        //        logConfig.level = AgoraLogLevel.error
        //        // 设置 log 的文件路径
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "ddMMyyyyHHmm"
        //
        //        let folder =  NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask,true)
        
        
        //        logConfig.filePath =  "/Users/fyx/Desktop/1复现测试demo合集/mac_test/agorasdkfyx123.log"
        
        //        logConfig.filePath = "\(folder[0])/logs/\(formatter.string(from: Date())).log"
        // 设置 log 的文件大小为 2MB
        //        logConfig.fileSizeInKB = 2 * 1024
        //
        //        config.logConfig = logConfig
        
        // 在这里输入你的 App ID.
        config.appId = ""
        
        
        // 调用 AgoraRtcEngineDelegate
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        //        agoraKit.setLogFile("/Users/fyx/Desktop/1agoratest.log")
    }
    
    func setupLocalVideo(){
        // 启用视频模块
        agoraKit?.enableVideo()
        // 开始本地预览
        agoraKit?.startPreview()
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        // 设置本地视图
        agoraKit?.setupLocalVideo(videoCanvas)
    }
    
    func joinChannel(){
        //设置音频输入设备系统不跟随
                agoraKit?.followSystemRecordingDevice(false)
        
        //设置音频输出设备系统不跟随
        agoraKit?.followSystemPlaybackDevice(false)
        let option = AgoraRtcChannelMediaOptions()
        // 在视频直播场景下，将频道场景设置为 liveBroadcasting
        //          option.channelProfile = .of((Int32)(AgoraChannelProfile.liveBroadcasting.rawValue))
        option.channelProfile = .liveBroadcasting
        // 设置用户角色为主播或观众
        //          option.clientRoleType = .of((Int32)(AgoraClientRole.broadcaster.rawValue))
        option.clientRoleType = .broadcaster
        
        // 使用临时 token 加入频道，在这里传入你的项目的 token 和频道名。
        agoraKit?.joinChannel(byToken: "", channelId: "test123", uid: 0, mediaOptions: option)

        
        
    }
    
    override func viewDidDisappear() {
        agoraKit?.stopPreview()
        agoraKit?.leaveChannel(nil)
    }
    
    
    @IBAction func SwitchRecording(_ sender: NSSwitch) {
        
        agoraKit?.followSystemRecordingDevice(sender.state == .on)
        
    }
    
    
    @IBAction func SwitchPlayback(_ sender: NSSwitch) {
        agoraKit?.followSystemPlaybackDevice(sender.state == .on)
    }
    
    
    
    @IBAction func startMicTest(_ sender: NSSwitch) {
        if(sender.state == .on){
            agoraKit?.startRecordingDeviceTest(50)
        }else{
            agoraKit?.stopRecordingDeviceTest()
        }
        
    }
    
    
    @IBAction func startSpeakerTest(_ sender: NSSwitch) {
        if(sender.state == .on){
            
            if let filepath = Bundle.main.path(forResource: "audiomixing", ofType: "mp3") {
                let result = agoraKit.startPlaybackDeviceTest(filepath)
                if result != 0 {
                    
                }
                
            }
            
        }
        else{
            agoraKit?.stopPlaybackDeviceTest()
        }
    }
    
    
    @IBAction func getRecordDevice(_ sender: NSButton) {
        var ret5: AgoraRtcDeviceInfo!
        ret5 = agoraKit.getDeviceInfo(.audioRecording)
        print("getDeviceInfo audioRecording deviceId: \(String(describing: ret5.deviceId)) deviceName: \(String(describing: ret5.deviceName)) type: \(ret5.type)")
    }
    
    
    
    @IBAction func getCurrentPlayDevice(_ sender: NSButton) {
        var ret6: AgoraRtcDeviceInfo!
        ret6 = agoraKit.getDeviceInfo(.audioPlayout)
        print("getDeviceInfo audioPlayout deviceId: \(String(describing: ret6.deviceId)) deviceName: \(String(describing: ret6.deviceName)) type: \(ret6.type)")
    }
    
    
    @IBOutlet weak var setRecord: NSTextField!
    
    
    @IBOutlet weak var setPlayback: NSTextField!
    
    
    @IBAction func setRecordingDevice(_ sender: NSButton) {
        
        let channel1 = setRecord.stringValue
                   
        agoraKit?.setDevice(.audioRecording, deviceId: channel1)
    }
    
    
    
    @IBAction func setPlaybackingDevice(_ sender: NSButton) {
        let channel2 = setPlayback.stringValue
        agoraKit?.setDevice(.audioPlayout, deviceId: channel2)
    }
    
    
}





extension ViewController: AgoraRtcEngineDelegate{
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int){
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteView
        agoraKit?.setupRemoteVideo(videoCanvas)
    }
    
    func  rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        
        print("didJoinChannel \(channel) uid \(uid) elapsed \(elapsed)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, device deviceId: String, type deviceType: AgoraMediaDeviceType, stateChanged state: Int) {
        print("DeviceStateChanged \(deviceId) type \(deviceType.rawValue) state \(state)")
        
        print("============")
        
        //设置音频输入设备为当前使用设备
//                var ret3: AgoraRtcDeviceInfo!
//                ret3 = agoraKit.getDeviceInfo(.audioRecording)
//                print("getDeviceInfo audioRecording deviceId: \(String(describing: ret3.deviceId)) deviceName: \(String(describing: ret3.deviceName)) type: \(ret3.type)")
//
//        agoraKit?.setDevice(.audioRecording, deviceId: (String(describing: ret3.deviceId)))
//        agoraKit?.setDevice(.audioRecording, deviceId: "169")
        
        
        
        
        
        //
        //        print("============")
        
        //设置音频输出设备为当前使用设备
//        var ret4: AgoraRtcDeviceInfo!
//        ret4 = agoraKit.getDeviceInfo(.audioPlayout)
//        print("getDeviceInfo audioPlayout deviceId: \(String(describing: ret4.deviceId)) deviceName: \(String(describing: ret4.deviceName)) type: \(ret4.type)")
//        agoraKit?.setDevice(.audioPlayout, deviceId: (String(describing: ret4.deviceId)))
        
//        agoraKit?.setDevice(.audioPlayout, deviceId: "318")
        
        
        
    }
    
    
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, reportAudioVolumeIndicationOfSpeakers speakers: [AgoraRtcAudioVolumeInfo], totalVolume: Int) {
        for speaker in speakers {
            print("reportAudioVolumeIndicationOfSpeakers:\(speaker.uid), \(speaker.volume)")
            if(speaker.uid == 0) {
                //                  micTestingVolumeIndicator.doubleValue = Double(speaker.volume)
            }
        }
    }
}


