# Analytics Feature

## Overview
This feature handles accuracy calculation, daily performance tracking, and historical reporting.

## Architecture Layers

### Data Layer
- **datasources/**: SQLite database operations for stats storage
- **models/**: Data models for statistics and reports
- **repositories/**: Implementation of analytics repositories

### Domain Layer
- **entities/**: `DailyStats` entity for daily aggregated data
- **repositories/**: Abstract repository interfaces
- **usecases/**: Business logic for analytics operations

### Presentation Layer
- **bloc/**: State management for analytics data
- **pages/**: Dashboard and history views
- **widgets/**: Charts, graphs, and stats display widgets

## Key Classes
- `DailyStats`: Domain entity for daily statistics
- `AnalyticsRepository`: Interface for data persistence and retrieval
- `AnalyticsRepositoryImpl`: SQLite-based implementation
- `GetDailyStatsUseCase`: Retrieve daily statistics
- `CalculateAccuracyUseCase`: Compute accuracy metrics

## Database Tables
- `daily_stats`: Aggregated daily statistics
- `sessions`: Recording sessions
- `mistakes`: Detected grammar errors

## Status
🚧 Not yet implemented
