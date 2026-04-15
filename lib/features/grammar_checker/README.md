# Grammar Checker Feature

## Overview
This feature detects grammar mistakes in transcribed text and provides suggestions.

## Architecture Layers

### Data Layer
- **datasources/**: Grammar rule definitions and external API integrations
- **models/**: Data models for grammar mistakes
- **repositories/**: Implementation of domain repositories

### Domain Layer
- **entities/**: `GrammarMistake` entity with error types
- **repositories/**: Abstract repository interfaces
- **usecases/**: Business logic for grammar checking

### Presentation Layer
- **bloc/**: State management for grammar checking results
- **pages/**: Mistake display and correction UI
- **widgets/**: Grammar suggestion widgets

## Key Classes
- `GrammarMistake`: Domain entity for detected errors
- `GrammarErrorType`: Enum for error classifications
- `GrammarCheckerRepository`: Interface for checking operations
- `GrammarCheckerRepositoryImpl`: Concrete implementation
- `CheckGrammarUseCase`: Use case for grammar analysis

## Status
🚧 Not yet implemented
