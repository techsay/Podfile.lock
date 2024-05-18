//
//  ParsePods.swift
//  PodfileLock
//
//  Created by 聂小波 on 2024/5/17.
//

import Cocoa
import Foundation

var myDict: [String: Int] = [:]
var listDict: [String: [String]] = [:]
var names_list: [String:Int] = [:]
var relat_dic: [String:[String]] = [:]


// 读取文件
func runWithLockFile(url: URL) {
    do {
        let string = try String(contentsOf: url, encoding: .utf8)
        if string.isEmpty {
            NSAlert().show(title: "Error", msg: "数据为空！")
            return
        }
        runPodfile(lockfileContent: string)
    } catch {
        NSAlert().show(title: "Error", msg: error.localizedDescription)
    }
}

// 解析Podfile.lock中PODS信息
func runPodfile(lockfileContent: String) {
    do {
        
        var m_name = ""
        var inPODS = 0
        var depends_all_List: [String] = []
        var depends_single_list: [String] = []
        var depends_single_dics: [String: [String]] = [:]
        
        let lines = lockfileContent.components(separatedBy: .newlines)
        // 解析Podfile.lock
        for line in lines {
            if line.starts(with: "PODS:") {
                print("开始PODS:")
                inPODS = 1
            } else if inPODS == 1 && line.starts(with: "  - ") {
                let next_m_name = getFileName(line)
                if m_name == next_m_name {
                    continue
                } else {
                    if !m_name.isEmpty, !depends_single_dics.keys.contains(m_name), !depends_single_list.isEmpty {
                        depends_single_dics[m_name] = depends_single_list
                    }
                    
                    depends_single_list = []
                    updateFileName(m_name)
                    
                    m_name = getFileName(line)
                    
                    if !m_name.isEmpty, let existingList = depends_single_dics[m_name] {
                        depends_single_list = existingList
                    }
                }
            } else if inPODS == 1 && line.starts(with: "    - ") {
                let name = getFileName(line)
                if name == m_name {
                    continue
                }
                
                if listDict[m_name] == nil {
                    listDict[m_name] = [name]
                } else if !listDict[m_name]!.contains(name) {
                    listDict[m_name]!.append(name)
                }
                
                let line_dep_s = "\(m_name)(\(m_name))---> \(name)(\(name))"
                
                if !depends_single_list.contains(line_dep_s) {
                    depends_single_list.append(line_dep_s)
                }
                
                if !depends_all_List.contains(line_dep_s) {
                    depends_all_List.append(line_dep_s)
                }
                
            } else if inPODS == 1 && !line.isEmpty && line.first!.isLetter {
                updateFileName(m_name)
                
                if !m_name.isEmpty, !depends_single_dics.keys.contains(m_name), !depends_single_list.isEmpty {
                    depends_single_dics[m_name] = depends_single_list
                }
                
                depends_single_list = []
                break
            }
        }
        
        while listDict.keys.count > 0 {
            for key in listDict.keys {
                updateValueName(key)
            }
        }
        
        var list_sorted_dict: [Int: [String]] = [:]
        
        for (key, value) in myDict {
            if list_sorted_dict[value] == nil {
                list_sorted_dict[value] = [key]
            } else {
                list_sorted_dict[value]?.append(key)
            }
        }
        
        let sortedKeys = list_sorted_dict.keys.sorted(by: >)
        
        // 每个模块的依赖信息
        var depends_graph_singles = ""
        var depends_list_msg = ""
        var depends_all_msg = "```mermaid\n  graph LR\n"
        
        for line_info in depends_all_List {
            depends_all_msg += line_info + "\n"
            
            if let last_open_bracket = line_info.lastIndex(of: "("),
               let last_close_bracket = line_info.lastIndex(of: ")") {
                let right_name = line_info[(last_open_bracket..<last_close_bracket)].suffix(from: line_info.index(after: last_open_bracket))
                if !right_name.isEmpty, let existingList = depends_single_dics[String(right_name)], !existingList.isEmpty {
                    depends_single_dics[String(right_name)]?.append(line_info)
                }
            }
        }
        
        // 全局依赖表信息
        depends_all_msg += "\n```\n"
        // 全局单个依赖json信息
        var depends_all_json = "let names_list = [\n"
        var idx_json_total = 0
        
        for key in sortedKeys {
            guard let m_list_names = list_sorted_dict[key] else {
                continue
            }
            
            depends_list_msg += "模块层 \(key) ：\(m_list_names)\n\n"
            var idx_json = 0
            
            for module_name in m_list_names {
                if let single_list = depends_single_dics[module_name], !single_list.isEmpty {
                    var single_list_str = "```mermaid\n  graph LR\n"
                    var depds:[String] = []
                    
                    for single_list_name in single_list {
                        single_list_str += single_list_name + "\n"
                        depds.append(single_list_name)
                    }
                    relat_dic[module_name] = depds
                    
                    single_list_str += "```\n"
                    depends_graph_singles += single_list_str
                }
                names_list[module_name] = idx_json_total + idx_json
                depends_all_json += "\"\(module_name)\":\(idx_json_total + idx_json),\n"
                idx_json += 1
            }
            
            idx_json_total += 100
        }
        
        depends_all_json += "]"
        
        //信息保存md格式文件，并通过Typora等支持 Markdown 软件打开显示 依赖关系图
        print("全局单个依赖json生成...")
        print(depends_all_json)


        print("全局单个依赖表生成...")
        print(depends_graph_singles)

        print("全局依赖表生成...")
        print(depends_all_msg)

        print("全局层级关系列表生成...")
        print(depends_list_msg)
        
    }
    
}

func updateFileName(_ m_name: String) {
    if m_name.isEmpty {
        return
    }
    
    if myDict[m_name] == nil && listDict[m_name] == nil {
        myDict[m_name] = 1
    }
}

func updateValueName(_ m_name: String) {
    guard let list_item = listDict[m_name] else {
        return
    }
    
    listDict[m_name] = nil
    var tmp_list: [String] = []
    var max_name = ""
    
    for key in list_item {
        if myDict[key] != nil {
            if max_name.isEmpty || myDict[max_name]! < myDict[key]! {
                max_name = key
            }
        } else if !tmp_list.contains(key) {
            tmp_list.append(key)
        }
    }
    
    if !max_name.isEmpty && !tmp_list.isEmpty && !tmp_list.contains(max_name) {
        tmp_list.append(max_name)
    } else if !max_name.isEmpty && tmp_list.isEmpty {
        myDict[m_name] = myDict[max_name]! + 1
    }
    
    if !tmp_list.isEmpty {
        myDict[m_name] = nil
        listDict[m_name] = tmp_list
    }
}

// 解析模块名称
func getFileName(_ line: String) -> String {
    let line = line.trimmingCharacters(in: .whitespacesAndNewlines)
    let name = line.components(separatedBy: " ")[1]
    let file_name = name.components(separatedBy: "/")[0]
    return file_name
}
