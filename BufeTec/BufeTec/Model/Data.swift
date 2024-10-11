//  Data.swift
//  ForumTest
//
//  Created by Ximena Tobias on 21/09/24.
//

import Foundation
// MARK: - BecarioInformationElement
struct BecarioInformationElement: Codable {
    let id, nombre, correo, rol: String

    enum CodingKeys: String, CodingKey {
        case id, nombre, correo, rol
    }
}

typealias BecarioInformation = [BecarioInformationElement]
// MARK: - LawyerInformationElement
struct LawyerInformationElement: Codable {
    let id, nombre: String
    let correo, telefono, rol, areaEspecializacion, cedula, estadoCuenta: String?
    let horariosAtencion: HorariosAtencion?

    enum CodingKeys: String, CodingKey {
        case id
        case nombre, correo, telefono, rol, cedula
        case areaEspecializacion = "area_especializacion"
        case horariosAtencion = "horarios_atencion"
        case estadoCuenta = "estado_cuenta"
    }
}

typealias LawyerInformation = [LawyerInformationElement]


// MARK: - ClientInformationElement
struct ClientInformationElement: Codable {
    let id, nombre, numeroTelefonico, rol: String
    let correo, expediente, juzgado, seguimiento, alumno, folio: String?
    let ultimaVezInf: Date?


    enum CodingKeys: String, CodingKey {
        case id
        case nombre
        case numeroTelefonico = "numero_telefonico"
        case correo, expediente, juzgado, seguimiento, alumno, folio, ultimaVezInf, rol
    }
}

typealias ClientInformation = [ClientInformationElement]


// MARK: - UserInformationElement
struct UserInformationElement: Codable {
    let id: ID
    let userInformationID, nombre, correo: String
    let telefono, rol, areaEspecializacion, cedula: String
    let horariosAtencion: HorariosAtencion?
    let estadoCuenta: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userInformationID = "id"
        case nombre, correo, telefono, rol
        case areaEspecializacion = "area_especializacion"
        case cedula
        case horariosAtencion = "horarios_atencion"
        case estadoCuenta = "estado_cuenta"
    }
}

// MARK: - HorariosAtencion
struct HorariosAtencion: Codable {
    let lunes, martes, miércoles, jueves: [String]?
}

// MARK: - ID
struct ID: Codable {
    let oid: String

    enum CodingKeys: String, CodingKey {
        case oid = "$oid"
    }
}

typealias UserInformation = [UserInformationElement]

/*struct UserInformationElement: Codable {
    let apellido, areaEspecializacion: JSONNull?
    let casosAsignados: [JSONAny]
    let cedula: JSONNull?
    let correo: String
    let horariosAtencion: HorariosAtencion
    let id, nombre, rol: String
    let telefono: JSONNull?

    enum CodingKeys: String, CodingKey {
        case apellido
        case areaEspecializacion = "area_especializacion"
        case casosAsignados = "casos_asignados"
        case cedula, correo
        case horariosAtencion = "horarios_atencion"
        case id, nombre, rol, telefono
    }
}*/

// MARK: - ForumResponses
struct WelcomeElement: Codable {
    let autorID, contenido, fechaCreacion, id: String
    let readUsers: [JSONAny]
    let respuestas: [Respuesta]
    let titulo: String

    enum CodingKeys: String, CodingKey {
        case autorID = "autor_id"
        case contenido
        case fechaCreacion = "fecha_creacion"
        case id
        case readUsers = "read_users"
        case respuestas, titulo
    }
}

// MARK: - Respuesta
struct Respuesta: Codable {
    let autorID: String
    let comentarios: [JSONAny]
    let contenido, fechaCreacion, respuestaID: String

    enum CodingKeys: String, CodingKey {
        case autorID = "autor_id"
        case comentarios, contenido
        case fechaCreacion = "fecha_creacion"
        case respuestaID = "respuesta_id"
    }
}

typealias Welcome = [WelcomeElement]

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
            return nil
    }

    required init?(stringValue: String) {
            key = stringValue
    }

    var intValue: Int? {
            return nil
    }

    var stringValue: String {
            return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
            return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
            return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                    return value
            }
            if let value = try? container.decode(Int64.self) {
                    return value
            }
            if let value = try? container.decode(Double.self) {
                    return value
            }
            if let value = try? container.decode(String.self) {
                    return value
            }
            if container.decodeNil() {
                    return JSONNull()
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                    return value
            }
            if let value = try? container.decode(Int64.self) {
                    return value
            }
            if let value = try? container.decode(Double.self) {
                    return value
            }
            if let value = try? container.decode(String.self) {
                    return value
            }
            if let value = try? container.decodeNil() {
                    if value {
                            return JSONNull()
                    }
            }
            if var container = try? container.nestedUnkeyedContainer() {
                    return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                    return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
            if let value = try? container.decode(Bool.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(Int64.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(Double.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(String.self, forKey: key) {
                    return value
            }
            if let value = try? container.decodeNil(forKey: key) {
                    if value {
                            return JSONNull()
                    }
            }
            if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                    return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                    return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
            var arr: [Any] = []
            while !container.isAtEnd {
                    let value = try decode(from: &container)
                    arr.append(value)
            }
            return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
            var dict = [String: Any]()
            for key in container.allKeys {
                    let value = try decode(from: &container, forKey: key)
                    dict[key.stringValue] = value
            }
            return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
            for value in array {
                    if let value = value as? Bool {
                            try container.encode(value)
                    } else if let value = value as? Int64 {
                            try container.encode(value)
                    } else if let value = value as? Double {
                            try container.encode(value)
                    } else if let value = value as? String {
                            try container.encode(value)
                    } else if value is JSONNull {
                            try container.encodeNil()
                    } else if let value = value as? [Any] {
                            var container = container.nestedUnkeyedContainer()
                            try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                            try encode(to: &container, dictionary: value)
                    } else {
                            throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
            }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
            for (key, value) in dictionary {
                    let key = JSONCodingKey(stringValue: key)!
                    if let value = value as? Bool {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? Int64 {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? Double {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? String {
                            try container.encode(value, forKey: key)
                    } else if value is JSONNull {
                            try container.encodeNil(forKey: key)
                    } else if let value = value as? [Any] {
                            var container = container.nestedUnkeyedContainer(forKey: key)
                            try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                            try encode(to: &container, dictionary: value)
                    } else {
                            throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
            }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
            if let value = value as? Bool {
                    try container.encode(value)
            } else if let value = value as? Int64 {
                    try container.encode(value)
            } else if let value = value as? Double {
                    try container.encode(value)
            } else if let value = value as? String {
                    try container.encode(value)
            } else if value is JSONNull {
                    try container.encodeNil()
            } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
            }
    }

    public required init(from decoder: Decoder) throws {
            if var arrayContainer = try? decoder.unkeyedContainer() {
                    self.value = try JSONAny.decodeArray(from: &arrayContainer)
            } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                    self.value = try JSONAny.decodeDictionary(from: &container)
            } else {
                    let container = try decoder.singleValueContainer()
                    self.value = try JSONAny.decode(from: container)
            }
    }

    public func encode(to encoder: Encoder) throws {
            if let arr = self.value as? [Any] {
                    var container = encoder.unkeyedContainer()
                    try JSONAny.encode(to: &container, array: arr)
            } else if let dict = self.value as? [String: Any] {
                    var container = encoder.container(keyedBy: JSONCodingKey.self)
                    try JSONAny.encode(to: &container, dictionary: dict)
            } else {
                    var container = encoder.singleValueContainer()
                    try JSONAny.encode(to: &container, value: self.value)
            }
    }
}

