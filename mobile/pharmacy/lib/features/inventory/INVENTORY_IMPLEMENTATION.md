# Inventory Feature Implementation

## Overview

The Inventory feature allows pharmacy staff to view and manage their product stock.

## Components

### Domain Layer

- **ProductEntity**: Core business object representing a product. Includes properties for `isLowStock` (<= 5) and `isOutOfStock` (0).
- **InventoryRepository**: Abstract interface for inventory operations.

### Data Layer

- **ProductModel**: JSON serialization implementation of ProductEntity.
- **InventoryRemoteDataSource**: Handles API calls to backend:
  - `GET /pharmacy/products`: Fetch all products.
  - `POST /pharmacy/products/{id}/stock`: Update stock quantity.
- **InventoryRepositoryImpl**: Implementation of the repository pattern.

### Presentation Layer

- **InventoryState**: Holds the list of products, status (loading, loaded, error), and search query.
- **InventoryNotifier (Riverpod)**:
  - `fetchProducts()`: Loads initial data.
  - `updateStock(id, quantity)`: Updates stock via API and performs optimistic UI updates for instant feedback.
  - `search(query)`: Updates search filter.
- **InventoryPage**:
  - Displays list of products.
  - Search bar for filtering by name or category.
  - Visual indicators for stock status (Green: OK, Orange: Low, Red: Out of Stock).
  - Edit dialog to quick-update stock quantity.

## State Management

Uses `flutter_riverpod` with `StateNotifier` for reactive UI updates. Dependency injection is handled via `inventory_di_providers.dart`.

## Usage

Accessible via the "Stock" tab in the `DashboardPage`.
