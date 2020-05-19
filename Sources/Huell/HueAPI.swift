import Foundation
import Siesta

enum NetworkError: Error {
    case serviceNotInitialized
    case noUsernameInAuthResponse
    case hueAPIError(type: APIErrorType?)
    case cannotEncodeModelRequest
    case failedToSetGroupState
    case genericError
}

enum APIErrorType: Int {
    case bridgeButtonNotHeldDown = 101
    case bodyContainsInvalidJson = 2
}

public class HueAPI {
    public static let sharedInstance = HueAPI(baseIP: Constants.currentBridgeIP, authTokenUsername: Constants.authToken)

    static var emulated: Bool = false
    
    public var authToken: String?
    
    fileprivate var liveService: Service?
    fileprivate var emulatedService: Service?
    var activeDays: DaysOfWeekActive = .allDays
    
    public var baseIP: String?
    
    // signifies if we have a connection to the bridge
    fileprivate var canConnect: Bool?
    
    public var authTokenUsername: String? {
        if HueAPI.emulated {
            return Constants.emulatedAuthToken
        } else {
            return authToken
        }
    }
        
    public var service: Service? {
        if HueAPI.emulated {
            return emulatedService
        } else {
            return liveService
        }
    }
    
    var currentCircadianScheduleIds: [String]?
    var currentSceneIds: [String]?
    
    var hueRFC3339Formatter: DateFormatter {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return RFC3339DateFormatter
    }
    
    var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(hueRFC3339Formatter)
        return decoder
    }
    
    public func reloadSchedulesResource() throws {
        guard let service = service else {
            throw NetworkError.serviceNotInitialized
        }
        reloadSchedulesResource(withService: service)
    }
    
    public func reloadSchedulesResource(withService service: Service) {
        service.resource(schedulesEndpoint).loadIfNeeded()
    }
    
    public func startPolling() {
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(pollHueBridge), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func pollHueBridge() throws {
        guard let service = service else {
            throw NetworkError.serviceNotInitialized
        }
        
        // basic GET to test if we're connected
        service.resource(lightsEndpoint).request(.get).onSuccess({
            _ in
            HueAPI.sharedInstance.canConnect = true
        }).onFailure({
            _ in
            HueAPI.sharedInstance.canConnect = false
        })
    }
    
    init(baseIP: String?, authTokenUsername: String?) {
        self.baseIP = baseIP
        self.authToken = authTokenUsername
        
        if let baseIP = self.baseIP {
            liveService = service(withBaseIP: baseIP)
        }
        
        // bridge emulation
        self.emulatedService = service(withBaseIP: Constants.emulatedIP)
        
        try? configureListeners()
    }
    
    public func clearAPIUsername() {
        authToken = nil
    }
    
    // TODO: unpublic?
    public func configureServiceAndAuthenticate(withBaseIP baseIP: String, deviceType: String) -> Request {
        liveService = service(withBaseIP: baseIP)
        try? configureListeners()
        return try! authenticate(withDeviceType: deviceType).onSuccess({
            entity in
                if let response = self.successResponseDict(fromHueResponseArray: entity.jsonArray as! [[AnyHashable : Any]]) {
                    if let username = response["username"] as? String {
                        self.authToken = username
                    }
                }
        }).onFailure({
            error in
            print("Network error: \(error)")
        })
    }
    
    fileprivate func configureListeners() throws {
        guard let service = service else {
            throw NetworkError.serviceNotInitialized
        }
        
        listenForSchedulesResource(withService: service)
    }
    
    // http://<bridge IP address>/
    public func service(withBaseIP baseIP: String) -> Service {
        var service = Service(baseURL: "http://\(baseIP)", standardTransformers: [.text, .image])
        service = configureTransformers(forService: service)
        
        return service
    }
    
    fileprivate func configureTransformers(forService service: Service) -> Service {
        service.configure {
            $0.pipeline[.rawData].add(SuccessIfResponseDictNotErrorTransformer())
        }
        
        // authentication needs json to start with
        service.configure(authEndpoint) {
            $0.pipeline[.rawData].add(JSONResponseTransformer())
        }
        
        service.configureTransformer(allDevicesActionEndpoint) {
            try HueAPI.sharedInstance.jsonDecoder.decode([GroupResponse].self, from: $0.content)
        }
        
        return service
    }
    
    public func authenticate(withDeviceType deviceType: String) throws -> Request {
        guard let service = service else {
            throw NetworkError.serviceNotInitialized
        }
        
        return service.resource(authEndpoint).request(.post, text: "{\"devicetype\":\"\(Constants.deviceType)\"}")
    }
}

// MARK: endpoint strings
extension HueAPI {
     var lightsEndpoint: String {
        get {
            return "/api/\(authTokenUsername ?? "")/lights"
        }
    }
    
    func singleScheduleEndpoint(forScheduleId id: String) -> String {
        return "/api/\(authTokenUsername ?? "")/schedules/\(id)"
    }
    
    var schedulesEndpoint: String {
        get {
            return "/api/\(authTokenUsername ?? "")/schedules"
        }
    }
    
    var authEndpoint: String {
        get {
            return "/api"
        }
    }
    
    // ep to perform action on all devices
    var allDevicesActionEndpoint: String {
        get {
            return "/api/\(authTokenUsername ?? "")/groups/0/action"
        }
    }
}

// MARK: response handling
extension HueAPI {
    fileprivate func successResponseDict(fromHueResponseArray array: [[AnyHashable : Any]]) -> [AnyHashable : Any]? {
        if array.count > 0 {
            let firstEl = array[0]
            let successDict = firstEl["success"] as? [AnyHashable : Any]
            return successDict
        } else {
            return nil
        }
    }
}
