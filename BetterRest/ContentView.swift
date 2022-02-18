//
//  ContentView.swift
//  BetterRest
//
//  Created by Derya Antonelli on 14/02/2022.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = "Error"
    @State private var alertMessage = "Sorry, there was a problem calculating your bedtime."
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    private var bedTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(totalCoffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            return Date.now.formatted()
        }
    }
    
    private var totalCoffeeAmount: Int {
        return coffeeAmount + 1
    }
    
    var body: some View {
        NavigationView {
            VStack {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                Section(header: Text("Desired amount of sleep")) {
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }

                Section(header: Text("Daily coffee intake")) {
                    Picker(totalCoffeeAmount == 1 ? "1 cup" : "\(totalCoffeeAmount) cups", selection: $coffeeAmount) {
                        ForEach(coffeeAmount..<11, content: {number in
                               Text("\(number)")
                            })
                    }
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 400, alignment: .top)
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Your ideal bedtime is…")
                        .font(.subheadline)
                    Text("\(bedTime)")
                        .font(.largeTitle)
                }
                Spacer()
            }
            .navigationTitle("BetterRest")
            
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
