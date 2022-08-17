//
//  PropertyWrappers.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 16.06.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation

@propertyWrapper
struct RawRepresentableStorage<T: RawRepresentable> {
    private let objectName: String
    private let defaultValue: T
    private let defaults: UserDefaults
    
    init(_ objectName: String, defaultValue: T, defaults: UserDefaults = .standard) {
        self.objectName = objectName
        self.defaultValue = defaultValue
        self.defaults = defaults
    }
    
    var wrappedValue: T {
        get {
            guard let object = self.defaults.object(forKey: self.objectName) as? T.RawValue else {
                return self.defaultValue
            }
            
            return T(rawValue: object) ?? self.defaultValue
        }
        set {
            self.defaults.set(newValue.rawValue, forKey: self.objectName)
        }
    }
}

@propertyWrapper
struct StorageCodable<T: Codable> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }

            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                let data = try? JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
    
    init(wrappedValue defaultValue: T, key: String) {
        self.defaultValue = defaultValue
        self.key = key
    }
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

extension StorageCodable where T: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(wrappedValue: nil, key: key)
    }
}


private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

//unused wrapper
@propertyWrapper
struct StorageOptional<T> {
    private let key: String
    private let defaultValue: T

    var wrappedValue: T {
        get {
            guard let value = UserDefaults.standard.value(forKey: key) as? T else {
                return defaultValue
            }

            return value
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                UserDefaults.standard.setValue(newValue, forKey: key)
            }
        }
    }
    
    init(wrappedValue defaultValue: T, key: String) {
        self.defaultValue = defaultValue
        self.key = key
    }
}

extension StorageOptional where T: ExpressibleByNilLiteral {
    init(key: String) {
        self.init(wrappedValue: nil, key: key)
    }
}
