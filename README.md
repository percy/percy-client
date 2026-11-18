# Percy::Client

[![Build Status](https://travis-ci.org/percy/percy-client.svg?branch=master)](https://travis-ci.org/percy/percy-client)
[![Gem Version](https://badge.fury.io/rb/percy-client.svg)](http://badge.fury.io/rb/percy-client)

### Docs here: [https://percy.io/docs/api/ruby-client](https://percy.io/docs/api/ruby-client)

## Compatibility

| Dependency | Supported |
|------------|-----------|
| Ruby       | >= 2.6 (tested on 2.6 and 3.4) |
| Faraday    | >= 0.15.4, < 3 (0.x, 1.x, 2.x) |
| Excon      | >= 0.105.0, < 2 |

Requests always go through the excon adapter. On Faraday 2 it comes from the
`faraday-excon` gem, which percy-client depends on. Faraday versions older than
0.17.3 do not load on Ruby 3, so Ruby 3.x apps need Faraday >= 0.17.3.

See [CHANGELOG.md](CHANGELOG.md) for release notes.
