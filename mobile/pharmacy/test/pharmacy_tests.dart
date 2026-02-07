/// Pharmacy App Test Suite
/// 
/// This file documents all the automated tests for the Pharmacy application.
/// 
/// Run all tests: flutter test
/// Run with coverage: flutter test --coverage
/// 
/// Test Structure:
/// test/
/// ├── test_helpers.dart           - Common test utilities and factories
/// ├── core/
/// │   └── errors/
/// │       └── exceptions_test.dart - Exception classes tests
/// ├── features/
/// │   ├── auth/
/// │   │   └── domain/
/// │   │       └── entities/
/// │   │           └── user_entity_test.dart - User & Pharmacy entity tests
/// │   ├── orders/
/// │   │   └── domain/
/// │   │       └── entities/
/// │   │           └── order_entity_test.dart - Order entity tests
/// │   └── inventory/
/// │       └── domain/
/// │           └── entities/
/// │               ├── product_entity_test.dart - Product entity tests
/// │               └── category_entity_test.dart - Category entity tests
library pharmacy_flutter_tests;

// Export all test files for documentation purposes
export 'test_helpers.dart';
