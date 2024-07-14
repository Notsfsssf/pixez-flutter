//
//  AppWidgetDBManager.swift
//  SsssGridManExtension
//
//  Created by Perol Notsf on 2022/9/9.
//

import FMDB
import Foundation

struct AppWidgetIllust {
    let id: Int
    let illustId: Int
    let userId: Int
    let pictureUrl: String
    let largeUrl: String?
    let originalUrl: String?
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
    static let coriginal_url = "original_url"
    static let clarge_url = "large_url"
    static let ctitle = "title"
    static let cuser_name = "user_name"
    static let ctime = "time"
    static let ctype = "type"
    
    static func fetch() -> [AppWidgetIllust] {
        guard let db = groupDB() else {
            return []
        }
        var illusts = [AppWidgetIllust]()
        do {
            db.open()
            let qSet = try db.executeQuery("select * from \(tableIllustPersist) where type = ? ORDER BY RANDOM() LIMIT 1", values: ["recom"])
            while qSet.next() {
                let id = qSet.int(forColumn: cid)
                let illustId = qSet.int(forColumn: cillust_id)
                let userId = qSet.int(forColumn: cuser_id)
                let pictureId = qSet.string(forColumn: cpicture_url)
                let title = qSet.string(forColumn: ctitle)
                let userName = qSet.string(forColumn: cuser_name)
                let time = qSet.int(forColumn: ctime)
                let type = qSet.string(forColumn: ctype)
                let largeUrl = qSet.string(forColumn: clarge_url)
                let originalUrl = qSet.string(forColumn: coriginal_url)
                let illust = AppWidgetIllust(id: Int(exactly: id)!, illustId: Int(illustId), userId: Int(userId), pictureUrl: pictureId!, largeUrl: largeUrl, originalUrl: originalUrl, title: title!, userName: userName!, time: Int(exactly: time)!, type: type!)
                illusts.append(illust)
                print("db === \(illust)")
            }
            db.close()
            return illusts
        } catch {
            print("db query error === \(error.localizedDescription)")
        }
        return []
    }

    static func fetchIllusts(db: FMDatabase) -> [AppWidgetIllust] {
        var illusts = [AppWidgetIllust]()
        do {
            let qSet = try db.executeQuery("select * from glanceillustpersist", values: nil)
            while qSet.next() {
                let id = qSet.int(forColumn: cid)
                let illustId = qSet.int(forColumn: cillust_id)
                let userId = qSet.int(forColumn: cuser_id)
                let pictureId = qSet.string(forColumn: cpicture_url)
                let title = qSet.string(forColumn: ctitle)
                let userName = qSet.string(forColumn: cuser_name)
                let time = qSet.int(forColumn: ctime)
                let type = qSet.string(forColumn: ctype)
                let largeUrl = qSet.string(forColumn: clarge_url)
                let originalUrl = qSet.string(forColumn: coriginal_url)
                let illust = AppWidgetIllust(id: Int(cid)!, illustId: Int(illustId), userId: Int(userId), pictureUrl: pictureId!, largeUrl: largeUrl, originalUrl: originalUrl, title: title!, userName: userName!, time: Int(exactly: time)!, type: type!)
                illusts.append(illust)
                print("db === \(illust)")
            }
        } catch {}
        return illusts
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

    static func illustFolder() -> URL? {
        let fileManager = FileManager.default
        if let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.pixez") {
            let newDirectory = directory.appendingPathComponent("Illusts")
            try? fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: false, attributes: nil)
            return newDirectory
        }
        return nil
    }
}
