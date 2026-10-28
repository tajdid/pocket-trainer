import SwiftUI
import UIKit

enum Cartridge: Int, CaseIterable, Identifiable {
    case red, blue, yellow
    var id: Int { rawValue }
    var name: String { ["Red", "Blue", "Yellow"][rawValue] }
    var subtitle: String { ["A world of Pokémon awaits!", "A whole new world to explore!", "Your very own Pokémon story!"][rawValue] }
    var color: UIColor { [UIColor(red: 0.71, green: 0.19, blue: 0.16, alpha: 1), UIColor(red: 0.14, green: 0.34, blue: 0.65, alpha: 1), UIColor(red: 0.94, green: 0.70, blue: 0.13, alpha: 1)][rawValue] }
    var file: String { "Cartridge" + name }
}


extension Cartridge {
    var release: String { "\(self == .yellow ? "1998" : "1996") · FIRST RELEASE (JAPAN)" }
    var journey: String { self == .yellow ? "A familiar world. A friend beside you." : "Your journey begins in Kanto." }
    var mascot: String { ["Charizard", "Blastoise", "Pikachu"][rawValue] }
    var adventure: String {
        self == .yellow
        ? "Explore Kanto with Pikachu by your side. Meet new friends, challenge Gym Leaders and build a team for the journey to the Pokémon League."
        : "Leave Pallet Town for the wide world of Kanto. Discover Pokémon, challenge Gym Leaders and build a team on your way to the Pokémon League."
    }
    var trivia: String {
        ["Red and Blue were designed to connect: trading with a friend brings Pokémon from the other version into your adventure.",
         "Blue shares its Kanto journey with Red, but the Pokémon you encounter differ. A link cable and a friend help bring the two collections together.",
         "Pikachu walks behind you outside its Poké Ball. Turn around and talk to it to see how it is feeling."][rawValue]
    }
}
