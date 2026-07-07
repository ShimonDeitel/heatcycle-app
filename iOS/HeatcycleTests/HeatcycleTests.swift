import XCTest
@testable import Heatcycle

@MainActor
final class HeatcycleTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataLoaded() {
        XCTAssertGreaterThanOrEqual(store.entries.count, 3)
    }

    func testFreeLimitAboveSeedCount() {
        XCTAssertGreaterThan(Store.freeLimit, 3)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(CycleEntry())
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testDeleteEntryDecreasesCount() {
        store.add(CycleEntry())
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }

    func testCanAddMoreWhenUnderLimit() {
        store.entries = []
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreWhenAtLimitAndNotPro() {
        store.entries = (0..<Store.freeLimit).map { _ in CycleEntry() }
        store.isPro = false
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenProEvenAtLimit() {
        store.entries = (0..<Store.freeLimit).map { _ in CycleEntry() }
        store.isPro = true
        XCTAssertTrue(store.canAddMore)
    }

    func testUpdateEntryPersistsChange() {
        let entry = CycleEntry()
        store.add(entry)
        let updated = entry
        store.update(updated)
        XCTAssertEqual(store.entries.first?.id, entry.id)
    }
}
