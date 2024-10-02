//
//  Case.swift
//  BufeTec
//
//  Created by Sofia Sandoval on 10/1/24.
//

import Foundation

struct Case: Identifiable, Codable {
    let id: String
    let tipo_de_caso: String
    let cliente_id: String
    let abogados_becarios_id: [String]
    let estado: String
    let fecha_inicio: String
    let fecha_cierre: String?
    let documentos: [Documento]
    let actualizaciones: [Actualizacion]
    let descripcion: String
    let notas: String

    enum CodingKeys: String, CodingKey {
        case id
        case tipo_de_caso
        case cliente_id
        case abogados_becarios_id
        case estado
        case fecha_inicio
        case fecha_cierre
        case documentos
        case actualizaciones
        case descripcion
        case notas
    }
}

struct Documento: Codable {
    let nombre: String
    let url: String
}

struct Actualizacion: Codable {
    let fecha: String
    let descripcion: String
}
