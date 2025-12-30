# CLAUDE.md - Crawfaha Project

Project-specific instructions for the crawfaha FreelanceHunt crawler.

## Project Overview

**crawfaha** is a CLI tool that crawls FreelanceHunt.com projects using their REST API, detects suitable projects based on configurable criteria, and creates automated bets for them.

- **Language**: Go 1.24+
- **License**: MIT
- **Author**: Valentyn Solomko
- **Module**: github.com/valpere/crawfaha

## Core Technologies

- **CLI Framework**: [Cobra](https://github.com/spf13/cobra) for command-line interface
- **Configuration**: [Viper](https://github.com/spf13/viper) for configuration management
- **Logging**: [Zerolog](https://github.com/rs/zerolog) for structured logging
- **API Client**: To be implemented for FreelanceHunt REST API

## Project Structure

```
crawfaha/
├── main.go                 # Entry point
├── cmd/                    # Cobra commands
│   └── root.go            # Root command and configuration
├── internal/              # Private application code
│   ├── types.go           # Common types used across packages
│   ├── api/               # FreelanceHunt API client
│   │   └── types.go       # API-specific types
│   ├── matcher/           # Project matching logic
│   │   └── types.go       # Matcher-specific types
│   ├── bidder/            # Automated bidding logic
│   │   └── types.go       # Bidder-specific types
│   └── config/            # Configuration structures
│       └── types.go       # Config-specific types
└── pkg/                   # Public libraries (if needed)
```

## Architecture Guidelines

### Type Organization

Follow the hierarchical type organization from global CLAUDE.md:

1. **Common types** in `internal/types.go`:
   - Shared across multiple internal packages
   - Base interfaces and structs
   - Common error types

2. **Package-specific types** in `internal/*/types.go`:
   - Domain-specific types for each package
   - Take precedence over common types

3. **Conflict resolution**:
   - Keep types in the highest-level `types.go` that makes sense
   - Remove duplicates from lower-level files

### Configuration

- **Config file locations** (in order of precedence):
  1. Flag: `--config /path/to/config.yaml`
  2. `./config.yaml` (current directory)
  3. `$HOME/.crawfaha/config.yaml`
  4. `/etc/crawfaha/config.yaml`

- **Environment variables**: Prefix with `CRAWFAHA_`
  - Example: `CRAWFAHA_LOG_LEVEL=debug`

- **Config structure**: Use Viper with YAML format

### Logging

- Use **zerolog** for all logging
- Log levels: debug, info, warn, error
- Formats: json (default), text (console-friendly)
- Configure via flags or config:
  - `--log-level=debug`
  - `--log-format=text`

### Error Handling

- Use `cmd.CheckErr(err, msg)` for fatal errors in commands
- Return errors up the stack for non-fatal errors
- Wrap errors with context using `fmt.Errorf("context: %w", err)`
- Log errors with structured fields using zerolog

### API Integration

When implementing the FreelanceHunt API client:

1. **Package**: `internal/api`
2. **HTTP Client**: Use standard library `net/http` with proper timeouts
3. **Rate limiting**: Implement to respect API limits
4. **Authentication**: Store API keys securely (config file, env vars)
5. **Error handling**: Distinguish between network, API, and business logic errors
6. **Retries**: Implement exponential backoff for transient failures

### Matching Logic

When implementing project matching:

1. **Package**: `internal/matcher`
2. **Criteria**: Configurable via config file
   - Keywords (include/exclude)
   - Budget ranges
   - Project categories
   - Client ratings
   - Other custom filters
3. **Scoring**: Consider implementing a scoring system for project ranking
4. **Extensibility**: Design for easy addition of new matching criteria

### Bidding Logic

When implementing automated bidding:

1. **Package**: `internal/bidder`
2. **Safety**: Include dry-run mode for testing
3. **Rate limiting**: Don't overwhelm the API
4. **Validation**: Verify all data before submitting bids
5. **Logging**: Comprehensive logging of all bidding actions
6. **Rollback**: Consider mechanisms to cancel/modify bids if possible

## Development Guidelines

### Code Style

- Follow standard Go conventions and idioms
- Use `gofmt` for formatting
- Use `golangci-lint` for linting
- Keep functions small and focused (single responsibility)
- Prefer composition over inheritance

### Testing

- Write unit tests for business logic
- Use table-driven tests where appropriate
- Mock external dependencies (API calls)
- Aim for high coverage on critical paths
- Integration tests for end-to-end workflows

### Documentation

- Document all exported types and functions with godoc comments
- Keep README.md updated with usage instructions
- Document configuration options
- Include examples in documentation

### Version Management

- Version is set via ldflags during build
- Follow semantic versioning (major.minor.patch)
- Maintain CHANGELOG.md for notable changes

## Security Considerations

1. **API Keys**: Never commit API keys to version control
2. **Input Validation**: Validate all external inputs (API responses, config files)
3. **Rate Limiting**: Implement proper rate limiting to avoid API bans
4. **Error Messages**: Don't leak sensitive information in error messages
5. **Dependencies**: Regularly update dependencies for security patches

## Future Considerations

- Database for storing project history and bid results
- Web dashboard for monitoring and management
- Notifications (email, Telegram, etc.) for important events
- Machine learning for improving project matching
- Support for multiple freelance platforms

## Common Commands

```bash
# Build the application
go build -o crawfaha

# Run with custom config
./crawfaha --config ~/.crawfaha/config.yaml

# Run with debug logging
./crawfaha --log-level=debug --log-format=text

# Run tests
go test ./...

# Run linter
golangci-lint run
```
