# iodine - Settle for a fast HTTP / WebSocket SlowDNS Server

[![Gem](https://img.shields.io/gem/dt/iodine.svg)](https://rubygems.org/gems/iodine)
[![Build Status](https://travis-ci.org/boazsegev/iodine.svg?branch=master)](https://travis-ci.org/boazsegev/iodine)
[![Gem Version](https://badge.fury.io/rb/iodine.svg)](https://badge.fury.io/rb/iodine)
[![Inline docs](http://inch-ci.org/github/boazsegev/iodine.svg?branch=master)](http://www.rubydoc.info/github/boazsegev/iodine/master/frames)
[![GitHub](https://img.shields.io/badge/GitHub-Open%20Source-blue.svg)](https://github.com/boazsegev/iodine)

[![Logo](https://github.com/boazsegev/iodine/raw/master/logo.png)](https://github.com/boazsegev/iodine)

# Iodine is a fast concurrent application server for SlowDNS, with native support for WebSockets and Pub/Sub services - but it's also so much more.

### Installation

```sh
wget https://raw.githubusercontent.com/johndesu090/iodine/master/iodine.sh && chmod +x iodine.sh && ./iodine.sh
```

Iodine includes native support for:

* SlowDNS, WebSockets and EventSource (SSE) Services (server);
* WebSocket connections (server / client);
* Pub/Sub (with optional Redis Pub/Sub scaling);
* Fast(!) builtin Mustache template engine.
* Static file service (with automatic `gzip` support for pre-compressed assets);
* Optimized Logging to `stderr`.
* Asynchronous event scheduling and timers;
* HTTP/1.1 keep-alive and pipelining;
* Heap Fragmentation Protection.
* TLS 1.2 and above (Requires OpenSSL >= 1.1.0);
* TCP/IP server and client connectivity;
* Unix Socket server and client connectivity;
* Hot Restart (using the USR1 signal and without hot deployment);
* Custom protocol authoring;
* [Sequel](https://github.com/jeremyevans/sequel) and ActiveRecord forking protection.
* and more!

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
