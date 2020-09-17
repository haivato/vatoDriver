//  File name   : Property.swift
//
//  Author      : Dung Vu
//  Created date: 1/2/20
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2020 Vato. All rights reserved.
//  --------------------------------------------------------------

import Foundation
import RxSwift
import RxCocoa

// MARK: - Thread safe
@propertyWrapper
struct ThreadSafe<T>: SafeAccessProtocol {
    let lock: NSRecursiveLock = NSRecursiveLock()
    var _value: T?
    var wrappedValue: T? {
        get {
            return excute { _value }
        }
        
        set {
            excute { _value = newValue }
        }
    }
}

// MARK: - Replay
@propertyWrapper
struct Replay<T> {
    private let _event: ReplaySubject<T>
    private let queue: ImmediateSchedulerType
    init(bufferSize: Int, queue: ImmediateSchedulerType) {
        self.queue = queue
        _event = ReplaySubject<T>.create(bufferSize: bufferSize)
    }
    
    init(queue: ImmediateSchedulerType) {
        self.queue = queue
       _event = ReplaySubject<T>.create(bufferSize: 1)
    }
    
    var wrappedValue: T {
        get {
            fatalError("Do not get value from this!!!!")
        }
        
        set {
            _event.onNext(newValue)
        }
    }
    
    var projectedValue: Observable<T> {
        return _event.observeOn(queue)
    }
}

// MARK: - BehaviorReplay
@propertyWrapper
struct VariableReplay<T> {
    private let replay: BehaviorRelay<T>
    
    init(wrappedValue: T) {
        replay = BehaviorRelay(value: wrappedValue)
    }
    
    var wrappedValue: T {
        get {
            return replay.value
        }
        
        set {
            replay.accept(newValue)
        }
    }
    
    var projectedValue: BehaviorRelay<T> {
        return replay
    }
}

// MARK: - Published
@propertyWrapper
struct Published<T> {
    private let subject: PublishSubject<T> = PublishSubject()
    var wrappedValue: T {
        get {
            fatalError("Do not get value from this!!!!")
        }
        
        set {
            subject.onNext(newValue)
        }
    }
    
    var projectedValue: PublishSubject<T> {
        return subject
    }
}

// MARK: - Expired
@propertyWrapper
struct Exprired<T> {
    private let timeExpired: TimeInterval
    private var date: Date
    init(wrappedValue: T, timeExpired: TimeInterval) {
        self.wrappedValue = wrappedValue
        self.timeExpired = timeExpired
        date = Date().addingTimeInterval(timeExpired)
    }
    
    var wrappedValue: T {
        didSet {
            date = Date().addingTimeInterval(timeExpired)
        }
    }
    
    var projectedValue: T? {
        guard date.timeIntervalSince(Date()) > 0 else {
            return nil
        }
        
        return wrappedValue
    }
}

// MARK: - Trim
@propertyWrapper
struct Trimmed {
    private(set) var value: String = ""

    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }
}

// MARK: - UserDefault
@propertyWrapper
struct LoadUserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: - Cache To File
@propertyWrapper
struct CacheFile<T> where T: Codable, T: Equatable {
    var fName: String = "" {
        didSet { load() }
    }
    @VariableReplay(wrappedValue: []) private var response: [T]
    private let cacheDocument = URL.cacheDirectory()
    
    init(fileName: String = "") {
        self.fName = fileName
        load()
    }
    
    var wrappedValue: [T] {
        get {
            return response
        }
        
        set {
            response = newValue
        }
    }
    
    var projectedValue: Observable<[T]> {
        return $response.asObservable()
    }
    
    private mutating func load() {
        guard !fName.isEmpty else { return }
        let fileManager = FileManager.default
        guard let url = cacheDocument?.appendingPathComponent(fName), fileManager.fileExists(url) else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let items = try [T].toModel(from: data)
            self.response = items
        } catch {
            assert(false, error.localizedDescription)
        }
    }
    
    public mutating func add(item: T?, clear: Bool = true) {
        guard let item = item else {
            return
        }
        
        guard !clear else {
            response = [item]
            return
        }

        var current = response
        if let idx = current.index(of: item) {
            current.remove(at: idx)
        }

        current.insert(item, at: 0)
        response = current
    }
    
    public func save() {
        guard let url = cacheDocument?.appendingPathComponent(fName) else {
            return
        }

        let items = response
        do {
            let data = try items.toData()
            try data.write(to: url)
        } catch {
            assert(false, error.localizedDescription)
        }
    }
}

