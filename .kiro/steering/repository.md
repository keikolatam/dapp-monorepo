# Repository URLs and Project Information

## Overview

This steering document defines the standard URLs and project information that should be used consistently across all Cargo.toml files and project documentation.

## Standard URLs

### Homepage
All Cargo.toml files should use:
```toml
homepage = "http://keiko-dapp.xyz/"
```

### Repository
All Cargo.toml files should use:
```toml
repository = "https://github.com/keikolatam/keiko-dapp"
```

### Authors
All Cargo.toml files should use:
```toml
authors = ["Keiko Team"]
```

## License Information

### License File Reference
All Cargo.toml files should reference the LICENSE file at the repository root:
```toml
license-file = "../../../LICENSE"  # Adjust path as needed
```

### License Headers
All source files should include the Business Source License 1.1 header according to #[[file:LICENSE]]:
```rust
// Business Source License 1.1
// 
// Licensed Work: keiko-dapp Version 0.0.1 or later.
// The Licensed Work is (c) 2025 Luis Andrés Peña Castillo
// 
// For full license terms, see LICENSE file in the repository root.
```

## Application Rules

### When Creating New Files
- All new Cargo.toml files must include the standard homepage and repository URLs
- All new source files must include the license header
- Use consistent author information across all packages

### When Updating Existing Files
- Update any outdated URLs to match the standards above
- Ensure license file paths are correct relative to each package location
- Maintain consistency in project metadata

## Verification

To verify compliance:
1. Search for all Cargo.toml files in the repository
2. Check that homepage and repository URLs match the standards
3. Verify license file paths are correct
4. Ensure all source files have proper license headers

## Files Updated

The following files have been updated to comply with these standards:
- `backend/runtime/Cargo.toml` - Updated homepage and repository URLs
- `backend/node/Cargo.toml` - Updated homepage and repository URLs
- `backend/pallets/learning_interactions/Cargo.toml` - Updated homepage and repository URLs
- `backend/pallets/life_learning_passport/Cargo.toml` - Updated homepage and repository URLs
- `backend/pallets/reputation_system/Cargo.toml` - Updated homepage and repository URLs
- `backend/node/src/command.rs` - Updated support URLs in CLI implementations
- `backend/pallets/learning_interactions/src/lib.rs` - Updated xAPI identifier URLs

## Notes

- The workspace root `backend/Cargo.toml` doesn't need homepage/repository fields as it's a workspace manifest
- All packages should set `publish = false` as this is a private project
- Use consistent version numbering across all packages (currently 0.1.0)