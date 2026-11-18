# Changelog

## 2.2.0

Ruby 3.4 and Faraday 2 support, backward compatible with Ruby 2.6 and Faraday 0.15.4.
The public API (`Percy::Client`, `Percy::Config`, `PERCY_*` env vars) is unchanged.

- Support Ruby >= 2.6, including 3.4 (`required_ruby_version >= 2.6`).
- Relax `faraday` from `= 0.15.4` to `>= 0.15.4, < 3`. On Ruby 3.x use Faraday >= 0.17.3, because
  older Faraday versions themselves fail to load there.
- Relax `excon` from `= 0.105.0` to `>= 0.105.0, < 2`.
- Add `faraday-excon` (`>= 1.1, < 3`). percy-client loads it explicitly only on Faraday 2.
  Faraday 0.x through 1.3 use their built-in excon adapter, and Faraday 1.4 and later 1.x
  versions depend on faraday-excon and load `faraday/excon` themselves.
  **Faraday 2 needs faraday-excon >= 2.0.** If faraday-excon 1.x is installed,
  `require 'percy'` raises a `LoadError` that says how to fix it. Apps on Faraday 2 should change
  any explicit `faraday-excon` pin in their Gemfile to `'>= 2.0'`.
- Add `logger` as a runtime dependency (it stops being a default gem in Ruby 3.5).
- Constrain `addressable` to `~> 2.3`.
- `NiceErrorMiddleware` now inherits from `Faraday::Middleware`, because
  `Faraday::Response::Middleware` was removed in Faraday 2. Errors raised are unchanged.
- Set the `Authorization: Token token="..."` header directly instead of using Faraday's
  `:token_auth` middleware, which was removed in Faraday 2. The header value is unchanged,
  including `:token_auth`'s `String#inspect` escaping.
- Base64-encode resource content with `pack('m0')`, so the `base64` gem is no longer needed. It
  is not a default gem in Ruby 3.4.
- Dev dependencies: rake `>= 12.3, < 14`. `percy-style` moved to the Gemfile and is only
  installed on Ruby 2.x.

## 2.1.1 and earlier

See the GitHub releases page.
