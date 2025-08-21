# Инструкции по тестированию App Group интеграции

## Что было реализовано

1. **Переключатель в настройках NightscoutRemoteCGM**: Пользователь может включить/выключить использование App Group данных
2. **Логика переключения**: Когда включено, система пытается получить данные из xDrip4iOS через App Group
3. **Fallback логика**: Если App Group данные недоступны, автоматически переключается на Nightscout

## Как протестировать

### 1. Проверка UI
1. Откройте Loop
2. Перейдите в настройки CGM
3. Выберите NightscoutRemoteCGM
4. Должен появиться переключатель "Use App Group alongside Nightscout"

### 2. Проверка логирования
После добавления логирования, в консоли должны появиться сообщения:
- `NightscoutRemoteCGM: useAppGroup = true/false`
- `NightscoutRemoteCGM: Using App Group data` (если включено)
- `NightscoutRemoteCGM: Using Nightscout data` (если выключено)
- `NightscoutRemoteCGM: Attempting to fetch from App Group` (при попытке получить данные из App Group)
- `NightscoutRemoteCGM: App Group data not available, falling back to Nightscout` (если данные недоступны)

### 3. Проверка работы
1. Включите переключатель "Use App Group alongside Nightscout"
2. Проверьте логи в консоли
3. Если App Group данные недоступны, система должна автоматически переключиться на Nightscout
4. Выключите переключатель и убедитесь, что система использует только Nightscout

## Возможные проблемы

1. **App Group Identifier не найден**: Проверьте, что в Info.plist есть ключ "AppGroupIdentifier"
2. **Shared UserDefaults недоступны**: Проверьте настройки App Group в проекте
3. **Данные xDrip4iOS недоступны**: Убедитесь, что xDrip4iOS настроен для записи данных в App Group

## Ожидаемое поведение

- Когда переключатель **выключен**: Используется только Nightscout
- Когда переключатель **включен**: 
  - Сначала пытается получить данные из xDrip4iOS через App Group
  - Если данные недоступны, автоматически переключается на Nightscout
  - Если данные доступны, использует их

## Логи для отладки

Добавлены следующие логи:
- `NightscoutRemoteCGM: useAppGroup = [true/false]`
- `NightscoutRemoteCGM: Using App Group data`
- `NightscoutRemoteCGM: Using Nightscout data`
- `NightscoutRemoteCGM: Attempting to fetch from App Group`
- `NightscoutRemoteCGM: AppGroupIdentifier found: [identifier]`
- `NightscoutRemoteCGM: SharedUserDefaults created successfully`
- `NightscoutRemoteCGM: Found latestReadings data: [X] bytes`
- `NightscoutRemoteCGM: Successfully decoded [X] readings`
- `NightscoutRemoteCGM: Processing [X] readings from App Group`
- `NightscoutRemoteCGM: Returning .newData with [X] readings` или `NightscoutRemoteCGM: Returning .noData (no new readings)`

## Исправления

✅ **Убраны все fallback'и к Nightscout** - теперь App Group работает изолированно
✅ **Добавлена защита от EXC_BREAKPOINT** - добавлены try-catch блоки и проверки nil
✅ **Детальное логирование** - каждый шаг процесса логируется

## Создание тестовых данных

Для тестирования создан скрипт `test_xdrip_data.swift` который записывает тестовые данные в App Group:

```bash
swift test_xdrip_data.swift
```

Этот скрипт создает тестовое чтение глюкозы со значением 120 mg/dL в формате xDrip.

## 🔍 Диагностика проблемы с датами

Добавлено детальное логирование для диагностики проблемы с парсингом дат:

### Новые логи для отладки:
- `NightscoutRemoteCGM: DEBUG - First reading keys: [...]` - показывает все ключи в первой записи
- `NightscoutRemoteCGM: DEBUG - First reading: {...}` - показывает полную структуру первой записи
- `NightscoutRemoteCGM: Found trend: X` / `No trend found in reading X`
- `NightscoutRemoteCGM: Found glucose value: X` / `No glucose value found in reading X`
- `NightscoutRemoteCGM: Found date string: X` / `No date found in reading X (tried key 'DT')`
- `NightscoutRemoteCGM: Parsing timestamp: X` - показывает попытки парсинга дат
- `NightscoutRemoteCGM: Successfully parsed [format]: [date]` - показывает успешный парсинг

### Поддерживаемые форматы дат:
1. ISO8601 с дробными секундами
2. ISO8601 без дробных секунд
3. Unix timestamp (секунды с 1970)
4. Кастомный формат "yyyy-MM-dd HH:mm:ss"

### Альтернативные ключи для дат:
- `"DT"` (основной)
- `"date"`
- `"timestamp"`
- `"time"`

## 🛡️ Исправления EXC_BREAKPOINT

Добавлена защита от ошибок EXC_BREAKPOINT при работе с delegate:

### Исправления:
1. **Безопасная работа с delegate** - добавлены проверки на nil
2. **Try-catch блоки** - для обработки ошибок при вызове delegate
3. **Упрощенная фильтрация** - избегаем сложных операций с delegate
4. **Дополнительное логирование** - для отслеживания проблем с delegate

### Новые логи для отладки delegate:
- `NightscoutRemoteCGM: No delegate available, using nil start date`
- `NightscoutRemoteCGM: ERROR getting start date from delegate: [error]`
- `NightscoutRemoteCGM: ERROR getting start date from delegate in Nightscout: [error]`

## 🎯 Использование существующей логики xDrip

**ВАЖНО!** Теперь используется готовая реализация из `xDripAppGroup`:

### Что изменилось:
1. **Используем `xDripAppGroup()`** - вместо собственной логики парсинга
2. **Используем `fetchLatestReadings()`** - готовый метод для получения данных
3. **Используем `xDripReading`** - готовую структуру данных
4. **Убрали собственный парсинг** - используем проверенную логику

### Преимущества:
- ✅ **Проверенная логика** - уже работает в Loop
- ✅ **Правильный парсинг дат** - использует regex для `(timestamp)`
- ✅ **Меньше кода** - убрали 100+ строк собственной логики
- ✅ **Надежность** - используем то, что уже тестировалось

### Новые логи:
- `NightscoutRemoteCGM: Attempting to fetch from App Group using xDripAppGroup`
- `NightscoutRemoteCGM: Successfully fetched X xDrip readings`
- `NightscoutRemoteCGM: Processing xDrip reading X/Y`

## 🔧 Исправления импортов

Добавлен импорт для использования xDripClient:

### Изменения:
1. **Добавлен `import xDripClient`** - для доступа к xDripAppGroup
2. **Используем `xDripClient.xDripAppGroup()`** - полное имя класса
3. **Убрана ошибка компиляции** - теперь код должен компилироваться
