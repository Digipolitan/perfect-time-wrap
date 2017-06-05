import PerfectMiddleware
import PerfectHTTP
import PerfectLib
import Foundation

/**
 * The handler that must log the request
 */
public typealias TimeWrapHandler = (TimeWrap.Info, HTTPRequest, HTTPResponse) -> (String)

/**
 * HTTP request logger middleware for perfect swift middleware
 * @author Benoit BRIATTE http://www.digipolitan.com
 * @copyright 2017 Digipolitan. All rights reserved.
 */
open class TimeWrap {

    /**
     * Info object, this object store start & end date of the request
     * Retrieves an instance of this class using context.timeWrap method
     */
    public class Info {

        /**
         * Retrieves the request start date
         */
        public fileprivate(set) var startDate: Date?

        /**
         * Retrieves the request end date
         */
        public fileprivate(set) var endDate: Date?

        /**
         * Get the request duration
         */
        public func duration() -> Double {
            guard let st = self.startDate,
                    let et = self.endDate else {
                return 0
            }
            return et.timeIntervalSince(st) * 1000
        }
    }

    /**
     * TimeWrap consts
     */
    public enum Consts {

        /** Retrieves the key for the Info object inside the route context */
        public static let infoKey = "time_wrap_info"

        /** Retrieves the default options */
        public static let options: Options = Options()

        /** Retrieves the default handler, display a console log */
        public static let handler: TimeWrapHandler = { info, req, res in
            return String(format: "\(req.method) \(req.path) \(res.status) %.3f ms", info.duration())
        }
    }

    /**
     * TimeWrap options
     */
    public struct Options {

        /**
         * Retrieves the request log handler
         */
        public let handler: TimeWrapHandler

        /**
         * Init the TimeWrap option
         * @param handler Set the handler method, default : Consts.handler
         */
        public init(handler: @escaping TimeWrapHandler = Consts.handler) {
            self.handler = handler
        }
    }

    /**
     * Use this method to register the TimeWrap middleware
     * Cannot set this middleware using router.use because we need to trigger the middleware 2 times (before and after all routes)
     * @param router The router middleware
     * @param options Log options, default : Consts.options
     */
    public static func use(in router: RouterMiddleware, options: Options = Consts.options) {
        router.use(event: .beforeAll) { context in
            if context.timeWrap.startDate == nil {
                context.timeWrap.startDate = Date()
            }
            context.next()
         }
        router.use(event: .afterAll) { context in
            let info = context.timeWrap
            if context.timeWrap.endDate == nil {
                info.endDate = Date()
            }
            Log.info(message: options.handler(info, context.request, context.response))
            context.next()
        }
    }

    /**
     * Cannot be instanciate
     */
    private init() {}
}

/**
 * Add TimeWrap support to the route context
 */
public extension RouteContext {

    /**
     * Access to data stored by TimeWrap (Info object)
     */
    public var timeWrap: TimeWrap.Info {
        if let info = self[TimeWrap.Consts.infoKey] as? TimeWrap.Info {
            return info
        }
        let info = TimeWrap.Info()
        self[TimeWrap.Consts.infoKey] = info
        return info
    }
}
