//
//  SSSGridman.swift
//  SSSGridman
//
//  Created by  perol on 2021/3/27.
//

import WidgetKit
import SwiftUI
import Intents

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
        guard let url = URL(string: "https://i.pximg.net/img-master/img/2018/12/18/00/08/54/72162700_p0_master1200.jpg") else { return }
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
