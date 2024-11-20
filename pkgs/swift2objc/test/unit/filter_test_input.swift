import Foundation

public struct Engine {
    public let type: String
    public let horsepower: Int
    
    public init(type: String, horsepower: Int) {
        self.type = type
        self.horsepower = horsepower
    }
    
    public func displaySpecs() {
        print("Engine: \(type), \(horsepower) HP")
    }
}


public struct Tire {
    public let brand: String
    public let size: Int
    
    public init(brand: String, size: Int) {
        self.brand = brand
        self.size = size
    }
    
    public func displayInfo() {
        print("Tire: \(brand), size \(size)")
    }
}


public struct Dimensions {
    public let length: Double
    public let width: Double
    public let height: Double
    
    public init(length: Double, width: Double, height: Double) {
        self.length = length
        self.width = width
        self.height = height
    }
    
    public func displayDimensions() {
        print("Dimensions (LxWxH): \(length) x \(width) x \(height) meters")
    }
}


public class Vehicle {
    public var make: String
    public var model: String
    public var engine: Engine
    public var dimensions: Dimensions
    
    public init(make: String, model: String, engine: Engine, dimensions: Dimensions) {
        self.make = make
        self.model = model
        self.engine = engine
        self.dimensions = dimensions
    }
    
    public func displayInfo() {
        print("Vehicle: \(make) \(model)")
        engine.displaySpecs()
        dimensions.displayDimensions()
    }
}


public class Car: Vehicle {
    public var numberOfDoors: Int
    public var tires: [Tire]
    
    public init(make: String, model: String, engine: Engine, dimensions: Dimensions, numberOfDoors: Int, tires: [Tire]) {
        self.numberOfDoors = numberOfDoors
        self.tires = tires
        super.init(make: make, model: model, engine: engine, dimensions: dimensions)
    }
    
    public func honk() {
        print("Car \(make) \(model) goes 'Beep Beep!'")
    }
}


public class ElectricCar: Car {
    public var batteryCapacity: Int // in kWh
    
    public init(make: String, model: String, dimensions: Dimensions, numberOfDoors: Int, tires: [Tire], batteryCapacity: Int) {
        self.batteryCapacity = batteryCapacity
        let electricEngine = Engine(type: "Electric", horsepower: batteryCapacity * 3) // Example calculation
        super.init(make: make, model: model, engine: electricEngine, dimensions: dimensions, numberOfDoors: numberOfDoors, tires: tires)
    }
    
    public func chargeBattery() {
        print("Charging \(make) \(model)... Battery capacity: \(batteryCapacity) kWh")
    }
}

public class Bicycle {
    public var brand: String
    public var gearCount: Int
    public var dimensions: Dimensions
    
    public init(brand: String, gearCount: Int, dimensions: Dimensions) {
        self.brand = brand
        self.gearCount = gearCount
        self.dimensions = dimensions
    }
    
    public func pedal() {
        print("\(brand) bicycle is pedaling with \(gearCount) gears.")
        dimensions.displayDimensions()
    }
}


public class Garage {
    private var vehicles: [Vehicle] = []
    
    public init() {}
    
    public func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        print("Added \(vehicle.make) \(vehicle.model) to the garage.")
    }
    
    public func listVehicles() {
        print("Garage contains:")
        for vehicle in vehicles {
            print("- \(vehicle.make) \(vehicle.model)")
        }
    }
}
