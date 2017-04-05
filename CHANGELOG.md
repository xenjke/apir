# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
Nothing yet

## [0.1.4] - 2017-04-05
- Headers are now capitalized when printing CURL
- Content-Type header is now overriding to comply with payload (RestClient warning fix)

## [0.1.3] - 2017-03-29
- Request authorisation credentials as intialize args
- Request authorisation credentials in CURL
- removed `.idea`
- `.idea` in `.gitignore`

## [0.1.2] - 2017-02-05
- Fixed cookie merging bug, introduced in [0.1.0]

## Added
- `response.headers` in reporting

## [0.1.1] - 2017-02-05
Found cookie merging bug, fixed in [0.1.2]
`@cookie_jar` small fix

### Changed
- `@cookie_jar` is now initializing a bit earlier, to make sure headers would not
be generated with `nil` `@cookie_jar`

## [0.1.0] - 2017-01-28
A version bump, because of `#header` and `#default_header` behaviour changed.

## Added
- This changelog!
- `#default_headers` override example and test
- `#with_logging` override example

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
