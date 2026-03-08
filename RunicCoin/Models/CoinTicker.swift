import Foundation

// MARK: - Bybit Base Response
/// Esta estructura envuelve la respuesta general de Bybit
struct BybitResponse: Decodable {
    let retCode: Int
    let retMsg: String
    let result: BybitResult
}

// MARK: - Bybit Result
/// Contiene la lista de monedas
struct BybitResult: Decodable {
    let list: [CoinTicker]
}

// MARK: - Coin Ticker Model
/// Nuestro modelo principal. Conforma a Identifiable y Hashable para usar en List y NavigationStack.
struct CoinTicker: Decodable, Identifiable, Hashable {

    var id: String { symbol }
    
    let symbol: String
    let lastPrice: String
    let price24hPcnt: String
    
    // MARK: - Computed Properties (Manejo de Strings a Números)
    
    /// Convertimos el precio de String a Double de forma segura
    var currentPrice: Double {
        Double(lastPrice) ?? 0.0
    }
    
    /// Convertimos el porcentaje de cambio para saber si es positivo o negativo
    /// Multiplicamos por 100 porque Bybit devuelve, por ejemplo, "0.05" para referirse a un 5%
    var priceChangePercentage: Double {
        (Double(price24hPcnt) ?? 0.0) * 100
    }
}
