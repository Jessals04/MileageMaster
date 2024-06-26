//
//  EntryView.swift
//  MileageMaster
//
//  Created by Jesse Watson on 15/04/2024.
//

import SwiftUI

struct EntryListItem: View {
    
    let entry: Entry
    private let createdAt: String?
    
    init(_ entry: Entry) {
        self.entry = entry
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX"
        if let date = inputFormatter.date(from: entry.createdAt) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "EEEE dd/MM/yyyy"
            self.createdAt = outputFormatter.string(from: date)
        } else {
            print("Error parsing date string")
            self.createdAt = nil
        }
    }
    
    // Alert
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    // Show
    @State private var showDeleteConfirmation = false
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    var body: some View {
        NavigationLink(destination: EntryView(entry)) {
            
            GeometryReader { geometry in
                VStack {
                    
                    Text(createdAt != nil ? String(entry.car.name + " on " + createdAt!) : entry.car.name)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        
                        VStack {
                            
                            // --- Total Price
                            var totalPrice = String(entry.totalPrice)
                            IconWithValue(systemName: "dollarsign.circle.fill", iconColor: Color.green, value: "$" + totalPrice)
                                .onAppear() {
                                    let numberFormatter = NumberFormatter()
                                    numberFormatter.numberStyle = .decimal
                                    let number = numberFormatter.string(from: NSNumber(value: entry.totalPrice))
                                    if number != nil {
                                        totalPrice = number!
                                    }
                                }
                            
                            // --- Liters
                            IconWithValue(systemName: "drop.fill", iconColor: Color.blue, value: String(entry.liters) + " l")
                            
                            // --- Distance
                            IconWithValue(systemName: "road.lanes", iconColor: Color.purple, value: String(entry.odoCurr - entry.odoPrev) + " km")
                            
                        }
                        .frame(width: geometry.size.width * 0.40)
                        
                        VStack {
                            
                            // --- Station
                            IconWithValue(systemName: "mappin.circle.fill", iconColor: Color.red, value: entry.station)
                            
                            // --- Notes
                            var notes = entry.notes ?? "No notes..."
                            IconWithValue(systemName: "list.clipboard.fill", iconColor: Color.orange, value: notes, lineLimit: 2)
                                .onAppear() {
                                    if entry.notes != nil {
                                        if entry.notes == "" {
                                            notes = "No notes..."
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                        }
                        
                    }
                    .swipeActions(edge: .trailing) {
                        
                        // --- Swipe to Delete
                        
                        Button() {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                        
                    }
                }
            }
            .frame(height: 90, alignment: .leading)
            .alert(isPresented: $showAlert) {
                
                // --- Alert Popup
                
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("Dismiss"))
                )
                
            }
            .confirmationDialog(
                "Are you sure you want to delete this log?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                
                // --- Confirmation Dialog
                
                Button(role: .destructive) {
                    let entryController = EntryController()
                    Task {
                        let deletedEntry: Entry? = await entryController.deleteEntry(id: entry.id)
                        if deletedEntry == nil {
                            showAlert(title: "Unknown Error", message: "There was an error deleting the log. Please try again.")
                        } else {
                            entryController.loadEntries()
                        }
                    }
                    
                } label: {
                    Text("Delete")
                        .foregroundStyle(.red)
                }
                
                Button("Cancel", role: .cancel) {}
                
            }
        }
        .tint(Colors.shared.text)
    }
    
}
