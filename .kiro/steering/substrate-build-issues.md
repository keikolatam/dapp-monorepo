# Substrate Build Issues

## Known Issues

### TcpListener Compilation Error

**Issue**: When running `cargo test` or `cargo build` on individual pallets, you may encounter:

```
error[E0433]: failed to resolve: could not find `TcpListener` in `net`
  --> substrate/utils/prometheus/src/lib.rs:89:29
   |
89 |     let listener = tokio::net::TcpListener::bind(&prometheus_addr).await.map_err(|e| {
   |                                ^^^^^^^^^^^ could not find `TcpListener` in `net`
```

**Root Cause**: This is a Substrate dependency configuration issue where the `tokio` crate is missing the `net` feature flag in the prometheus endpoint utility.

**Workaround Strategies**:

1. **Use Workspace-Level Testing**: Instead of testing individual pallets, run tests from the workspace root:

   ```bash
   cargo test -p pallet-life-learning-passport
   ```

2. **Build from Runtime**: Test pallets as part of the runtime build:

   ```bash
   cd backend
   cargo build --release
   ```

3. **Mock Dependencies**: For pallet-specific testing, create minimal mock environments that don't pull in the problematic prometheus dependencies.

4. **Dependency Inversion**: Structure pallet code to be testable without full Substrate runtime dependencies by using trait abstractions.

## Implementation Guidelines

When implementing pallets:

- Focus on core pallet logic and data structures
- Use trait abstractions for external dependencies
- Implement comprehensive unit tests using mock environments
- Verify integration through runtime compilation rather than individual pallet testing
- Document any dependency-related build issues in this file

## Testing Strategy

1. **Unit Tests**: Use mock.rs with minimal dependencies
2. **Integration Tests**: Test through runtime compilation
3. **Functional Tests**: Use full node testing environment

This issue affects all pallets in the project and is not specific to individual pallet implementations.
