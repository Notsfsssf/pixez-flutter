//
//  AppWidgetDBManager.swift
//  Runner
//
//  Created by Perol Notsf on 2022/9/4.
//

import FMDB
import Foundation

struct AppWidgetIllust {
    let id:Int
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
    static func fetch() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dummyDatabaseName = "glanceillustpersist.db"
        let documentsDirectory = paths[0].appendingPathComponent(dummyDatabaseName)
        let db = FMDatabase(path: documentsDirectory.path)
        var illusts = [AppWidgetIllust]()
        do {
            db.open()
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
                let illust = AppWidgetIllust(id:Int(exactly: id)!,illustId: Int(illustId), userId: Int(userId), pictureUrl: pictureId!, title: title!, userName: userName!, time: Int(exactly: time)!, type: type!)
                illusts.append(illust)
                print("db === \(illust)")
            }
            db.close()
        } catch {}
        if let groupDb = groupDB() {
            do {
                groupDb.open()
                try groupDb.executeQuery("""
                create table \(tableIllustPersist) (
                  \(cid) integer primary key autoincrement,
                  \(cillust_id) integer not null,
                  \(cuser_id) integer not null,
                  \(cpicture_url) text not null,
                  \(ctype) text not null,
                  \(ctitle) text,
                  \(cuser_name) text,
                    \(ctime) integer not null
                  )
                """, values: nil)
                for i in illusts {
                    if let ill = fetchIllusts(db: db).first {
                        try groupDb.executeUpdate("insert into \(tableIllustPersist) (\(cid),\(cillust_id),\(cuser_id),\(cpicture_url),\(ctype),\(ctitle),\(cuser_name),\(ctime)) values (?,?,?,?,?,?,?,?)", values: [i.id,i.illustId, i.userId, i.pictureUrl, i.type, i.title, i.userName, i.time])
                    } else {
                        try groupDb.executeUpdate("insert into \(tableIllustPersist) (\(cillust_id),\(cuser_id),\(cpicture_url),\(ctype),\(ctitle),\(cuser_name),\(ctime)) values (?,?,?,?,?,?,?)", values: [i.illustId, i.userId, i.pictureUrl, i.type, i.title, i.userName, i.time])
                    }
                }
                groupDb.close()
            } catch {
                print("group db error\(error.localizedDescription)")
            }
        }
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
                let illust = AppWidgetIllust(id:Int(cid)!,illustId: Int(illustId), userId: Int(userId), pictureUrl: pictureId!, title: title!, userName: userName!, time: Int(exactly: time)!, type: type!)
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
}
