# AudioGen - Agent Instructions

## Project Overview

AudioGen is a macOS Swift application that provides a user interface for text-to-audio generation using OpenAI's TTS (Text-to-Speech) API. The app acts as a frontend that captures user input and instructions, then delegates the audio generation process to a Node.js script.

## Architecture

### Core Components

- **Swift UI Frontend**: Native macOS application built with SwiftUI
- **Node.js Backend**: `index.js` script that handles OpenAI TTS API integration
- **File-based Communication**: Text files serve as the bridge between UI and Node script
  - `instructions.txt`: Stores generation parameters and instructions
  - `input.txt`: Stores the text content to be converted to audio

## Technology Stack

- **Language**: Swift (macOS)
- **UI Framework**: SwiftUI
- **Backend Runtime**: Node.js
- **API**: OpenAI TTS
- **Architecture Pattern**: MVVM (Model-View-ViewModel) with functional programming principles

## Development Guidelines

### Swift Code Standards

1. **Functional Programming Approach**: Prefer functional patterns, pure functions, and immutability
2. **Type Safety**: Leverage Swift's strong type system; use enums for state, protocols for abstractions
3. **Error Handling**: Use Result types and proper error propagation
4. **Async/Await**: Use modern Swift concurrency for asynchronous operations
5. **SwiftUI Best Practices**: Prefer composition, extract reusable views, keep views simple

### Code Style

- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Write self-documenting code with clear variable names
- Add documentation comments for public interfaces
- Keep functions small and focused on single responsibilities
- Prefer `let` over `var` whenever possible

### Architecture Patterns

The project uses **MVVM (Model-View-ViewModel)** architecture:

- **Models**: Represent data structures (audio generation parameters, results)
- **Views**: SwiftUI views that remain simple and declarative
- **ViewModels**: Handle business logic, state management, and coordination with Node.js
  - Use `@Published` properties for state
  - Keep ViewModels testable by avoiding direct UI dependencies
  - Handle file I/O and process execution here
  - Use `@MainActor` for UI-updating logic

**Functional Programming Principles:**
- Prefer pure functions where possible
- Use immutable data structures
- Leverage Swift's Result type for error handling
- Keep side effects isolated in ViewModels

## Current Implementation Details

### File Operations

The app writes user input to two text files:
- `instructions.txt`: Contains generation instructions and parameters
- `input.txt`: Contains the text to be converted to speech

### Node.js Integration

- The app executes `index.js` which handles:
  - Reading from `instructions.txt` and `input.txt`
  - Making OpenAI TTS API calls
  - Saving generated audio files
  - Returning status/results

## Development Workflow

### When Adding Features

1. **Read existing code** to understand current patterns and structure
2. **Maintain consistency** with established architectural decisions
3. **Test thoroughly** - consider both unit and UI tests
4. **Handle errors gracefully** - provide clear user feedback
5. **Document complex logic** - especially Node.js integration points

### When Refactoring

1. **Preserve functionality** - ensure existing features continue to work
2. **Improve incrementally** - avoid massive rewrites
3. **Update tests** - keep test coverage aligned with changes
4. **Consider backwards compatibility** - especially for file formats

### When Debugging

1. **Check file I/O** - verify `instructions.txt` and `input.txt` are written correctly
2. **Verify Node.js execution** - ensure `index.js` is accessible and runs properly
3. **Inspect error messages** - from both Swift and Node.js layers
4. **Test file permissions** - ensure app has necessary file system access

## Future Considerations

- Text and instruction management will evolve (details pending)
- Consider streaming audio generation progress
- Potential for multiple voice/model selection
- Audio playback controls within the app
- History/library of generated audio files

## Important Notes

- This is a macOS-specific application
- The Node.js script must be available in the app's execution context
- File-based communication is the current bridge between Swift UI and Node.js
- OpenAI API key management will be required

## Questions to Consider

When implementing new features, ask:
- How does this affect the file-based communication?
- Does this require changes to both Swift and Node.js layers?
- How should errors from Node.js be surfaced to users?
- What's the user experience during audio generation (loading states)?
- How do we handle concurrent generation requests?

## Getting Help

When working on this project:
- Refer to Swift documentation for language features
- Check SwiftUI documentation for UI components
- Review OpenAI TTS API documentation for capabilities
- Consider macOS sandboxing and permissions requirements
- Look into process execution in Swift for running Node.js scripts

---

**Project Status**: Active Development  
**Primary Goal**: Provide intuitive UI for OpenAI TTS integration  
**Core Pattern**: Swift UI → File I/O → Node.js → OpenAI TTS
