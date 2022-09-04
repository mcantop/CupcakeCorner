//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Maciej on 02/09/2022.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order
    
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var showingAlertError = false
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://hws.dev/img/cupcakes@3x.jpg"), scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total cost is \(order.data.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button {
                    Task {
                        await placeOrder()
                    }
                } label: {
                    Text("Place order")
                }
                .padding()
                
            }
        }
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank you", isPresented: $showingAlert) {
            Text("OK")
        } message: {
            Text(alertMessage)
        }
        
        .alert("Error", isPresented: $showingAlertError) {
            Text("Close")
        } message: {
            Text(alertMessage)
        }
    }
    
    func placeOrder() async {
        guard let encoded = try? JSONEncoder().encode(order.data) else {
            print("Failed to encode order.")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            let decoded = try JSONDecoder().decode(OrderData.self, from: data)
            alertMessage = "Your order for \(decoded.quantity) x \(OrderData.types[decoded.type].lowercased()) cupcakes is on its way!"
            showingAlert.toggle()
        } catch {
            alertMessage = "\(error)"
            showingAlertError.toggle()
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
