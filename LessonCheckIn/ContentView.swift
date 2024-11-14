import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var addLessonPopup = false
    @State private var showAllLessons = false

    @Query var lessons: [Lesson]
    
    init() {
        let weekday = Calendar.current.component(.weekday, from: Date())
        _lessons = Query(filter: #Predicate<Lesson> { lesson in lesson.lessonDay == (weekday == 1 ? 7 : weekday - 1) })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Lessons")
                .font(.largeTitle)
                .padding()
            
            if lessons.isEmpty {
                // Display placeholder message and add lesson button when there are no lessons
                VStack(alignment: .center, spacing: 20) {
                    Text("You don't have any lessons for today.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                }
            }
                else {
                // Display list of lessons when lessons array is not empty
                List(lessons) { lesson in
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .frame(height: 100)
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text(lesson.lessonName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Time: \(lesson.lessonTime, formatter: timeFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                withAnimation {
                                    toggleAbsence(for: lesson)
                                }
                            }) {
                                Text(lesson.isPresent ? "Present" : "Absent")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .frame(minWidth: 80)
                                    .background(lesson.isPresent ? Color.green : Color.red)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                }
            }
            
            HStack {
                Button(action: {
                    showAllLessons = true
                }) {
                    Text("Lessons")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .sheet(isPresented: $showAllLessons) {
                    AllLessonsView()
                }
                
                Spacer()
                
                Button(action: {
                    addLessonPopup = true
                }) {
                    Text("Add Lesson")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .sheet(isPresented: $addLessonPopup) {
                    AddLessonView(addLessonPopup: $addLessonPopup)
                }
            }
            .padding(20)
        }
    }
    
    private func toggleAbsence(for lesson: Lesson) {
        lesson.isPresent.toggle()
        if lesson.isPresent {
            lesson.incrementAbsence()
        } else {
            lesson.decrementAbsence()
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct AllLessonsView: View {
    
    @Environment(\.modelContext) private var context
    @Query var lessons: [Lesson]
    @State private var addLessonPopup = false
    
    var body: some View {
        NavigationView {
            List {
                if lessons.isEmpty {
                    VStack(alignment: .center, spacing: 20) {
                        Text("Don't have any lessons, try to add one!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            addLessonPopup = true
                        }) {
                            Text("Add Lesson")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .sheet(isPresented: $addLessonPopup) {
                            AddLessonView(addLessonPopup: $addLessonPopup)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(lessons) { lesson in
                        NavigationLink(destination: EditLessonView(lesson: lesson)) {
                            VStack(alignment: .leading) {
                                Text(lesson.lessonName)
                                    .font(.headline)
                                Text("Day: \(dayName(for: lesson.lessonDay))")
                                Text("Time: \(lesson.lessonTime, formatter: timeFormatter)")
                                    .font(.subheadline)
                                Text("Absences: \(lesson.numberOfAbsences)")
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteLesson)
                }
            }
            .navigationTitle("All Lessons")
        }
    }
    
    private func deleteLesson(at offsets: IndexSet) {
        for index in offsets {
            let lesson = lessons[index]
            context.delete(lesson)
        }
    }
    
    private func dayName(for day: Int) -> String {
        switch day {
        case 1: return "Monday"
        case 2: return "Tuesday"
        case 3: return "Wednesday"
        case 4: return "Thursday"
        case 5: return "Friday"
        case 6: return "Saturday"
        case 7: return "Sunday"
        default: return ""
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct EditLessonView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var lessonName: String
    @State private var lessonDay: Int
    @State private var lessonTime: Date
    
    
    var lesson: Lesson
    
    init(lesson: Lesson) {
        self.lesson = lesson
        _lessonName = State(initialValue: lesson.lessonName)
        _lessonDay = State(initialValue: lesson.lessonDay)
        _lessonTime = State(initialValue: lesson.lessonTime)
    }
    
    var body: some View {
        Form {
            TextField("Lesson Name", text: $lessonName)
            
            Picker("Day of the Week", selection: $lessonDay) {
                ForEach(1...7, id: \.self) { day in
                    Text(dayName(for: day)).tag(day)
                }
            }
            
            DatePicker("Time", selection: $lessonTime, displayedComponents: .hourAndMinute)
        }
        .navigationTitle("Edit Lesson")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
            }
        }
    }
    
    
    private func saveChanges() {
        lesson.lessonName = lessonName
        lesson.lessonDay = lessonDay
        lesson.lessonTime = lessonTime
        
        do {
            try context.save()
            dismiss()
            
        } catch {
            print("Error saving changes: \(error)")
        }
        
    }
    
    
    private func dayName(for day: Int) -> String {
        switch day {
        case 1: return "Monday"
        case 2: return "Tuesday"
        case 3: return "Wednesday"
        case 4: return "Thursday"
        case 5: return "Friday"
        case 6: return "Saturday"
        case 7: return "Sunday"
        default: return ""
        }
    }
}

struct AddLessonView: View {
    
    @Binding var addLessonPopup: Bool
    @Environment(\.modelContext) private var context
    @State private var lessonName = ""
    @State private var lessonDay = 1
    @State private var lessonTime = Date()
    @State private var numberOfAbsences = 0
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Lesson Name", text: $lessonName)
                
                Picker("Day of the Week", selection: $lessonDay) {
                    ForEach(1...7, id: \.self) { day in
                        Text(dayName(for: day)).tag(day)
                    }
                }
                
                DatePicker("Time", selection: $lessonTime, displayedComponents: .hourAndMinute)
                
            
                
            }
            .navigationTitle("Add New Lesson")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveLesson()
                        addLessonPopup = false
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        addLessonPopup = false
                    }
                }
            }
        }
    }
    
    private func saveLesson() {
        let newLesson = Lesson(lessonName: lessonName, lessonDay: lessonDay, lessonTime: lessonTime)
        context.insert(newLesson)
    }
    
    private func dayName(for day: Int) -> String {
        switch day {
        case 1: return "Monday"
        case 2: return "Tuesday"
        case 3: return "Wednesday"
        case 4: return "Thursday"
        case 5: return "Friday"
        case 6: return "Saturday"
        case 7: return "Sunday"
        default: return ""
        }
    }
}

#Preview {
    ContentView()
}

