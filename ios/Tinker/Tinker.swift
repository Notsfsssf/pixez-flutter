//
//  Tinker.swift
//  Tinker
//
//  Created by Perol Notsf on 2024/7/8.
//

import AppIntents
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    var placeHolderEntry: SimpleEntry {
        return SimpleEntry(date: .now, uiImage: nil, id: 1, illustId: 1, userId: 1, pictureUrl: "https://pixiv.net//", title: "No content available", userName: ":(", time: 0, type: "empty")
    }

    func placeholder(in context: Context) -> SimpleEntry {
        placeHolderEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = placeHolderEntry
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let imageRequestGroup = DispatchGroup()
        var entries: [SimpleEntry] = []
        DispatchQueue.global(qos: .background).async {
            let illusts = AppWidgetDBManager.fetch()
            do {
                if let folder = AppWidgetDBManager.illustFolder() {
                    guard let first = illusts.randomElement() else {
                        throw SimpleError(message: "No data")
                    }
                    let sourceUrl = first.largeUrl ?? first.pictureUrl
                    let pictureURL = folder.appendingPathComponent("\(first.id).\(sourceUrl.split(separator: ".").last ?? "png")")
                    if FileManager.default.fileExists(atPath: pictureURL.path) {
                    } else {
                        guard let fileURL = URL(string: sourceUrl) else {
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
                          let uiImage = UIImage(data: data)
                    else {
                        throw SimpleError(message: "data null")
                    }
                    entries.append(first.toSimple(uiImage: uiImage))
                    imageRequestGroup.leave()
                }
            } catch {
                entries.append(placeHolderEntry)
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

extension AppWidgetIllust {
    func toSimple(uiImage: UIImage) -> SimpleEntry {
        SimpleEntry(date: .now, uiImage: uiImage, id: id, illustId: illustId, userId: userId, pictureUrl: pictureUrl, title: title, userName: userName, time: time, type: type)
    }
}

struct SimpleError: Error {
    let message: String
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

struct TinkerEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        buildContent()
    }

    @ViewBuilder func buildContent() -> some View {
        GeometryReader { red in
            ZStack {
                if entry.type != "empty", let uiImage = entry.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: red.size.width, height: red.size.height, alignment: .center)
                }
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(entry.title ?? "")")
                                .font(.title3)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .shadow(radius: 5, x: 0, y: 5)
                            Text("@\(entry.userName ?? "")")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .shadow(radius: 5, x: 0, y: 5)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.black.opacity(0.0), .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                    )
                }
            }.frame(width: red.size.width, height: red.size.height, alignment: .center)
        }.widgetURL(URL(string: entry.type == "empty" ? "pixez://pixiv.net" : "pixez://pixiv.net/artworks/\(entry.illustId)"))
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SuperCharge: AppIntent {
    static var title: LocalizedStringResource = "Refresh recommend illust"
    static var description = IntentDescription("Refresh recommend illust")

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct Tinker: Widget {
    let kind: String = "Tinker"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ZStack {
                    Color.clear
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(entry.title ?? "")")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .shadow(radius: 5, x: 0, y: 5)
                                Text("@\(entry.userName ?? "")")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .shadow(radius: 5, x: 0, y: 5)
                            }
                            Spacer()
                        }
                    }
                    VStack {
                        HStack(alignment: .top) {
                            Spacer()
                            Button(intent: SuperCharge()) {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 4)
                        }
                        Spacer()
                    }
                }
                .widgetURL(URL(string: entry.type == "empty" ? "pixez://pixiv.net" : "pixez://pixiv.net/artworks/\(entry.illustId)"))
                .containerBackground(for: .widget) {
                    ZStack {
                        if let image = entry.uiImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                }
            } else {
                TinkerEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Tinker_Previews: PreviewProvider {
    static var previews: some View {
        let entry = SimpleEntry(date: .now, uiImage: nil, id: 1, illustId: 1, userId: 1, pictureUrl: "https://pixiv.net//", title: "Title", userName: "User", time: 0, type: "")
        TinkerEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
