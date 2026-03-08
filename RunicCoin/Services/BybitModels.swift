import Foundation

// MARK: - Bybit Spot V5 Models

/// Top-level response from Bybit `/v5/market/tickers`
struct BybitResponse: Codable {
    let retCode: Int
    let retMsg: String
    let result: BybitResult
}

/// The `result` container holding a list of tickers
struct BybitResult: Codable {
    let list: [CoinTicker]
}

/// Represents a single ticker entry for a trading pair (e.g., BTCUSDT)
/// Bybit commonly returns numeric values as strings.
struct CoinTicker: Codable {
    let symbol: String
    let lastPrice: String?
    let highPrice24h: String?
    let lowPrice24h: String?
    let volume24h: String?
    let turnover24h: String?
    let price24hPcnt: String?
    let usdIndexPrice: String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case lastPrice
        case highPrice24h
        case lowPrice24h
        case volume24h
        case turnover24h
        case price24hPcnt
        case usdIndexPrice
    }
}
