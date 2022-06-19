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

    var projectsList: some View {
        List(selection: $viewModel.selectedItem) {
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(viewModel.items(for: project)) { item in
                        ItemRowView(project: project, item: item)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    viewModel.delete(item)
                                }
                            }
                            .tag(item)
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
                        .buttonStyle(.borderless)
                    }
                }
                .disableCollapsing()
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onDeleteCommand {
            guard let selectedItem = viewModel.selectedItem else { return }
            viewModel.delete(selectedItem)
        }
    }
    var addProjectToolBarITem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if viewModel.showClosedProjects == false {
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
                    Label("Add Project", systemImage: "plus")
                }
            }
        }
    }
    var sortOrderToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Menu {
                Button("Optimized") { viewModel.sortOrder = .optimised }
                Button("Creation Button") { viewModel.sortOrder = .creationDate }
                Button("Tile") { viewModel.sortOrder = .title }
            } label: {
                Label("Sort", systemImage: "arror.up.arrow.down")
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
                sortOrderToolBarItem
            }
            SelectSomethingView()
        }
        .sheet(isPresented: $viewModel.showingUnlockView) {
            UnlockView()
        }
    }

    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        ProjectView(dataController: DataController.preview, showClosedProjects: false)
    }
}
