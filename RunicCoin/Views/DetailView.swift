import SwiftUI
import Charts // Framework nativo de Apple para gráficos

struct DetailView: View {
    // La moneda seleccionada en la vista anterior
    let coin: CoinTicker
    
    // El ViewModel exclusivo para esta vista (trae el historial)
    @StateObject private var viewModel = DetailViewModel()
    
    // Estado para controlar cuándo mostramos el modal de compra (Paso 3)
    @State private var showingPurchaseModal = false
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Header (Precio Actual)
            VStack(spacing: 8) {
                Text("$\(coin.currentPrice, specifier: "%.4f")")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                
                Text("\(coin.priceChangePercentage >= 0 ? "+" : "")\(coin.priceChangePercentage, specifier: "%.2f")% en 24h")
                    .font(.headline)
                    .foregroundColor(coin.priceChangePercentage >= 0 ? .green : .red)
            }
            .padding(.top)
            
            // MARK: - Gráfico (K-Line)
            VStack(alignment: .leading) {
                Text("Últimas 24 Horas")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if viewModel.isLoading {
                    // Muestra spinner mientras carga
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                } else if let errorMessage = viewModel.errorMessage {
                    // Muestra error
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                } else {
                    // Dibuja el gráfico usando la data histórica
                    Chart(viewModel.klineData) { dataPoint in
                        LineMark(
                            x: .value("Hora", dataPoint.timestamp),
                            y: .value("Precio", dataPoint.close)
                        )
                        .foregroundStyle(coin.priceChangePercentage >= 0 ? Color.green.gradient : Color.red.gradient)
                        .interpolationMethod(.monotone) // Suaviza la línea
                    }
                    .frame(height: 250)
                    .chartXAxis {
                        // Formateamos el eje X para que solo muestre la hora
                        AxisMarks(values: .stride(by: .hour, count: 4)) { value in
                            AxisGridLine()
                            AxisTick()
                            if let date = value.as(Date.self) {
                                AxisValueLabel(format: .dateTime.hour())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Botón de Compra
            Button {
                showingPurchaseModal = true
            } label: {
                Text("Comprar \(coin.symbol.replacingOccurrences(of: "USDT", with: ""))")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle(coin.symbol)
        .navigationBarTitleDisplayMode(.inline)
        // Dispara la llamada a la red al aparecer la vista
        .task {
            await viewModel.fetchHistoricalData(for: coin.symbol)
        }
        // Configura el modal (sheet) que construiremos en el Paso 3
        .sheet(isPresented: $showingPurchaseModal) {
            PurchaseView(coin: coin)
        }
    }
}

// Mock de Preview
#Preview {
    NavigationStack {
        DetailView(coin: CoinTicker(symbol: "BTCUSDT", lastPrice: "65000.50", price24hPcnt: "0.05"))
    }
}
