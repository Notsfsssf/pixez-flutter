//
//  SSSGridman.swift
//  SSSGridman
//
//  Created by  perol on 2021/3/27.
//

import WidgetKit
import SwiftUI
import Intents

struct Recommand: Codable {
    let illusts: [Illust]
}

struct User: Codable {
    let name: String
}

// MARK: - Illust
struct Illust: Codable {
    let imageUrls: ImageUrls
    let id: Int
    let title: String
    let user:User
    
    
    enum CodingKeys: String, CodingKey {
        case imageUrls = "image_urls"
        case id
        case title
        case user
    }
}

// MARK: - ImageUrls
struct ImageUrls: Codable {
    let squareMedium: String
    
    enum CodingKeys: String, CodingKey {
        case squareMedium = "square_medium"
    }
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), i: UIImage(named: "ic_launcher-playstore"),title: "",userName: "")
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, i: UIImage(named: "ic_launcher-playstore"),title: "",userName: "")
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        print("time line start")
        let userDefault = UserDefaults(suiteName: "group.pixez")
        let time = userDefault!.integer(forKey: "widgetkit.app_widget_time")
        if  let data = userDefault!.string(forKey: "widgetkit.app_widget_data") {
            let host = userDefault!.string(forKey: "widgetkit.picture_source") ?? "i.pximg.net"
            userDefault!.set(data, forKey: "widgetkit.pre_app_widget_data")
            userDefault!.set(data, forKey: "widgetkit.pre_picture_source")
            let decoder = JSONDecoder()
            let recommand = try! decoder.decode(Recommand.self, from: data.data(using: .utf8)!)
            let randomIndex = Int(arc4random() % UInt32(recommand.illusts.count-1))
            guard let url = URL(string:recommand.illusts[randomIndex].imageUrls.squareMedium.replacingOccurrences(of: "i.pximg.net", with: host) ) else { return }
            var request = URLRequest(url: url)
            request.setValue("https://app-api.pixiv.net/", forHTTPHeaderField: "referer")
            request.setValue("PixivIOSApp/5.8.0", forHTTPHeaderField: "User-Agent")
            URLSession.shared.dataTask(with: request){ (data, response, error) in
                if let image = UIImage(data: data!){
                    let currentDate = Date()
                    let entry = SimpleEntry(date: currentDate, configuration: configuration, i: image,title:recommand.illusts[randomIndex].title,userName: recommand.illusts[randomIndex].user.name)
                    entries.append(entry)
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    if(time<10){
                        let count = time+1
                        userDefault!.setValue(count, forKey: "widgetkit.app_widget_time")
                    }else{
                        userDefault!.removeObject(forKey:  "widgetkit.app_widget_time")
                        userDefault!.removeObject(forKey:  "widgetkit.app_widget_data")
                    }
                    completion(timeline)
                }
                else{
                    print(error ?? "")
                }
            }.resume()
            
        }else{
            if  let data = userDefault!.string(forKey: "widgetkit.pre_app_widget_data") {
                let host = userDefault!.string(forKey: "widgetkit.pre_picture_source") ?? "i.pximg.net"
                let decoder = JSONDecoder()
                let recommand = try! decoder.decode(Recommand.self, from: data.data(using: .utf8)!)
                let randomIndex = Int(arc4random() % UInt32(recommand.illusts.count-1))
                guard let url = URL(string:recommand.illusts[randomIndex].imageUrls.squareMedium.replacingOccurrences(of: "i.pximg.net", with: host) ) else { return }
                var request = URLRequest(url: url)
                request.setValue("https://app-api.pixiv.net/", forHTTPHeaderField: "referer")
                request.setValue("PixivIOSApp/5.8.0", forHTTPHeaderField: "User-Agent")
                URLSession.shared.dataTask(with: request){ (data, response, error) in
                    if let image = UIImage(data: data!){
                        let currentDate = Date()
                        let entry = SimpleEntry(date: currentDate, configuration: configuration, i: image,title:recommand.illusts[randomIndex].title,userName: recommand.illusts[randomIndex].user.name)
                        entries.append(entry)
                        let timeline = Timeline(entries: entries, policy: .atEnd)
                        completion(timeline)
                    }
                    else{
                        print(error ?? "")
                    }
                }.resume()
                return
            }
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, configuration: configuration, i: UIImage(named: "ic_launcher-playstore"),title: "",userName: "")
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let i:UIImage?
    let title:String
    let userName:String
}

struct SSSGridmanEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                Image(uiImage: entry.i!).resizable().scaledToFill().frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
//                VStack (alignment: .leading, spacing: 10){
//                    Text(entry.title)
//                        .font(.caption)
//                        .foregroundColor(.white)
//                    
//                    Text(entry.userName)
//                        .font(.caption)
//                        .foregroundColor(.white)
//                }.padding(EdgeInsets(top: 3, leading: 15, bottom: 3, trailing: 0))
            }
        }
    }
}

@main
struct SSSGridman: Widget {
    let kind: String = "SSSGridman"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SSSGridmanEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct SSSGridman_Previews: PreviewProvider {
    static var previews: some View {
        SSSGridmanEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), i: UIImage(named: "ic_launcher-playstore"),title: "Title",userName: "My Load"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
