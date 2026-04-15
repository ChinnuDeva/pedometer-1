# Speech Recognition Feature

## Overview
This feature handles real-time speech-to-text conversion using the device's microphone.

## Architecture Layers

### Data Layer
- **datasources/**: Remote and local data sources for speech API integration
- **models/**: Data models extending domain entities
- **repositories/**: Implementation of domain repositories

### Domain Layer
- **entities/**: `Transcription` entity definition
- **repositories/**: Abstract repository interfaces
- **usecases/**: Business logic use cases

### Presentation Layer
- **bloc/**: State management with BLoC pattern
- **pages/**: Full screen widgets
- **widgets/**: Reusable UI components

## Key Classes
- `Transcription`: Domain entity for transcribed text
- `TranscriptionModel`: Data model with serialization
- `SpeechRecognitionRepository`: Interface for speech operations
- `SpeechRecognitionRepositoryImpl`: Concrete implementation
- `RecordSpeechUseCase`: Use case for recording and transcribing

## Status
🚧 Not yet implemented
