## Test environments

- macOS Tahoe 26.2, R 4.5.3

## R CMD check results

0 errors | 0 warnings | 1 note

The only local note was:

```text
checking for future file timestamps ... NOTE
unable to verify current time
```

This appears to be an environment-specific time verification issue in the local
check environment, not a package content issue.

## Downstream dependencies

This is the initial CRAN submission, so there are no downstream dependencies.

## Additional comments

The package imports Coral Point Count with Excel extensions (CPCe) files and
CPCe-derived local exports. It does not connect to MERMAID, CoralNet, or any
closed web platform.
