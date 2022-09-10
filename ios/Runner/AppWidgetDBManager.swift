//
//  AppWidgetDBManager.swift
//  Runner
//
//  Created by Perol Notsf on 2022/9/4.
//

import FMDB
import Foundation

struct AppWidgetIllust {
    let id: Int
    let illustId: Int
    let userId: Int
    let pictureUrl: String
    let title: String?
    let userName: String?
    let time: Int
    let type: String
}

enum AppWidgetDBManager {
    static let tableIllustPersist = "glanceillustpersist"
    static let cid = "id"
    static let cillust_id = "illust_id"
    static let cuser_id = "user_id"
    static let cpicture_url = "picture_url"
    static let ctitle = "title"
    static let cuser_name = "user_name"
    static let ctime = "time"
    static let ctype = "type"
    
    static func copyDb() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dummyDatabaseName = "glanceillustpersist.db"
        let sourceURL = paths[0].appendingPathComponent(dummyDatabaseName)
        if !FileManager.default.fileExists(atPath: sourceURL.path) {
            print("db not exist")
            return
        }
        if let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.pixez") {
            let newDirectory = directory.appendingPathComponent("DB")
            try? FileManager.default.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            let url = newDirectory.appendingPathComponent(dummyDatabaseName)
            let data = try! Data(contentsOf: sourceURL)
            try! data.write(to: url)
        }
    }

    static func groupDB() -> FMDatabase? {
        let fileManager = FileManager.default
        let dummyDatabaseName = "glanceillustpersist.db"
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.pixez") {
            let newDirectory = directory.appendingPathComponent("DB")
            try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            let url = newDirectory.appendingPathComponent(dummyDatabaseName)
            return FMDatabase(path: url.path)
        }
        return nil
    }
}
