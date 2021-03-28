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

// MARK: - Illust
struct Illust: Codable {
    let imageUrls: ImageUrls
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case imageUrls = "image_urls"
        case id
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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), i: UIImage(named: "ic_launcher-playstore"))
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, i: UIImage(named: "ic_launcher-playstore"))
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        print("time line start")
        UserDefaults.standard.string(forKey: <#T##String#>)
        print(UserDefaults(suiteName: "com.perol.pixez")!.string(forKey:  "flutter.app_widget_data"))
        
        if  let data = UserDefaults(suiteName: "com.perol.pixez")!.string(forKey: "flutter.app_widget_data") {
            let host = UserDefaults(suiteName: "com.perol.pixez")!.string(forKey: "flutter.picture_source") ?? "i.pximg.net"
            let time = UserDefaults(suiteName: "com.perol.pixez")!.integer(forKey: "flutter.app_widget_time")
            print(host)
            print(time)
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
                    let entry = SimpleEntry(date: currentDate, configuration: configuration, i: image)
                    entries.append(entry)
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                }
                else{
                    print(error ?? "")
                }
            }.resume()
            if(time<10){
                let count = time+1
                UserDefaults(suiteName: "com.perol.pixez")!.setValue(count, forKey: "flutter.app_widget_time")
            }else{
                UserDefaults(suiteName: "com.perol.pixez")!.removeObject(forKey:  "flutter.app_widget_time")
                UserDefaults(suiteName: "com.perol.pixez")!.removeObject(forKey:  "flutter.app_widget_data")
            }
        }else{
            let currentDate = Date()
            let entry = SimpleEntry(date: currentDate, configuration: configuration, i: UIImage(named: "ic_launcher-playstore"))
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
}

struct SSSGridmanEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Image(uiImage: entry.i!).resizable().scaledToFill()
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
        SSSGridmanEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), i: UIImage(named: "ic_launcher-playstore")))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
