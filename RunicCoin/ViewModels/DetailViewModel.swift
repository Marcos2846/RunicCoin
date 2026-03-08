//
//  DetailViewModel.swift
//  RunicCoin
//
//  Created by Marcos Garcia on 04/03/26.
//

import Foundation
import Combine

@MainActor
final class DetailViewModel: ObservableObject {
    @Published var klineData: [KLineData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let networkService = BybitNetworkService()
    
    /// Llama al servicio de red para obtener el historial de precios (K-lines)
    func fetchHistoricalData(for symbol: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Solicitamos velas de 60 minutos (1 hora) y un límite de 24 (últimas 24 horas)
            let data = try await networkService.fetchKLines(symbol: symbol, interval: "60", limit: 24)
            self.klineData = data
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
