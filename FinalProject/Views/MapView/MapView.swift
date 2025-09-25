import SwiftUI
import MapKit

struct MapView: View {
    let coordinate: CLLocationCoordinate2D
    
    @State private var position: MapCameraPosition
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        _position = State(initialValue: .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            )
        ))
    }
    
    var body: some View {
        Map(position: $position) {
            Marker("Capital", coordinate: coordinate)
                .tint(.red)
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
    }
}
