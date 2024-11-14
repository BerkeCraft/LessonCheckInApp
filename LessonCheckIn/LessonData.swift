//
//  LessonData.swift
//  LessonCheckIn
//
//  Created by Berke Cora on 12.11.2024.
//

import Foundation
import SwiftData

@Model
class Lesson: Identifiable {
    
    var id = UUID()
    var lessonName: String
    var lessonDay: Int
    var lessonTime: Date
    var numberOfAbsences: Int = 0
    var isPresent: Bool = true

    init(lessonName: String, lessonDay: Int, lessonTime: Date) {
        self.lessonName = lessonName
        self.lessonDay = lessonDay
        self.lessonTime = lessonTime
    }
    
    
    func incrementAbsence() {
        numberOfAbsences += 1
    }
    
    func decrementAbsence() {
        if numberOfAbsences > 0 {
            numberOfAbsences -= 1
        }
        else if numberOfAbsences == 0{
            numberOfAbsences = 0
        }
    }
}

