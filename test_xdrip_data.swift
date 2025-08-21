#!/usr/bin/env swift

import Foundation

// Создаем тестовые данные для xDrip в формате App Group
func createTestXDripData() -> Data? {
    let testReading = [
        "from": "xDrip",
        "Value": 120.0,
        "Trend": 4, // Flat trend
        "DT": "2025-08-22T00:20:00.000Z"
    ] as [String: Any]
    
    let testReadings = [testReading]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: testReadings, options: [])
        return jsonData
    } catch {
        print("Error creating test data: \(error)")
        return nil
    }
}

// Записываем тестовые данные в App Group
func writeTestDataToAppGroup() {
    guard let testData = createTestXDripData() else {
        print("Failed to create test data")
        return
    }
    
    // Используем тот же App Group Identifier, что и в приложении
    let appGroupIdentifier = "group.ru.zamot.freeeapsx"
    
    guard let sharedUserDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
        print("Failed to access App Group: \(appGroupIdentifier)")
        return
    }
    
    sharedUserDefaults.set(testData, forKey: "latestReadings")
    sharedUserDefaults.synchronize()
    
    print("Test data written to App Group successfully!")
    print("Data size: \(testData.count) bytes")
    print("App Group: \(appGroupIdentifier)")
}

print("Writing test xDrip data to App Group...")
writeTestDataToAppGroup()
print("Done!")
