//
//  AwardsView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 24/11/20.
//

import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    static let tag: String? = "Awards"
    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }
    var body: some View {
        StackNavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            /*Alert has been composed rather than syntheised
                            so storage of the selected award can be achieved
                            for furhter use later on*/
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                // Order of these modifiers is precise
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(Text(award.description))
                        .buttonStyle(ImageButtonStyle())
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAwardDetails, content: getAwardAlert)
    }
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color):  Color.secondary.opacity(0.5)
    }
    func label(for award: Award) -> Text {
        Text(dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked")
    }
    func getAwardAlert() -> Alert {
        if dataController.hasEarned(award: selectedAward) {
            return Alert(
                title: Text("Unlocked: \(selectedAward.name)"),
                message: Text("\(selectedAward.description)"),
                dismissButton: .default(Text("OK"))
            )
        } else {
            return Alert(
                title: Text("Locked"),
                message: Text("\(selectedAward.description)"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
