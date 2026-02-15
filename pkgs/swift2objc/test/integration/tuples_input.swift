// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test simple tuple return
public class TupleTest {
    public func getCoordinates() -> (Int, Int) {
        return (10, 20)
    }
    
    public func getLabeledTuple() -> (id: Int, name: String) {
        return (id: 42, name: "Alice")
    }
    
    public func getMixedTuple() -> (Int, value: String, Bool) {
        return (1, value: "test", true)
    }
    
    // Tuple with optional elements
    public func getTupleWithOptionals() -> (Int?, String?) {
        return (nil, "test")
    }
    
    // Deeply nested tuple (3 levels)
    public func getDeeplyNestedTuple() -> (Int, (String, (Bool, Double))) {
        return (1, ("test", (true, 3.14)))
    }
    
    // Large tuple with many elements
    public func getLargeTuple() -> (Int, Int, Int, Int, Int) {
        return (1, 2, 3, 4, 5)
    }
    
    // All labeled elements
    public func getAllLabeledTuple() -> (x: Int, y: Int, z: String) {
        return (x: 10, y: 20, z: "point")
    }
    
    public class NestedTupleTest {
    public func getNestedTuple() -> (Int, (String, Bool)) {
        return (42, ("test", true))
    }
}

public class OptionalTupleTest {
    public func getOptionalTuple() -> (Int, String)? {
        return (1, "test")
    }
    
    // Optional nested tuple
    public func getOptionalNestedTuple() -> (Int, (String, Bool)?) {
        return (42, nil)
    }
}
}