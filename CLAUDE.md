# Frontyard

## Git Commit Trailers

Every commit must include git trailers for changelog entries. Use changelog section names as trailer keys in commit messages.

### Trailer keys

- `Added:` - new features
- `Changed:` - changes in existing functionality
- `Deprecated:` - soon-to-be removed features
- `Removed:` - now removed features
- `Fixed:` - bug fixes
- `Security:` - vulnerability fixes

### Example

```
git commit -m "Implement user authentication

Added: User login and logout functionality
Fixed: Session timeout not working correctly"
```

Multiple trailers of the same type are allowed; each becomes a separate changelog entry.
