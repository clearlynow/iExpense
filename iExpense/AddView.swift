//
//  AddView.swift
//  iExpense
//
//  Created by Alison Gorman on 2/5/21.
//

import SwiftUI

struct AddView: View {
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = ""
    @State private var alertIsPresented = false
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var expenses: Expenses

    static let types = ["Business", "Personal"]

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                Picker("Type", selection: $type) {
                    ForEach(Self.types, id: \.self) {
                        Text($0)
                    }
                }
                TextField("Amount", text: $amount)
                    .keyboardType(.numberPad)
            }
            .navigationBarTitle("Add new expense")
            .navigationBarItems(trailing: Button("Save") {
                if let actualAmount = Int(self.amount) {
                    let item = ExpenseItem(name: self.name, type: self.type, amount: actualAmount)
                    self.expenses.items.append(item)
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.alertIsPresented = true
                }
            })
        }
        .alert(isPresented: $alertIsPresented) { () -> Alert in
            Alert(title: Text("Error"), message: Text("You must enter a whole number"), dismissButton: .default(Text("OK")))
        }
    }
}

struct AddView_Previews: PreviewProvider {

    
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
