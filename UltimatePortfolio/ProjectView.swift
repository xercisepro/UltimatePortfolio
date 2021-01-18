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
    @EnvironmentObject var dataController: DataController
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var showingSortOrder = false
    @State private var sortOrder = Item.SortOrder.optimised
    let showClosedProjects: Bool
    let projects: FetchRequest<Project>
    var projectsList: some View {
        List {
            ForEach(projects.wrappedValue) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(items(for: project)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        delete(offsets, from: project)
                    }
                    if showClosedProjects == false {
                        Button {
                            addItem(to: project)
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
            if showClosedProjects == false {
                Button(action: addProject) {
                    // In iOS 14.3 VoiceOver has a glitch that reads the label
                    // "Add Project" as "Add" no matter what accessibility label
                    // we give this button when using a label. As a result, when
                    // VoiceOver is running we use text view as a replacement
                    // to force a correct reading without losing the original layout.
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
    init(showClosedProjects: Bool) {
        self.showClosedProjects = showClosedProjects
        projects = FetchRequest<Project>(
            entity: Project.entity(),
            sortDescriptors: [ NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)],
            predicate: NSPredicate(format: "closed = %d",
            showClosedProjects)
        )
    }
    var body: some View {
        NavigationView {
            Group {
                if projects.wrappedValue.count == 0 {
                    Text("There's nothing here right now.")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                }
            }
            .navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                addProjectToolBarITem
                sortProjectToolBarItem
            }
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimised")) { sortOrder = .optimised },
                    .default(Text("Creation Date")) { sortOrder = .creationDate},
                    .default(Text("Title")) { sortOrder = .title }
                ])
            }
            SelectSomethingView()
        }
    }
    func items(for project: Project) -> [Item] {
        switch sortOrder {
        case .title:
            return project.projectItems.sorted(by: \Item.itemTitle )
        case .creationDate:
            return project.projectItems.sorted(by: \Item.itemCreationDate )
        default:
            return project.projectItemsDefaultSorted
        }
    }
    func addItem(to project: Project) {
        withAnimation {
            let item = Item(context: managedObjectContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
    }
    func delete(_ offsets: IndexSet, from project: Project) {
        let allItems = items(for: project)
        for offset in offsets {
            let item = allItems[offset]
            dataController.delete(item)
        }
        dataController.save()
    }
    func addProject() {
        withAnimation {
            let project = Project(context: managedObjectContext)
            project.closed = false
            project.creationDate = Date()
            dataController.save()
        }
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    static var previews: some View {
        ProjectView(showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
