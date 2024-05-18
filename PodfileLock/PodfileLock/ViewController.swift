

import Cocoa
import Foundation

var podfilePath: URL?

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        view.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        
        layerContentView.frame = view.bounds
        itemContentView.frame = view.bounds
        itemContentView.layer?.backgroundColor = NSColor.clear.cgColor
        
        view.addSubview(layerContentView)
        view.addSubview(itemContentView)
        
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // 将当前视图控制器的视图居中显示
        if let window = view.window {
            window.center()
        }
        
        // 将当前视图控制器的窗口置于最顶层
        view.window?.makeKeyAndOrderFront(nil)
        selectPodfile()
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // 启动后选择lock文件
    func selectPodfile() {
        guard let mainWin = self.view.window else { return }
        // 创建文件选择对话框
        let openPanel = NSOpenPanel()
            
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.beginSheetModal(for: mainWin) { [self] (result) in
            if result == NSApplication.ModalResponse.OK {
                guard let selectedFileURL = openPanel.urls.first else { return }
                print(selectedFileURL)
                // 检查文件扩展名
                if selectedFileURL.pathExtension == "lock" {
                    podfilePath = selectedFileURL
                    if let path = podfilePath {
                        showPodfile(url: path)
                    }
                } else {
                    NSAlert().show(title: "Error", msg: "Invalid file format. Please select a .lock file.")
                }
            }
        }
    }
    
    func showPodfile(url: URL) {
        // 解析Podfile.lock中PODS信息，生成图表信息和按钮位置列表
        runWithLockFile(url: url)
        
        // 显示页面按钮和画线
        showItems(vc: self)
        
        // 更新窗口大小
        let newSize = NSSize(width: max_w + 100, height: max_h + 100)
        resizeWindow(to: newSize)
        layerContentView.frame = view.bounds
        itemContentView.frame = view.bounds
    }
    
    // 调整窗口大小的方法
    var window: NSWindow? {
        return view.window
    }
    func resizeWindow(to newSize: NSSize) {
        guard let window = window else { return }
        
        var frame = window.frame
        frame.size = newSize
        window.setFrame(frame, display: true)
    }
    
    // 按钮点击事件处理方法
    func addAction(_ sender: NSButton) {
        sender.action = #selector(buttonClicked(_:))
    }
    
    @objc func buttonClicked(_ sender: NSButton) {
        itemClicked(sender, view: view)
    }
    
}
