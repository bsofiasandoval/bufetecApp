//
//  LocationCheckView.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/14/24.
//
import SwiftUI
import MapKit
import CoreLocation

struct LocationCheckView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
        span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
    )
    
    
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @Environment(\.openURL) var openURL
    @EnvironmentObject var authState: AuthState
    @StateObject private var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#13295D"), Color(hex: "#2756C3")]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("¿Te encuentras en la zona del municipio de Monterrey o Santiago?")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    
                    

                MapViewRepresentable(region: $region, userLocation: $locationManager.userLocation)
                    .frame(height: 500)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .shadow(radius: 10)

                HStack(spacing: 20) {
                   Button(action: {
                       if let helpURL = URL(string: "http://10.14.255.51:3000") {
                           openURL(helpURL)
                       }
                   }) {
                       Text("No")
                           .frame(minWidth: 100)
                           .fontWeight(.medium)
                           .padding()
                           .background(Color.white)
                           .foregroundColor(Color(hex: "#13295D"))
                           .cornerRadius(10)
                   }
                   
                   // Use NavigationLink for "Sí" button
                    NavigationLink(destination: NewClientCbView().environmentObject(authState)) {
                       Text("Sí")
                           .frame(minWidth: 100)
                           .fontWeight(.medium)
                           .padding()
                           .background(Color.white)
                           .foregroundColor(Color(hex: "#13295D"))
                           .cornerRadius(10)
                   }
               }
               .padding()
            }
            .padding()
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
        })
    }
}

// Clase para manejar la ubicación del usuario
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener la ubicación del usuario: \(error.localizedDescription)")
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var userLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        // Añadir overlay del área de Monterrey
        let monterreyCoordinates = [
            CLLocationCoordinate2D(latitude: 25.790879, longitude: -100.414793),
            CLLocationCoordinate2D(latitude: 25.797077, longitude: -100.399655),
            CLLocationCoordinate2D(latitude: 25.794459, longitude: -100.382703),
            CLLocationCoordinate2D(latitude: 25.794431, longitude: -100.372611),
            CLLocationCoordinate2D(latitude: 25.779649, longitude: -100.365090),
            CLLocationCoordinate2D(latitude: 25.768010, longitude: -100.357892),
            CLLocationCoordinate2D(latitude: 25.757935, longitude: -100.349646),
            CLLocationCoordinate2D(latitude: 25.743782, longitude: -100.335134),
            CLLocationCoordinate2D(latitude: 25.739903, longitude: -100.325367),
            CLLocationCoordinate2D(latitude: 25.725618, longitude: -100.320640),
            CLLocationCoordinate2D(latitude: 25.704811, longitude: -100.311609),
            CLLocationCoordinate2D(latitude: 25.702209, longitude: -100.301496),
            CLLocationCoordinate2D(latitude: 25.702532, longitude: -100.288845),
            CLLocationCoordinate2D(latitude: 25.702563, longitude: -100.268383),
            CLLocationCoordinate2D(latitude: 25.685696, longitude: -100.264783),
            CLLocationCoordinate2D(latitude: 25.679214, longitude: -100.271622),
            CLLocationCoordinate2D(latitude: 25.673060, longitude: -100.278099),
            CLLocationCoordinate2D(latitude: 25.658163, longitude: -100.274502),
            CLLocationCoordinate2D(latitude: 25.639445, longitude: -100.268039),
            CLLocationCoordinate2D(latitude: 25.606514, longitude: -100.257614),
            CLLocationCoordinate2D(latitude: 25.588736, longitude: -100.237606),
            CLLocationCoordinate2D(latitude: 25.572216, longitude: -100.222135),
            CLLocationCoordinate2D(latitude: 25.562118, longitude: -100.217738),
            CLLocationCoordinate2D(latitude: 25.552289, longitude: -100.237419),
            CLLocationCoordinate2D(latitude: 25.536197, longitude: -100.218978),
            CLLocationCoordinate2D(latitude: 25.542805, longitude: -100.205272),
            CLLocationCoordinate2D(latitude: 25.531708, longitude: -100.196068),
            CLLocationCoordinate2D(latitude: 25.518377, longitude: -100.194308),
            CLLocationCoordinate2D(latitude: 25.524486, longitude: -100.191777),
            CLLocationCoordinate2D(latitude: 25.518918, longitude: -100.184980),
            CLLocationCoordinate2D(latitude: 25.512245, longitude: -100.181933),
            CLLocationCoordinate2D(latitude: 25.502218, longitude: -100.173303),
            CLLocationCoordinate2D(latitude: 25.484401, longitude: -100.161569),
            CLLocationCoordinate2D(latitude: 25.463754, longitude: -100.150463),
            CLLocationCoordinate2D(latitude: 25.443666, longitude: -100.144287),
            CLLocationCoordinate2D(latitude: 25.429647, longitude: -100.135626),
            CLLocationCoordinate2D(latitude: 25.427554, longitude: -100.125777),
            CLLocationCoordinate2D(latitude: 25.415164, longitude: -100.125744),
            CLLocationCoordinate2D(latitude: 25.399609, longitude: -100.118967),
            CLLocationCoordinate2D(latitude: 25.380704, longitude: -100.107255),
            CLLocationCoordinate2D(latitude: 25.364445, longitude: -100.096112),
            CLLocationCoordinate2D(latitude: 25.351142, longitude: -100.103551),
            CLLocationCoordinate2D(latitude: 25.361141, longitude: -100.112800),
            CLLocationCoordinate2D(latitude: 25.351427, longitude: -100.127049),
            CLLocationCoordinate2D(latitude: 25.367027, longitude: -100.150463),
            CLLocationCoordinate2D(latitude: 25.366172, longitude: -100.160918),
            CLLocationCoordinate2D(latitude: 25.396426, longitude: -100.167730),
            CLLocationCoordinate2D(latitude: 25.403435, longitude: -100.185507),
            CLLocationCoordinate2D(latitude: 25.420360, longitude: -100.184387),
            CLLocationCoordinate2D(latitude: 25.424391, longitude: -100.198500),
            CLLocationCoordinate2D(latitude: 25.430981, longitude: -100.196702),
            CLLocationCoordinate2D(latitude: 25.465584, longitude: -100.231684),
            CLLocationCoordinate2D(latitude: 25.479435, longitude: -100.226851),
            CLLocationCoordinate2D(latitude: 25.483282, longitude: -100.211555),
            CLLocationCoordinate2D(latitude: 25.481585, longitude: -100.191227),
            CLLocationCoordinate2D(latitude: 25.489394, longitude: -100.196779),
            CLLocationCoordinate2D(latitude: 25.497757, longitude: -100.200477),
            CLLocationCoordinate2D(latitude: 25.507231, longitude: -100.200485),
            CLLocationCoordinate2D(latitude: 25.513918, longitude: -100.206646),
            CLLocationCoordinate2D(latitude: 25.517256, longitude: -100.222647),
            CLLocationCoordinate2D(latitude: 25.511131, longitude: -100.233087),
            CLLocationCoordinate2D(latitude: 25.507793, longitude: -100.239215),
            CLLocationCoordinate2D(latitude: 25.522819, longitude: -100.236809),
            CLLocationCoordinate2D(latitude: 25.519482, longitude: -100.226960),
            CLLocationCoordinate2D(latitude: 25.521715, longitude: -100.214036),
            CLLocationCoordinate2D(latitude: 25.680144, longitude: -100.379055),
            CLLocationCoordinate2D(latitude: 25.694631, longitude: -100.383390),
            CLLocationCoordinate2D(latitude: 25.700967, longitude: -100.384080),
            CLLocationCoordinate2D(latitude: 25.709659, longitude: -100.386333),
            CLLocationCoordinate2D(latitude: 25.716610, longitude: -100.393694),
            CLLocationCoordinate2D(latitude: 25.722209, longitude: -100.404837),
            CLLocationCoordinate2D(latitude: 25.737213, longitude: -100.401000),
            CLLocationCoordinate2D(latitude: 25.727916, longitude: -100.411875),
            CLLocationCoordinate2D(latitude: 25.730121, longitude: -100.415378),
            CLLocationCoordinate2D(latitude: 25.746455, longitude: -100.413737),
            CLLocationCoordinate2D(latitude: 25.748695, longitude: -100.416931),
            CLLocationCoordinate2D(latitude: 25.735989, longitude: -100.421907),
            CLLocationCoordinate2D(latitude: 25.740071, longitude: -100.438648),
            CLLocationCoordinate2D(latitude: 25.751471, longitude: -100.443096),
            CLLocationCoordinate2D(latitude: 25.790879, longitude: -100.414793)  // Closing the polygon
        ]
        let polygon = MKPolygon(coordinates: monterreyCoordinates, count: monterreyCoordinates.count)
        mapView.addOverlay(polygon)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        
        // Agregar la ubicación del usuario como anotación si está disponible
        if let userLocation = userLocation {
            uiView.setCenter(userLocation, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygonOverlay = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygonOverlay)
                renderer.strokeColor = UIColor.systemBlue
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}





#Preview {
    NavigationView {
        LocationCheckView()
            .environmentObject(AuthState())
    }
}
