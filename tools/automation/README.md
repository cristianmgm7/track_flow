# TrackFlow Development Automation Tools

This directory contains automation tools to streamline TrackFlow development and reduce repetitive tasks.

## 🚀 Quick Start

```bash
# Make scripts executable
chmod +x tools/automation/*

# Generate a new feature
./tools/automation/new-feature notifications

# Run development automation
./tools/automation/dev_automation.sh gen

# Check project health
./tools/automation/project_health.sh
```

## 📁 Tools Overview

### 1. **Feature Generator** (`generate_feature.py` + `new-feature`)
Generates complete feature scaffolding following TrackFlow's Clean Architecture + DDD patterns.

**Creates 19 files per feature:**
- Domain layer: entities, use cases, repositories, value objects
- Data layer: DTOs, Isar documents, data sources, repository implementations  
- Presentation layer: BLoC (events, states, bloc)
- Tests: entity tests and BLoC tests

```bash
# Generate new feature
./tools/automation/new-feature user_settings

# Generate with tests
./tools/automation/new-feature notifications --with-tests

# Skip presentation layer (domain + data only)
python tools/automation/generate_feature.py analytics --skip-presentation
```

### 2. **Development Automation** (`dev_automation.sh`)
Automates common development tasks with a unified interface.

```bash
# Full development setup
./tools/automation/dev_automation.sh setup

# Quick code generation
./tools/automation/dev_automation.sh gen

# Clean and regenerate
./tools/automation/dev_automation.sh clean-gen

# Run tests
./tools/automation/dev_automation.sh test [unit|integration|watch|coverage]

# Start development server
./tools/automation/dev_automation.sh dev [flavor] [device]

# Build app
./tools/automation/dev_automation.sh build [flavor] [platform] [mode]

# Fix common issues
./tools/automation/dev_automation.sh fix

# Code quality checks
./tools/automation/dev_automation.sh lint
./tools/automation/dev_automation.sh format

# Database operations
./tools/automation/dev_automation.sh db [reset|inspect]
```

### 3. **Project Health Monitor** (`project_health.sh`)
Comprehensive health check for the entire project.

```bash
./tools/automation/project_health.sh
```

**Monitors:**
- Flutter environment and doctor status
- Dependencies and outdated packages
- Code generation status
- Project structure compliance
- Code quality and formatting
- Test status and coverage
- Firebase configuration
- Platform-specific configurations
- Database files and size

## 🎯 Usage Examples

### Daily Development Workflow
```bash
# Start your day
./tools/automation/project_health.sh
./tools/automation/dev_automation.sh gen
./tools/automation/dev_automation.sh dev

# Create new feature
./tools/automation/new-feature user_notifications
./tools/automation/dev_automation.sh gen
./tools/automation/dev_automation.sh test

# Before commit
./tools/automation/dev_automation.sh lint
./tools/automation/dev_automation.sh format
```

### Troubleshooting
```bash
# Fix common development issues
./tools/automation/dev_automation.sh fix

# Check what's wrong
./tools/automation/project_health.sh

# Reset and regenerate everything
./tools/automation/dev_automation.sh clean-gen
./tools/automation/dev_automation.sh setup
```

### Feature Development
```bash
# 1. Generate feature scaffold
./tools/automation/new-feature analytics --with-tests

# 2. Implement business logic in generated files
# 3. Run code generation
./tools/automation/dev_automation.sh gen

# 4. Test your implementation
./tools/automation/dev_automation.sh test unit

# 5. Check code quality
./tools/automation/dev_automation.sh lint
```

## 🏗️ Architecture Compliance

All generated code follows TrackFlow's established patterns:

- **Clean Architecture**: Domain → Data → Presentation layers
- **Domain-Driven Design**: Rich entities, value objects, domain services
- **BLoC Pattern**: Reactive state management with events/states
- **Either Pattern**: Functional error handling with `Either<Failure, Success>`
- **Dependency Injection**: `@injectable` and `@lazySingleton` annotations
- **Offline-First**: Isar local storage with Firebase sync
- **Testing**: Comprehensive test coverage with mocks

## 🔧 Customization

### Feature Generator Templates
Edit `generate_feature.py` to modify templates for:
- Entity patterns
- Use case structures  
- BLoC implementations
- Repository patterns
- Test templates

### Development Commands
Modify `dev_automation.sh` to add project-specific commands or integrate with CI/CD pipelines.

### Health Checks
Extend `project_health.sh` to include additional project-specific validations.

## 🚨 Important Notes

1. **Always run code generation** after using the feature generator
2. **Check project health** regularly to catch issues early
3. **Use automation scripts** instead of manual Flutter commands
4. **Generated code is a starting point** - customize for your specific needs
5. **Test generated features** before implementing business logic

## 🤝 Contributing

When adding new automation:
1. Follow existing script patterns
2. Add comprehensive help text
3. Include error handling and validation  
4. Update this README with usage examples
5. Test on clean project setup

---

These tools transform TrackFlow development from hours of boilerplate to minutes of productive coding. Use them consistently to maintain code quality and development velocity.