//
//  ContentView.swift
//  AFL4_Michael
//
//  Created by Michael on 02/06/22.
//

import SwiftUI

enum Priority: String, Identifiable, CaseIterable {
    
    var id: UUID {
        return UUID()
    }
    
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

extension Priority {
    
    var title: String{
        switch self{
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}
struct ContentView: View {
//    @AppStorage("_shouldShowOnboarding") var shouldShowOnboarding: Bool = true
    @State var shouldShowOnboarding: Bool = true
    
    @State private var title: String = ""
    
    @State private var selectedPriority: Priority = .medium
    
    @State var showSheet: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(key: "dateCreated", ascending: false)]) private var allTask: FetchedResults<Task>
    
    private func saveTask() {
        
        do {
            let task = Task(context: viewContext)
            task.title = title
            task.priority = selectedPriority.rawValue
            task.dateCreated = Date()
            try viewContext.save()
        }catch {
            print(error.localizedDescription)
        }
 
    }
    
    private func styleForPriority(_ value: String) -> Color {
        let priority = Priority(rawValue: value)
        
        switch priority {
        case .low:
            return Color.green
        case .medium:
            return Color.orange
        case .high:
            return Color.red
        default:
            return Color.gray
        }
    }
    
    private func updateTask(_ task: Task) {
        task.isChecked.toggle()
        
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = allTask[index]
            viewContext.delete(task)
            
            do {
                try viewContext.save()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationView{
            VStack {
                
                Button{
                    showSheet.toggle()
                } label: {
                    Text("Add")
                        .padding(10)
                        .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.mint, Color.cyan, Color.mint]), startPoint:  .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                }
                .halfSheet(showSheet: $showSheet){
                    
                    ZStack{
                        Color.white
                        
                        VStack{
                            TextField("Enter title", text: $title)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 400)
                            
                            Picker("Priority", selection: $selectedPriority) {
                                ForEach(Priority.allCases) { priority in
                                    Text(priority.title).tag(priority)
                                }
                            }.pickerStyle(.segmented)
                                .padding()
                            Button{
                                saveTask()
                            } label: {
                                Text("Save")
                                    .padding(10)
                                        .frame(maxWidth: 200)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color.mint, Color.cyan, Color.mint]), startPoint:  .leading, endPoint: .trailing))
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                            }
                        }
                            
                        }
                    }



                
                List {
                    ForEach(allTask) { task in
                        HStack {
                            Circle()
                                .fill(styleForPriority(task.priority!))
                                .frame(width: 15, height: 15)
                            Spacer().frame(width: 20)
                            Text(task.title ?? "")
                                .foregroundColor(task.isChecked ? .gray: .black)
                                .strikethrough(task.isChecked)
                            Spacer()
                            Image(systemName: task.isChecked ? "checkmark.circle.fill" : "checkmark.circle")
                                .foregroundColor(task.isChecked ? .green : .gray)
                                .onTapGesture {
                                    updateTask(task)
                                }
                        }
                    }.onDelete(perform: deleteTask)
                    
                }.cornerRadius(20)
                
                
                Spacer()
            }
            .padding()
            .navigationTitle("All Lists")

        }
        .fullScreenCover(isPresented: $shouldShowOnboarding, content: { OnboardingView(shouldShowOnboarding: $shouldShowOnboarding)

        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistedContainer = CoreDataManager.shared.persistentContainer
        ContentView().environment(\.managedObjectContext, persistedContainer.viewContext)
    }
}

extension View{
    
    func halfSheet<SheetView: View>(showSheet: Binding<Bool>,@ViewBuilder
                                    sheetView: @escaping ()->SheetView)-> some View{
        
        return self
            .background(
                HalfSheetHelper(sheetView: sheetView(), showSheet: showSheet)
            )
    }
}


struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable{
    
    var sheetView: SheetView
    @Binding var showSheet: Bool
    let controller = UIViewController()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.view.backgroundColor = .clear
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
        let sheetController = CustomHostingController(rootView: sheetView)
        if showSheet{
            uiViewController.present(sheetController, animated: true)
            
            DispatchQueue.main.async {
                self.showSheet.toggle()
            }
        }
    }
}

class CustomHostingController<Content: View>: UIHostingController<Content>{
    
    override func viewDidLoad() {
        
        
        if let presentationController = presentationController as?
            UISheetPresentationController{
            
            presentationController.detents = [
                .medium()]
            
            presentationController.prefersGrabberVisible = true
        }
    }
}
