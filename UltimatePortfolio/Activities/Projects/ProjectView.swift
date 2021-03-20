//
//  ProjectView.swift
//  UltimatePortfolio
//
//  Created by Andrew CP Markham on 4/11/20.
//

import SwiftUI

struct ProjectView: View {
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
    @StateObject var viewModel: ViewModel
    @State private var showingSortOrder = false

    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(viewModel.items(for: project)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: project)
                    }
                    if viewModel.showClosedProjects == false {
                        Button {
                            withAnimation {
                                viewModel.addItem(to: project)
                            }
                        } label: {
                            Label("Add New Item", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    var addProjectToolBarITem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.showClosedProjects == false {
                Button {
                    // In iOS 14.3 VoiceOver has a glitch that reads the label
                    // "Add Project" as "Add" no matter what accessibility label
                    // we give this button when using a label. As a result, when
                    // VoiceOver is running we use text view as a replacement
                    // to force a correct reading without losing the original layout.
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }
    var sortProjectToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }
    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(viewModel.showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                addProjectToolBarITem
                sortProjectToolBarItem
            }
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimised")) { viewModel.sortOrder = .optimised },
                    .default(Text("Creation Date")) { viewModel.sortOrder = .creationDate},
                    .default(Text("Title")) { viewModel.sortOrder = .title }
                ])
            }
            SelectSomethingView()
        }
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        ProjectView(dataController: DataController.preview, showClosedProjects: false)
    }
}
