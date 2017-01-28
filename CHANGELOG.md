# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
Nothing yet

## [0.1.0] - 2017-28-01
A version bump, because
## Added
- This changelog!
- `#default_headers` override example and test

### Changed
- `#headers` by default now includes `#default_headers`
- `#default_headers` is now not private
- `#header` is now returning default headers included.
Headers behaviour probably is unaffected but may be changed unintentionally.
- `#curl` is now returning default headers as well.
- `Apir::Request.present_cookie_jar` is now returning nil if no cookies given (was empty string)

### [0.0.3]
## Changed
- `#curl` and `#report_data` now returns request type i.e.: `-X GET`
- RequestReporting -> Reporting (module renamed)
- RequestReport -> Report (module renamed and moved)

## [0.0.2]
### Added
- travis build control

### Changed
- codestyle
- coverage
- reducing dependencies

## [0.0.1] - 2017-01-13
### Added
 - initial commit