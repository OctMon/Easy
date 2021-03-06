import Foundation

extension MonkeyKing {
    
    static func weiboSchemeLink(uuidString: String) -> URL? {
        var components = URLComponents(string: "weibosdk://request")
        
        components?.queryItems = [
            .init(name: "id", value: uuidString),
            .init(name: "sdkversion", value: "003233000"),
            .init(name: "luicode", value: "10000360"),
            .init(name: "lfid", value: Bundle.main.monkeyking_bundleID ?? ""),
            .init(name: "newVersion", value: "3.3"),
        ]
        
        return components?.url
    }
    
    static func weiboUniversalLink(query: String?) -> URL? {
        var components = URLComponents(string: "https://open.weibo.com/weibosdk/request")
        
        components?.query = query
        
        if let index = components?.queryItems?.firstIndex(where: { $0.name == "id" }) {
            components?.queryItems?[index].name = "objId"
        } else {
            assertionFailure()
            return nil
        }
        
        components?.queryItems?.append(
            .init(name: "urltype", value: "link")
        )
        
        return components?.url
    }
}
