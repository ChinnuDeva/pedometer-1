# Natural Language Validation Layer - Architecture & Implementation
## Spoken English + Hindi Grammar Enhancement

**Date**: April 14, 2026  
**Priority**: CRITICAL  
**Status**: Design Complete - Ready for Implementation

---

## Problem Analysis

### Current Issues

1. **"Can I know your name?" marked as CORRECT**
   - Grammatically correct ✓
   - But unnatural in spoken English ✗
   - Native speakers say: "What is your name?" or "May I know your name?"

2. **Hindi sentences always marked CORRECT**
   - No Hindi grammar validation exists
   - No Hindi NLP library integrated
   - Users get false confidence in incorrect Hindi

3. **No distinction between correct and natural**
   - System only checks syntax rules
   - Doesn't validate conversational naturalness
   - Missing layer: "How commonly is this used?"

---

## Architecture Overview

### Current System (Single Layer)
```
Text → Grammar Rules → Errors/No Errors → Accuracy Score
        (Syntax only)
```

**Problem**: "Can I know your name?" passes syntax check

### Required New System (Two Layers)

```
Text → Grammar Rules → Natural Language Validator → Dual Scores
       (Syntax check)    (Fluency/Naturalness)     (Grammar + Fluency)
                ↓                   ↓                    ↓
            Grammar             Fluency            Combined
            Score: 100%         Score: 40%          Output: ✓ Correct, ⚠ Unnatural
```

---

## Component Design

### 1. Enhanced GrammarMistake Entity

**Current (Limited)**:
```dart
class GrammarMistake {
  String id;
  String text;
  String suggestion;
  GrammarErrorType errorType;
  double confidence;
  // Missing: naturalness info
}
```

**Enhanced**:
```dart
class GrammarMistake {
  // Original fields
  String id;
  String text;
  String suggestion;
  GrammarErrorType errorType;
  double confidence;
  
  // NEW FIELDS
  double fluencyScore;              // 0-100: naturalness
  bool isNaturalPhrasing;           // true if commonly used
  FluencyIssueType? fluencyType;    // what's unnatural?
  List<String> alternativePhrases;  // better ways to say it
  String language;                  // 'en' or 'hi'
}

enum FluencyIssueType {
  awkwardPhrasing,      // "Can I know your name?"
  formalWhereInformal,  // Too stiff for conversation
  informalWhereFormal,  // Too casual for formal context
  notCommonlyUsed,      // Rare phrasing
  translationError,     // Hindi→English artifact
  regionalism,          // Regional variation
  archaic,              // Outdated
  otherFluencyIssue,
}
```

---

### 2. Natural Language Validator Service

**Purpose**: Check if text is naturally used in spoken English

```dart
class NaturalLanguageValidator {
  // 1. Phrase database lookup
  Future<FluencyValidation> checkAgainstPhraseDatabase(String text)
  
  // 2. Pattern matching for awkward constructions  
  Future<FluencyValidation> checkEnglishPatterns(String text)
  
  // 3. ML-based naturalness scoring (optional)
  Future<FluencyValidation> scoreWithML(String text)
  
  // 4. Combine all three for final score
  FluencyValidation combine(...results)
}
```

---

### 3. Conversational Phrase Database

**Structure**: Map of unnatural → natural alternatives

```dart
const commonMisphrasings = {
  'can i know your name': [
    'what is your name',
    'may i know your name',
    'could you tell me your name',
  ],
  'i am knowing': [
    'i know',
  ],
  'i am coming from': [
    'i come from',
    'i am from',
  ],
  'can you tell me one thing': [
    'can i ask you something',
    'can you tell me something',
  ],
};
```

---

### 4. Pattern-Based Fluency Rules

**Detects common awkward patterns**:

| Pattern | Detection | Suggestion |
|---------|-----------|------------|
| "Can I know your X" | Conversational context | Use "What is your X" or "May I know your X" |
| "I am knowing" | Stative verb with "am" | Use "I know" |
| "I am coming from" | Wrong progressive | Use "I come from" |
| "tell me X thing" | Hindi artifact | Remove "thing" |
| "Can I get help" | Missing object | Use "Can you help me" |

---

### 5. Hindi Language Validator

**Validates Hindi-specific**:

1. **Gender agreement** (hindi naam, hindi bhasha)
2. **Verb conjugation** (correct tense forms)
3. **Case marking** (postpositions, kaarak)
4. **Common mistakes** (specific to Hindi speakers)

**Implementation options**:
- Option A: Use Hindi NLP API (Google Translate API, Indic NLP)
- Option B: Rule-based validation (basic patterns)
- Option C: Mark as "Limited validation" if no API available

---

### 6. Dual Scoring System

**Output format** (instead of just accuracy %):

```
Input: "Can I know your name?"

Grammar Score: 100%
├─ No syntax errors ✓
├─ Punctuation ✓
└─ Verb usage ✓

Fluency Score: 40%
├─ Not commonly used ✗
├─ Better: "What is your name?" ✗
└─ Better: "May I know your name?" ✗

Final Output:
✓ Grammatically Correct
⚠ Unnatural in spoken English
→ Suggestions: "What is your name?" or "May I know your name?"
```

---

## Implementation Path

### Phase 1: Extend Entities (2 hours)

```
1. Add fluency fields to GrammarMistake
2. Create FluencyIssueType enum
3. Create FluencyValidation result class
4. Update tests
```

### Phase 2: Phrase Database (1 hour)

```
1. Create ConversationalPhraseDatabase
2. Add 50+ common misphrasings
3. Add alternatives for each
4. Write tests for phrase matching
```

### Phase 3: English Fluency Rules (3 hours)

```
1. Create EnglishFluencyRules class
2. Implement 10+ pattern detections
3. Score confidence for each detection
4. Write comprehensive tests
```

### Phase 4: Hindi Validator (4 hours)

```
1. Research Hindi NLP options
2. Implement rule-based validation
3. Add common Hindi mistakes
4. Handle API integration
```

### Phase 5: Dual Scoring (2 hours)

```
1. Create DualScoreResult class
2. Combine grammar + fluency scores
3. Generate suggestions
4. Update presentation layer
```

### Phase 6: Integration (4 hours)

```
1. Update GrammarCheckerService
2. Register new services in DI
3. Wire up in BLoCs
4. Update UI to show both scores
```

### Phase 7: Testing (6 hours)

```
1. Unit tests for all components
2. Integration tests
3. Manual testing with examples
4. Edge case testing
```

---

## API Integration Options

### For Advanced ML Scoring

**Option 1: Google Cloud Natural Language API**
```dart
// Detects syntax, parts of speech
// Can analyze sentiment/intent
// Not ideal for conversational naturalness
```

**Option 2: OpenAI API (GPT-4)**
```dart
// Can rate naturalness
// Can suggest alternatives
// More expensive but more accurate
```

**Option 3: Hugging Face Transformers**
```dart
// Open source
// Can run locally or via API
// Good accuracy for naturalness
```

### For Hindi Validation

**Option 1: Google Translate API**
```dart
// Basic grammar checking
// Translation quality
// Limited Hindi grammar validation
```

**Option 2: Indic NLP Library**
```dart
// Open source
// Hindi-specific
// Can run locally
// Requires Dart wrapper
```

**Option 3: Manual Rule-Based**
```dart
// No API needed
// Can start simple
// Scale over time
// Best for MVP
```

---

## Expected Output Examples

### Example 1: Unnatural English

**Input**: "Can I know your name?"

**Output**:
```
Grammar Score: 100%
  ✓ Subject-verb agreement
  ✓ Tense correct
  ✓ Punctuation correct

Fluency Score: 35%
  ⚠ Awkward phrasing
  ⚠ Not commonly used in conversation
  
Status: ✓ Correct, ⚠ Unnatural

Suggestions:
  → "What is your name?"
  → "May I know your name?"
  → "Could you tell me your name?"
```

### Example 2: Grammatically Incorrect

**Input**: "I am knowing your name"

**Output**:
```
Grammar Score: 70%
  ⚠ Stative verb with progressive
  
Fluency Score: 20%
  ⚠ Very unnatural combination
  
Status: ❌ Incorrect & Unnatural

Corrections:
  → "I know your name"
```

### Example 3: Hindi Sentence

**Input**: "Mere naam kya hai?" (Hindi)

**Output**:
```
Language: Hindi

Grammar Score: 90%
  ✓ Gender agreement
  ✓ Case marking
  ⚠ Could use formal variant

Fluency Score: 85%
  ✓ Commonly used
  ✓ Natural phrasing
  
Status: ✓ Correct & Natural

Note: Limited validation available for Hindi.
```

---

## Benefits

### For Users
- Learns natural spoken English, not just correct grammar
- Gets suggestions for better phrasing
- Understands why something is unnatural
- Better confidence in their speech

### For App
- Differentiates from basic grammar checkers
- More useful for language learning
- Builds user trust with transparency
- Shows grammar + fluency distinction

### For Hindi Speakers
- Can validate Hindi sentences (with caveats)
- Learns natural English alternatives
- Awareness of common Hindi→English artifacts

---

## Testing Strategy

### Unit Tests

```dart
test('detects "can i know your name" as unnatural') {
  final result = validator.validateFluency(
    'can i know your name',
    language: 'en',
  );
  expect(result.fluencyScore, lessThan(50));
  expect(result.issueType, FluencyIssueType.awkwardPhrasing);
}

test('accepts "what is your name" as natural') {
  final result = validator.validateFluency(
    'what is your name',
    language: 'en',
  );
  expect(result.fluencyScore, greaterThan(90));
  expect(result.isNaturalPhrasing, true);
}
```

### Integration Tests

```dart
test('full grammar + fluency check', () async {
  final grammar = await grammarChecker.checkText('Can I know your name?');
  final fluency = await nlValidator.validateFluency(
    'Can I know your name?',
    language: 'en',
  );
  
  expect(grammar.isEmpty, true);  // Grammatically correct
  expect(fluency.fluencyScore, lessThan(50));  // But unnatural
});
```

---

## Rollout Plan

### MVP (Minimum Viable)
1. Add FluencyIssueType enum and fields
2. Implement 20 common phrases database
3. Basic pattern detection (5 patterns)
4. Manual Hindi rule checking
5. Show dual scores in UI

### V1 (Production Ready)
1. Expand phrase database to 100+
2. Add 20+ pattern detections
3. Integrate optional ML API
4. Hindi API integration
5. Comprehensive documentation

### V2 (Advanced)
1. Learn from user corrections
2. Regional variants support
3. Context-aware suggestions
4. Multi-language support
5. Analytics on common errors

---

## Success Metrics

### Before Enhancement
- "Can I know your name?" → ✓ 100% accuracy (WRONG)
- Hindi sentence → ✓ 100% accuracy (WRONG)
- User confusion about feedback

### After Enhancement  
- "Can I know your name?" → ✓ Grammar 100%, ⚠ Fluency 35% (CORRECT)
- Hindi sentence → ✓ Grammar 90%, Fluency 85%, Note: Limited validation (CORRECT)
- User learns natural phrasing
- Clear feedback on what's unnatural and why

---

## Next Steps

1. **Review** this architecture with team
2. **Choose** API options (or go manual first)
3. **Create** enhanced entities
4. **Implement** phrase database
5. **Add** pattern-based rules
6. **Integrate** into grammar checker service
7. **Update** UI to show dual scores
8. **Test** thoroughly

---

**Document Version**: 1.0  
**Status**: Ready for Implementation  
**Estimated Timeline**: 3-4 weeks for full implementation
