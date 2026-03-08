//
//  BybitNetworkService.swift
//  RunicCoin
//
//  Created by Marcos Garcia on 04/03/26.
//
import Foundation

// MARK: - API Error Handling
/// Un Enum limpio para manejar nuestros errores de forma predecible
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "La URL proporcionada no es válida."
        case .invalidResponse: return "El servidor devolvió una respuesta inesperada."
        case .decodingError(let error): return "Error al procesar los datos de Bybit: \(error.localizedDescription)"
        }
    }
}

// MARK: - Network Service
final class BybitNetworkService {
    
    // El endpoint público de Spot V5
    private let endpoint = "https://api.bybit.com/v5/market/tickers?category=spot"
    
    // Las únicas monedas que nos interesan (formato de Bybit: Moneda + USDT)
    private let targetSymbols = ["BTCUSDT", "ETHUSDT", "BNBUSDT", "SOLUSDT"]

    /// Obtiene los tickers, los decodifica y filtra solo los 4 principales
    /// - Returns: Un arreglo de [CoinTicker]
    func fetchCryptoData() async throws -> [CoinTicker] {
        // 1. Validar la URL
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        // 2. Realizar la petición asíncrona
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Validar que la respuesta sea un código HTTP 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // 4. Decodificar el JSON
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(BybitResponse.self, from: data)
            
            // 5. Filtrar el arreglo gigante para quedarnos SOLO con nuestras 4 monedas
            let allTickers = decodedResponse.result.list
            let filteredTickers = allTickers.filter { ticker in
                targetSymbols.contains(ticker.symbol)
            }
            
            // (Opcional) Ordenar las monedas en el mismo orden que 'targetSymbols'
            let sortedTickers = filteredTickers.sorted { a, b in
                guard let indexA = targetSymbols.firstIndex(of: a.symbol),
                      let indexB = targetSymbols.firstIndex(of: b.symbol) else {
                    return false
                }
                return indexA < indexB
            }
            
            return sortedTickers
            
        } catch {
            // Si el JSON falla (ej. Bybit cambió la estructura de su API)
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - K-Line Data Fetching
    /// Obtiene los datos históricos (velas) de una moneda
    func fetchKLines(symbol: String, interval: String = "60", limit: Int = 24) async throws -> [KLineData] {
        let klineEndpoint = "https://api.bybit.com/v5/market/kline?category=spot&symbol=\(symbol)&interval=\(interval)&limit=\(limit)"
        
        guard let url = URL(string: klineEndpoint) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(KLineResponse.self, from: data)
            
            // Bybit devuelve los más recientes primero. Opcionalmente los invertimos para el gráfico
            let rawList = decodedResponse.result.list.reversed()
            
            // Mapeamos el arreglo de strings a nuestra estructura KLineData
            let klineDataArray: [KLineData] = rawList.compactMap { stringArray in
                // Bybit formato: [startTime, openPrice, highPrice, lowPrice, closePrice, volume, turnover]
                guard stringArray.count >= 5,
                      let timestampDouble = Double(stringArray[0]),
                      let open = Double(stringArray[1]),
                      let high = Double(stringArray[2]),
                      let low = Double(stringArray[3]),
                      let close = Double(stringArray[4]) else {
                    return nil // Ignoramos si la data viene incompleta
                }
                
                // Bybit devuelve el timestamp en milisegundos
                let date = Date(timeIntervalSince1970: timestampDouble / 1000.0)
                
                return KLineData(timestamp: date, open: open, high: high, low: low, close: close)
            }
            
            return klineDataArray
            
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
