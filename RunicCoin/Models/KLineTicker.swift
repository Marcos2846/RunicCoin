//
//  KLineTicker.swift
//  RunicCoin
//
//  Created by Marcos Garcia on 04/03/26.
//

import Foundation

// MARK: - Bybit KLine Response
/// Estructura base para el endpoint KLine
struct KLineResponse: Decodable {
    let retCode: Int
    let retMsg: String
    let result: KLineResult
}

// MARK: - Bybit KLine Result
struct KLineResult: Decodable {
    let symbol: String
    let category: String
    let list: [[String]] // Bybit devuelve un arreglo de arreglos de strings
}

// MARK: - Parsed KLine Data Model
/// Nuestro modelo procesado para usar en Swift Charts
struct KLineData: Identifiable {
    let id = UUID() // Necesario para iterar en Swift Charts
    let timestamp: Date // El tiempo real
    let open: Double
    let high: Double
    let low: Double
    let close: Double
}
