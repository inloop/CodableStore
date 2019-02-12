import CodableStore

enum FakeAPIEnvironment: CodableStoreHTTPEnvironment {
    static let sourceBase = URL(string: "https://my-json-server.typicode.com/jakubpetrik/fake-api")!
    static let date: Endpoint<CustomDateSubject> = GET("/date")
    static let createDate: EndpointWithPayload<CustomDateSubject, CustomDateSubject> = POST("/date")
    static let dates: Endpoint<[CustomDateSubject]> = GET("/dates")
}
