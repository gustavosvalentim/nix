# Code Review Best Practices (Source-Backed)

Use this reference to justify review priorities and severity decisions.

## Core Principles

- Correctness is the top review goal; style is secondary.
- Keep findings specific and actionable with exact locations.
- Prioritize high-risk security and reliability defects first.
- Require test evidence for changed business logic and failure paths.

## Security Review Focus

- Prioritize weakness classes highlighted by CWE Top 25 and OWASP guidance.
- Explicitly check for:
- Injection and unsafe command execution paths
- Broken authentication and authorization
- Secret exposure and insecure cryptography
- Input validation and output encoding gaps
- Error handling that leaks sensitive details

## Reliability and Correctness Focus

- Treat unhandled exceptions as high-risk unless proven contained.
- Treat reliance on undefined behavior as at least high-risk in affected languages.
- Check incomplete branches, edge-case handling, and rollback/cleanup semantics.

## Testing Expectations

- Map each changed business rule to tests.
- Call out missing tests for:
- Primary business logic paths
- Error/failure handling paths
- Security-sensitive decision points

## Severity Calibration

- For security findings, calibrate impact using CVSS concepts (exploitability + impact).
- For non-security findings, calibrate by likelihood x impact on production behavior.
- Use `critical`, `high`, `medium`, `low` and explain the rationale.

## Primary Sources

- Google Engineering Practices: Code Review Developer Guide
  - https://google.github.io/eng-practices/review/
- Google Engineering Practices: Standard of Code Review
  - https://google.github.io/eng-practices/review/reviewer/standard.html
- OWASP Testing Guide: Code Review Testing
  - https://owasp.org/www-project-web-security-testing-guide/
- OWASP Code Review Guide
  - https://owasp.org/www-project-code-review-guide/
- NIST Secure Software Development Framework (SP 800-218)
  - https://csrc.nist.gov/pubs/sp/800/218/final
- CWE Top 25 Most Dangerous Software Weaknesses
  - https://cwe.mitre.org/top25/archive/2025/2025_top25_list.html
- CWE-248: Uncaught Exception
  - https://cwe.mitre.org/data/definitions/248.html
- CWE-758: Reliance on Undefined, Unspecified, or Implementation-Defined Behavior
  - https://cwe.mitre.org/data/definitions/758.html
- SEI CERT Rule ERR51-CPP
  - https://wiki.sei.cmu.edu/confluence/display/cplusplus/ERR51-CPP.+Handle+all+exceptions
- FIRST CVSS v4.0 Specification
  - https://www.first.org/cvss/specification-document
