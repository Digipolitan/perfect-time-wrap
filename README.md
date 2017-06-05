PerfectTimeWrap
=================================

[![Twitter](https://img.shields.io/badge/twitter-@Digipolitan-blue.svg?style=flat)](http://twitter.com/Digipolitan)

Perfect TimeWrap middleware swift is a request logger

## Installation

### Swift Package Manager

To install PerfectTimeWrap with SPM, add the following lines to your `Package.swift`.

```swift
import PackageDescription

let package = Package(
    name: "XXX",
    dependencies: [
        .Package(url: "https://github.com/Digipolitan/perfect-time-wrap-swift.git", majorVersion: 1)
    ]
)
```

## The Basics

Create a RouterMiddleware and register the TimeWrap middleware as follow

```swift
let server = HTTPServer()

let router = RouterMiddleware()

TimeWrap.use(in: router)

router.get(path: "/hello").bind { (context) in
  context.response.setBody(string: "Hello world !").completed()
  context.next()
}

server.use(router: router)

server.serverPort = 8888

do {
    try server.start()
    print("Server listening on port \(server.serverPort)")
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
```
When a user access to the route `/hello`, TimeWrap will log on the console :
`[INFO] GET /hello 200 OK 0.196 ms`

## Advanced

It's possible to register a specific handler to log as follow :
```swift
TimeWrap.use(in: router, options: .init { info, request, response in
    return "My special formatter \(info.duration())ms on \(request.path)"
 })
```
When a user access to the route `/hello`, TimeWrap will log on the console :
`[INFO] My special formatter 0.150978565216064ms on /hello`

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details!

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to [contact@digipolitan.com](mailto:contact@digipolitan.com).

## License

PerfectTimeWrap is licensed under the [BSD 3-Clause license](LICENSE).
