import XCTest
@testable import CoordinatorPlus

class TaskTests: XCTestCase {
    
    private enum TestTask: Int, Task {
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
