# CodableStore

[![CI Status](http://img.shields.io/travis/inloop/CodableStore.svg?style=flat)](https://travis-ci.org/inloop/CodableStore)
[![Version](https://img.shields.io/cocoapods/v/CodableStore.svg?style=flat)](http://cocoapods.org/pods/CodableStore)
[![License](https://img.shields.io/cocoapods/l/CodableStore.svg?style=flat)](http://cocoapods.org/pods/CodableStore)
[![Platform](https://img.shields.io/cocoapods/p/CodableStore.svg?style=flat)](http://cocoapods.org/pods/CodableStore)

## Example

`UserDefaults` as storage provider:

```
struct Company {
    let name: String
}

let provider = UserDefaults.standard

let tesla = Company(name: "Tesla")
let companyKey = "somekey"

tesla.create(provider, key: companyKey).then { (company: Company?) -> Void in
    // company: Company?
}
Company.read(provider, key: companyKey).then { company -> Void in
    // company: Company?
}
```

`URLSession` as storage provider:

```
struct Post: Codable {
    let title: String
    let body: String
}

let provider = URLSession.shared

let url = URL(string: "http://jsonplaceholder.typicode.com/posts")!
let detailUrl = URL(string: "http://jsonplaceholder.typicode.com/posts/1")!

[Post].read(store, key: url).then { posts -> Void in
    // posts: [Post]?
}

Post.read(store, key: url).then { post -> Void in
    // post: Post?
}

let newPost = Port(title: "Foo", body: "Blah")
newPost.create(store, key: url).then { (post: Post?) -> Void in
    // post: Post?
}
```

### URLSession custom URLRequest

## Custom provider

## Requirements

## Installation

CodableStore is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CodableStore'
```

## Author

Jakub Knejzlik, jakub.knejzlik@inloop.eu

## License

CodableStore is available under the MIT license. See the LICENSE file for more info.
