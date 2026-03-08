//
//  ContentView.swift
//  RunicCoin
//
//  Created by Marcos Garcia on 04/03/26.
//

import SwiftUI

struct ContentView: View {
    // 1. Instanciamos nuestro ViewModel usando @StateObject para que la vista sea dueña de este objeto.
    @StateObject private var viewModel = CryptoViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                // 2. Manejamos el estado "Cargando"
                if viewModel.isLoading {
                    ProgressView("Cargando criptomonedas...")
                        .scaleEffect(1.2)
                }
                // 3. Manejamos el estado de "Error"
                else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        
                        Text("Hubo un problema:")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Reintentar") {
                            // Volvemos a lanzar la petición si hay error
                            Task {
                                await viewModel.fetchCoins()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                // 4. Manejamos el estado de "Éxito" mostrando la lista de monedas
                else {
                    List(viewModel.publicCoins) { coin in
                        // Envolvemos cada fila en un NavigationLink hacia DetailView. Pasamos la moneda entera.
                        NavigationLink(value: coin) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(coin.symbol)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("$\(coin.currentPrice, specifier: "%.4f")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    // Pintamos de verde si subió, rojo si bajó
                                    Text("\(coin.priceChangePercentage, specifier: "%.2f")%")
                                        .font(.caption)
                                        .foregroundColor(coin.priceChangePercentage >= 0 ? .green : .red)
                                }
                            }
                        }
                    }
                    // Agregamos Pull-to-Refresh nativo de iOS
                    .refreshable {
                        await viewModel.fetchCoins()
                    }
                    // Definimos a dónde nos lleva el NavigationLink cuando pasamos un valor de tipo CoinTicker
                    .navigationDestination(for: CoinTicker.self) { coin in
                        DetailView(coin: coin)
                    }
                }
            }
            .navigationTitle("RunicCoin")
        }
        // 5. Llamamos a nuestra red la primera vez que la vista aparece
        .task {
            // .task corre automáticamente de forma asíncrona cuando la vista aparece
            if viewModel.publicCoins.isEmpty {
                await viewModel.fetchCoins()
            }
        }
    }
}

#Preview {
    ContentView()
}
