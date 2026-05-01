import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), nextClassName: "Sin clases", nextClassTime: "Sin horario", nextClassProfesor: "", nextClassAula: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), nextClassName: "Sin clases", nextClassTime: "Sin horario", nextClassProfesor: "", nextClassAula: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.gaara")
        
        let nextClassName = userDefaults?.string(forKey: "nextClassName") ?? "Sin clases"
        let nextClassTime = userDefaults?.string(forKey: "nextClassTime") ?? "Sin horario"
        let nextClassProfesor = userDefaults?.string(forKey: "nextClassProfesor") ?? ""
        let nextClassAula = userDefaults?.string(forKey: "nextClassAula") ?? ""
        
        var entries: [SimpleEntry] = []
        
        let entry = SimpleEntry(
            date: Date(),
            nextClassName: nextClassName,
            nextClassTime: nextClassTime,
            nextClassProfesor: nextClassProfesor,
            nextClassAula: nextClassAula
        )
        entries.append(entry)
        
        // Actualiza cada hora
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let nextClassName: String
    let nextClassTime: String
    let nextClassProfesor: String
    let nextClassAula: String
}

struct GaaraScheduleWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Próxima Clase")
                .font(.caption)
                .foregroundColor(.gray)
                .opacity(0.7)
            
            Text(entry.nextClassName)
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(2)
            
            Text(entry.nextClassTime)
                .font(.subheadline)
                .foregroundColor(.orange)
            
            HStack {
                if !entry.nextClassProfesor.isEmpty {
                    Text("Prof. \(entry.nextClassProfesor)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if !entry.nextClassAula.isEmpty {
                    Text("Aula \(entry.nextClassAula)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

@main
struct GaaraScheduleWidget: Widget {
    let kind: String = "GaaraScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GaaraScheduleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Próxima Clase")
        .description("Muestra tu próxima clase programada")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    GaaraScheduleWidget()
} preview: {
    SimpleEntry(date: .now, nextClassName: "Matemáticas", nextClassTime: "09:00 - 10:00", nextClassProfesor: "Dr. García", nextClassAula: "A101")
}
