import Foundation
import Combine // Necesario para 'ObservableObject' y '@Published'

// MARK: - Crypto ViewModel
/// El ViewModel es el puente entre nuestra Vista y nuestros Datos.
/// Conforma a 'ObservableObject' para que SwiftUI pueda "suscribirse" a sus cambios.
@MainActor // Asegura que todas las actualizaciones a la UI ocurran en el hilo principal
final class CryptoViewModel: ObservableObject {
    
    // MARK: - Variables de Estado (@Published)
    
    /// La lista de monedas que se mostrarán en la UI.
    /// '@Published' le dice a SwiftUI: "Cada vez que esta variable cambie, vuelve a dibujar la pantalla."
    @Published var publicCoins: [CoinTicker] = []
    
    /// Un indicador para mostrar un 'Spinner' (rueda giratoria) mientras cargamos los datos.
    @Published var isLoading: Bool = false
    
    /// Un mensaje de error para mostrar al usuario si la solicitud falla.
    @Published var errorMessage: String? = nil
    
    // MARK: - Dependencias
    
    /// Inyectamos nuestro servicio de red en el modelo.
    /// Usamos una propiedad privada para que la Vista no acceda a la red directamente.
    private let networkService = BybitNetworkService()
    
    // MARK: - Acciones Públicas (Intents)
    
    /// Llama al servicio de red para actualizar las monedas.
    func fetchCoins() async {
        // 1. Iniciamos la carga
        isLoading = true
        errorMessage = nil
        
        // 2. Intentamos realizar la petición a la red
        do {
            // Obtenemos los datos de la red. La ejecución se suspende aquí hasta que terminen
            let fetchedCoins = try await networkService.fetchCryptoData()
            
            // Si tiene éxito, actualizamos la información que ve la UI
            self.publicCoins = fetchedCoins
            
        } catch {
            // Si falla, atrapamos el error y exponemos el mensaje a la UI
            self.errorMessage = error.localizedDescription
        }
        
        // 3. Ya sea que falle o tenga éxito, apagamos la bandera de carga
        isLoading = false
    }
}
