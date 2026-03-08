import SwiftUI

struct PurchaseView: View {
    let coin: CoinTicker
    
    // Regresamos al DetailView cuando se realiza la compra
    @Environment(\.dismiss) private var dismiss
    
    // Variables de estado del input del usuario
    @State private var amountString: String = ""
    @State private var showingAlert = false
    
    // Calculamos el costo total sobre la marcha
    var totalCost: Double {
        let amount = Double(amountString) ?? 0.0
        return amount * coin.currentPrice
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header del activo
                HStack {
                    Text("Comprar")
                        .font(.title2)
                    Text(coin.symbol.replacingOccurrences(of: "USDT", with: ""))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                Text("Precio actual: $\(coin.currentPrice, specifier: "%.4f")")
                    .foregroundColor(.secondary)
                
                // Input Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cantidad")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("0.0", text: $amountString)
                        .keyboardType(.decimalPad) // Teclado numérico
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Total Summary
                HStack {
                    Text("Total Estimado:")
                        .font(.headline)
                    Spacer()
                    Text("$\(totalCost, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Botón de Confirmar
                Button {
                    // Al tocar, lanzamos la alerta de confirmación
                    showingAlert = true
                } label: {
                    Text("Confirmar Compra")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(amountString.isEmpty || totalCost <= 0 ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(amountString.isEmpty || totalCost <= 0) // Deshabilitado si no hay cantidad
                .padding()
            }
            .navigationTitle("Orden de Mercado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("¡Compra Exitosa!", isPresented: $showingAlert) {
                Button("OK") {
                    // Cuando le da OK a la alerta, cerramos el modal
                    dismiss()
                }
            } message: {
                Text("Has comprado \(amountString) \(coin.symbol.replacingOccurrences(of: "USDT", with: "")) por $\(totalCost, specifier: "%.2f").")
            }
        }
    }
}

#Preview {
    PurchaseView(coin: CoinTicker(symbol: "BTCUSDT", lastPrice: "65000.50", price24hPcnt: "0.05"))
}
