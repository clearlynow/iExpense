//
//  ContentView.swift
//  iExpense
//
//  Created by Alison Gorman on 2/4/21.
//

import SwiftUI

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return
            }
        }

        self.items = []
    }
}

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Int
}

extension ExpenseItem {
    var color: Color {
        switch amount {
        case let amount where amount < 10:
            return Color.green
        case let amount where amount < 100:
            return Color.yellow
        default:
            return Color.red
        }
    }
}

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationView {
            VStack{
            List {
                ForEach(expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }

                        Spacer()
                        Text("$\(item.amount)")
                    }
                    .foregroundColor(item.color)
                }
                .onDelete(perform: removeItems)
            }
            .navigationBarTitle("iExpense")
            }
            .navigationBarItems(leading: EditButton(),
                trailing: Button(action: {
                    self.showingAddExpense = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: self.expenses)
            .onReceive(expenses.$items) { items in
                        // This is used as a workaround to write to UserDefaults every time the items property of the expenses class is updated.
                        // This is necessary because the didSet property observer currently does NOT fire on a property with the @Published property wrapper.
                        let encoder = JSONEncoder()
                        if let encoded = try? encoder.encode(items) {
                            UserDefaults.standard.set(encoded, forKey: "Items")
                        }
                    }
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
