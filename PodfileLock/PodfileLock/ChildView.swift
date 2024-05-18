//
//  ChildView.swift
//  PodfileLock
//
//  Created by 聂小波 on 2024/5/17.
//

import Cocoa
import Foundation

var layerContentView = FlippedView()
var itemContentView = FlippedView()


var allLines: [CAShapeLayer] = []
var selectedBtn: NSButton?
var node_dic:[Int: DependencyNode] = [:]
var btns_dic:[Int: NSButton] = [:]
var max_w = 50.0
var max_h = 50.0

struct NodeFrame: Codable {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
}

struct DependencyNode  {
    
    var name: String
    var color: NSColor
    var frame: NodeFrame
    var index: Int = -1
    var sons: [String]
    
    init(name: String, color: NSColor, frame: NodeFrame, sons: [String]) {
        self.name = name
        self.color = color
        self.frame = frame
        self.sons = sons
    }
}

class FlippedView: NSView {
    override var isFlipped: Bool {
        return true
    }
}


func showItems(vc: ViewController) {
    
    var item_x = 50
    var add_line_count = 0
    var tmp_line_count = 0
    var swappedNamesList: [Int: String] = [:]
    // 换行，一行限制以内
    let max_h_count = 10
    
    for (key, value) in names_list {
        swappedNamesList[value] = key
    }
    let sortedKeys = swappedNamesList.keys.sorted()
    let default_colors = String.colors()
    // 打印排序后的键
    var per_v_i = -1
    for curIdx in sortedKeys {
        // 更新frame
        let v_idx = Int(curIdx / 100)
        let h_idx = Int(curIdx % 100)
        
        let gap = 30
        
        let name: String = swappedNamesList[curIdx] ?? ""
        
        let color = default_colors[v_idx % default_colors.count].color()
        
        let textH:CGFloat = 30
        let font = NSFont.systemFont(ofSize: 15)
        let attributes = [NSAttributedString.Key.font: font]
        let size = name.size(withAttributes: attributes)
        let width = size.width
        // 重置
        if per_v_i != v_idx {
            add_line_count += tmp_line_count
            tmp_line_count = 0
            per_v_i = v_idx
        }
        // 换行，一行限制15个以内
        if h_idx % max_h_count == 0 {
            item_x = gap
            tmp_line_count = max(tmp_line_count, h_idx / max_h_count)
        }
        let y = CGFloat(((v_idx + 1 + add_line_count + Int(h_idx / max_h_count)) * 50))
        let x = CGFloat(item_x)
        item_x += (Int(width) + gap)
        max_w = max(max_w, x+width)
        max_h = max(max_h, y+textH)
        var item = DependencyNode(name: name, color: color, frame: NodeFrame(x: x, y: y, width: width, height: textH), sons: [])
        item.index = curIdx
        node_dic[curIdx] = item
        
        drawItem(item, vc:vc)
    }
}

func itemClicked(_ sender: NSButton, view: NSView) {
    let buttonText = sender.attributedTitle.string
    print("按钮被点击了！标题为: \(buttonText)")
    var cancelSel = false
    if let curBtn = selectedBtn, curBtn == sender {
        cancelSel = true
        selectedBtn = nil
    } else {
        selectedBtn = sender
    }
    
    let reat_list = relat_dic[buttonText] ?? []
    layerContentView.layer?.sublayers?.removeAll()
    
    btns_dic.values.forEach { btn in
        let butText = btn.attributedTitle.string
        if cancelSel || btn.tag == sender.tag {
            btn.alphaValue = 1
        } else if reat_list.contains("\(buttonText)(\(buttonText))---> \(butText)(\(butText))") {
            btn.alphaValue = 0.9 // son
            drawline(first: sender, sec: btn, up: false)
        } else if reat_list.contains("\(butText)(\(butText))---> \(buttonText)(\(buttonText))") {
            btn.alphaValue = 0.9 // father
            drawline(first: sender, sec: btn, up: true)
        } else {
            btn.alphaValue = 0.1
        }
    }
    layerContentView.setNeedsDisplay(view.bounds)
}

func drawItem(_ item: DependencyNode, vc: ViewController) {
    let buttonNode = item
    let button = NSButton(frame: CGRect(x: buttonNode.frame.x, y: buttonNode.frame.y, width: buttonNode.frame.width+20, height: buttonNode.frame.height))
    // 设置背景色
    button.wantsLayer = true
    button.layer?.backgroundColor = buttonNode.color.cgColor
    // 设置圆角
    button.layer?.cornerRadius = 6
    button.layer?.masksToBounds = true
    // 设置标题颜色
    button.attributedTitle = NSAttributedString(string: buttonNode.name, attributes: [.foregroundColor: NSColor.white])
    button.target = vc
    button.tag = item.index
    button.bezelStyle = .regularSquare
    button.isBordered = false
    
    vc.addAction(button)
    // 添加按钮到视图中
    itemContentView.addSubview(button)
    
    btns_dic[item.index] = button
}


// 画线
func drawline(first: NSButton, sec: NSButton, up: Bool) {
    let startPoint = pointLine(btn: first)
    let endPoint = pointLine(btn: sec)
    let path = CGMutablePath()
    path.move(to: startPoint)
    path.addLine(to: endPoint)
    
    let lineLayer = CAShapeLayer()
    lineLayer.path = path
    lineLayer.strokeColor = sec.layer?.backgroundColor ?? (NSColor.black).cgColor
    lineLayer.lineWidth = 1.0
    layerContentView.layer?.addSublayer(lineLayer)
    allLines.append(lineLayer)
}

func pointLine(btn: NSButton) -> CGPoint {
    let frame = btn.frame
    return CGPoint(x: frame.midX, y: frame.midY)
}
