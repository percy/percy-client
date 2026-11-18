# Changelog

## 2.2.0

Ruby 3.4 and Faraday 2 support, backward compatible with Ruby 2.6 and Faraday 0.15.4.
The public API (`Percy::Client`, `Percy::Config`, `PERCY_*` env vars) is unchanged.

- Support Ruby >= 2.6, including 3.4 (`required_ruby_version >= 2.6`).
- Relax `faraday` from `= 0.15.4` to `>= 0.15.4, < 3`.
- Relax `excon` from `= 0.105.0` to `>= 0.105.0, < 2`.
- Add `faraday-excon` (`>= 1.1, < 3`). It provides the excon adapter on Faraday 2 and is only
  loaded there.
- Add `logger` as a runtime dependency (it stops being a default gem in Ruby 3.5).
- Constrain `addressable` to `~> 2.3`.
- `NiceErrorMiddleware` now inherits from `Faraday::Middleware`, because
  `Faraday::Response::Middleware` was removed in Faraday 2. Errors raised are unchanged.
- Set the `Authorization: Token token="..."` header directly instead of using Faraday's
  `:token_auth` middleware, which was removed in Faraday 2. The header value is unchanged.
- Base64-encode resource content with `pack('m0')`, so the `base64` gem is no longer needed. It
  is not a default gem in Ruby 3.4.
- Dev dependencies: rake `>= 12.3, < 14`. `percy-style` moved to the Gemfile and is only
  installed on Ruby 2.x.

## 2.1.1 and earlier

See the GitHub releases page.
