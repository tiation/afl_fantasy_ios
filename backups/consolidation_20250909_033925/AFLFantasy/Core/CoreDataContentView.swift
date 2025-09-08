import CoreData
import SwiftUI

struct CoreDataContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Player.name, ascending: true)],
        animation: .default
    )
    private var players: FetchedResults<Player>

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(players) { player in
                        Text(player.name ?? "Unknown Player")
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("AFL Fantasy")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addSamplePlayer) {
                        Label("Add Player", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func addSamplePlayer() {
        let newPlayer = Player(context: viewContext)
        newPlayer.id = UUID().uuidString
        newPlayer.name = "Sample Player"
        newPlayer.position = "Forward"
        newPlayer.team = "Team"

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
