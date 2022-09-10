//
//  SsssGridMan.swift
//  SsssGridMan
//
//  Created by Perol Notsf on 2022/9/4.
//

import FMDB
import Intents
import SwiftUI
import WidgetKit

struct SimpleError: Error {
    let message: String
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, uiImage: nil, id: 1, illustId: 1, userId: 1, pictureUrl: "https://pixiv.net//", title: "", userName: nil, time: 0, type: "")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, uiImage: nil, id: 1, illustId: 1, userId: 1, pictureUrl: "https://pixiv.net//", title: "", userName: nil, time: 0, type: "")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let imageRequestGroup = DispatchGroup()
        var entries: [SimpleEntry] = []
        DispatchQueue.global(qos: .background).async {
            let illusts = AppWidgetDBManager.fetch()
            do {
                if let folder = AppWidgetDBManager.illustFolder(),
                   let first = illusts.randomElement()
                {
                    let pictureURL = folder.appendingPathComponent("\(first.id).\(first.pictureUrl.split(separator: ".").last ?? "png")")
                    if FileManager.default.fileExists(atPath: pictureURL.path) {
                    } else {
                        guard let fileURL = URL(string: first.pictureUrl) else {
                            throw SimpleError(message: "picture url")
                        }
                        var request = URLRequest(url: fileURL)
                        request.setValue("https://app-api.pixiv.net/", forHTTPHeaderField: "referer")
                        request.setValue("PixivIOSApp/5.8.0", forHTTPHeaderField: "User-Agent")
                        let dispatchGroup = DispatchGroup()
                        var data: Data?
                        let task = URLSession.shared.dataTask(with: request, completionHandler: { d, _, _ in
                            data = d
                            dispatchGroup.leave()
                        })
                        dispatchGroup.enter()
                        task.resume()
                        dispatchGroup.wait()
                        guard let data = data else {
                            throw SimpleError(message: "data null")
                        }
                        try data.write(to: pictureURL)
                    }
                    guard let data = try? Data(contentsOf: pictureURL),
                          let uiImage = UIImage(data: data)?.cropImage()
                    else {
                        throw SimpleError(message: "data null")
                    }
                    entries.append(first.toSimple(uiImage: uiImage, configuration: configuration))
                    imageRequestGroup.leave()
                }
            } catch {
                entries.append(SimpleEntry(date: .now, uiImage: nil, id: 1, illustId: 1, userId: 1, pictureUrl: "https://pixiv.net//", title: "", userName: nil, time: 0, type: ""))
                print("Error:\(error)")
                imageRequestGroup.leave()
            }
        }
        imageRequestGroup.enter()
        imageRequestGroup.wait()
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

extension UIImage {
    func cropImage() -> UIImage? {
        return self
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let uiImage: UIImage?
    let id: Int
    let illustId: Int
    let userId: Int
    let pictureUrl: String
    let title: String?
    let userName: String?
    let time: Int
    let type: String
}

extension AppWidgetIllust {
    func toSimple(uiImage: UIImage, configuration: ConfigurationIntent) -> SimpleEntry {
        SimpleEntry(date: .now, uiImage: uiImage, id: id, illustId: illustId, userId: userId, pictureUrl: pictureUrl, title: title, userName: userName, time: time, type: type)
    }
}

struct SsssGridManEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { red in
            ZStack {
                if let uiImage = entry.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: red.size.width, height: red.size.height, alignment: .center)
                }
                VStack {
                    Spacer()
                    Button {
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        VStack(alignment:.leading) {
                            Text("\(entry.title ?? "")")
                                .font(.title3)
                                .lineLimit(1)
                            Text("@\(entry.userName ?? "")")
                                .font(.caption2)
                                .lineLimit(1)
                        }.frame(maxWidth:.infinity)
                    }.buttonStyle(.plain)
                        .frame(maxWidth:.infinity)
                }.padding()
            }.frame(width: red.size.width, height: red.size.height, alignment: .center)
        }
    }
}

@main
struct SsssGridMan: Widget {
    let kind: String = "SsssGridMan"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SsssGridManEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct SsssGridMan_Previews: PreviewProvider {
    static var previews: some View {
        let entry = SimpleEntry(date: .now, uiImage: nil, id: 1, illustId: 1, userId: 1, pictureUrl: "https://pixiv.net//", title: "Title", userName: "User", time: 0, type: "")
        SsssGridManEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
