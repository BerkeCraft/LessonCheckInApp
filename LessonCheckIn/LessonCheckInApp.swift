//
//  LessonCheckInApp.swift
//  LessonCheckIn
//
//  Created by Berke Cora on 12.11.2024.
//

import SwiftUI
import SwiftData

@main
struct LessonCheckInApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        } .modelContainer(for: Lesson.self, inMemory: false)
    }
}
