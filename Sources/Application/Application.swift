import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health
import KituraOpenAPI

public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
    let router = Router()
    let cloudEnv = CloudEnv()

    var counter: Int = 0;
    
    public init() throws {
        // Run the metrics initializer
        initializeMetrics(router: router)
    }

    func postInit() throws {
        // Endpoints
        self.router.post("/counter") { (request, response, next) in
            self.counter += 1
            response.send("\(String(self.counter))")
            next()
        }
        
        self.router.get("/counter") { (request, response, next) in
            response.send("\(String(self.counter))")
            next()
        }
        
        initializeHealthRoutes(app: self)
        KituraOpenAPI.addEndpoints(to: router)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}
