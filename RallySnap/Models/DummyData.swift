import Foundation
import SwiftUI

var dummySessions: [Session] = [
    Session(
        title: "Untitled 3",
        createdAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 40),
        clips: [
            Clip(title: "Clip 1", recordedAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 41), duration: 12, mode: .auto, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")),
            Clip(title: "Clip 2", recordedAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 43), duration: 8,  mode: .manual, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")),
            Clip(title: "Clip 3", recordedAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 45), duration: 15, mode: .auto, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")),
            Clip(title: "Clip 4", recordedAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 47), duration: 15, mode: .manual, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")),
            Clip(title: "Clip 5", recordedAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 48), duration: 15, mode: .auto, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4"))
        ]
    ),
    Session(
        title: "Untitled 2",
        createdAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 20),
        clips: [
            Clip(title: "Clip 1", recordedAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 21), duration: 10, mode: .auto, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4")),
            Clip(title: "Clip 2", recordedAt: Date.from(year: 2026, month: 4, day: 29, hour: 21, minute: 25), duration: 6,  mode: .auto, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4"))
        ]
    ),
    Session(
        title: "Untitled 3",
        createdAt: Date.from(year: 2026, month: 4, day: 10, hour: 21, minute: 40),
        clips: [
            Clip(title: "Clip 1", recordedAt: Date.from(year: 2026, month: 4, day: 10, hour: 21, minute: 42), duration: 9, mode: .manual, videoURL: Bundle.main.url(forResource: "VideoTennis", withExtension: "mp4"))
        ]
    )
]

var dummyAlbums: [Album] = [
    Album(title: "Forehand", coverColor: Color(white: 0.2), clips: [
        dummySessions[0].clips[0],
        dummySessions[1].clips[0]
    ]),
    Album(title: "Backhand", coverColor: Color(white: 0.15), clips: [
        dummySessions[0].clips[2],
        dummySessions[2].clips[0]
    ])
]

extension Date {
    static func from(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var c = DateComponents()
        c.year = year; c.month = month; c.day = day
        c.hour = hour; c.minute = minute
        return Calendar.current.date(from: c) ?? Date()
    }
}
