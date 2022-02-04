//
//  weatherTests.swift
//  weatherTests
//
//  Created by Lina on 2/2/22.
//

import XCTest
@testable import weather

struct ListMock: DateContaining, Equatable {
    let dt: Int
}


class weatherTests: XCTestCase {

    func testForecastFilter() {

        let list: [ListMock] = [

            ListMock(dt: 1643835600),
            ListMock(dt: 1643857200),
            ListMock(dt: 1643922000)
        ]

        //not optimal because function lives everywhere but okay for Linas knowledge right now
        let filteredList = filterNoon(unfilteredList: list)
        let expectedList: [ListMock] = [

            ListMock(dt: 1643835600),
            ListMock(dt: 1643922000)
        ]

        XCTAssertEqual(filteredList, expectedList)
    }

}
