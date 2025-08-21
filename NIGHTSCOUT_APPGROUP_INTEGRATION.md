# Nightscout App Group Integration for Loop

## Описание

Этот проект добавляет возможность использования App Group данных (например, из xDrip4iOS) вместе с Nightscout в Loop. Пользователь может переключаться между источниками глюкозы через настройки.

## Изменения

### 1. NightscoutRemoteCGM Settings (SettingsView.swift)

Добавлен переключатель в настройки NightscoutRemoteCGM:

```swift
Section(header: Text("Glucose Source Options")) {
    Toggle("Use App Group alongside Nightscout", isOn: Binding(
        get: { viewModel.useAppGroupWithNightscout },
        set: { newValue in
            viewModel.useAppGroupWithNightscout = newValue
            UserDefaults.standard.set(newValue, forKey: "useAppGroupWithNightscout")
            viewModel.updateGlucoseSource()
        }
    ))
}
```

### 2. NightscoutRemoteCGM Logic (NightscoutRemoteCGM.swift)

Модифицирован метод `fetchNewDataIfNeeded` для поддержки двух источников данных:

- **App Group**: Читает данные из xDrip4iOS через App Group
- **Nightscout**: Использует оригинальную логику Nightscout

```swift
public func fetchNewDataIfNeeded(_ completion: @escaping (CGMReadingResult) -> Void) {
    // Check if we should use App Group data instead of Nightscout
    let useAppGroup = UserDefaults.standard.bool(forKey: "useAppGroupWithNightscout")
    
    if useAppGroup {
        // Try to get data from App Group (xDrip)
        fetchFromAppGroup(completion: completion)
        return
    }
    
    // Use Nightscout as before
    fetchFromNightscout(completion: completion)
}
```

### 3. DeviceDataManager Integration (DeviceDataManager.swift)

Добавлена поддержка уведомлений для обновления источника глюкозы:

```swift
// Add observer for glucose source updates
NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateGlucoseSource"), object: nil, queue: nil) { [weak self] _ in
    DispatchQueue.main.async {
        self?.updateGlucoseSource()
    }
}
```

## Использование

1. **Настройка NightscoutRemoteCGM**: Настройте NightscoutRemoteCGM как обычно
2. **Включение App Group**: В настройках NightscoutRemoteCGM включите переключатель "Use App Group alongside Nightscout"
3. **Автоматическое переключение**: Loop будет автоматически использовать данные из App Group (xDrip4iOS) вместо Nightscout

## Требования

- xDrip4iOS должен быть настроен и передавать данные в App Group
- App Group должен быть настроен в проекте Loop
- NightscoutRemoteCGM должен быть установлен

## Fallback Logic

Если данные App Group недоступны или повреждены, система автоматически переключается на Nightscout как резервный источник.

## Совместимость

- Loop 3.x
- xDrip4iOS
- NightscoutRemoteCGM

## Примечания

- Переключение происходит в реальном времени
- Настройка сохраняется в UserDefaults
- Система автоматически обрабатывает ошибки и переключается на резервный источник
