//
//  LocationCheckView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/14/24.
//

import SwiftUI
import MapKit

struct LocationCheckView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161), // Monterrey coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3) // Adjust the zoom level to show Monterrey/Santiago
    )
    
    @State private var showingNewClientView = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            Text("¿Te encuentras en la zona de Monterrey/Santiago?")
                .font(.headline)
                .padding()

            Map(coordinateRegion: $region)
                .frame(height: 300)
                .cornerRadius(15)
                .padding()

            HStack {
                Button(action: {
                    // If user selects No, open external resources
                    if let helpURL = URL(string: "https://example.com/help-resources") {
                        openURL(helpURL)
                    }
                }) {
                    Text("No")
                        .font(.headline)
                        .frame(minWidth: 100)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    // If user selects Yes, navigate to NewClientCbView
                    showingNewClientView = true
                }) {
                    Text("Sí")
                        .font(.headline)
                        .frame(minWidth: 100)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            
            NavigationLink(
                destination: NewClientCbView(), // Your next view
                isActive: $showingNewClientView
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Verificación de Ubicación")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        LocationCheckView()
    }
}
