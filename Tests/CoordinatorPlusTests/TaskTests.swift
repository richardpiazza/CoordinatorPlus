import XCTest
@testable import CoordinatorPlus

class TaskTests: XCTestCase {
    
    static var allTests = [
        ("testTaskIsEqual", testTaskIsEqual)
    ]
    
    private enum TestTask: Int, Flow {
        case alpha
        case beta
        case gamma
        case delta
    }
    
    func testTaskIsEqual() {
        let alpha = TestTask.alpha
        let beta = TestTask.beta
        
        XCTAssertNotEqual(alpha, beta)
        XCTAssertNotEqual(alpha.rawValue, beta.rawValue)
        XCTAssertFalse(alpha.isEqual(beta))
    }
}
