//
//  weatherTests.swift
//  weatherTests
//
//  Created by Lina on 2/2/22.
//

import XCTest
@testable import weather

struct ListMock: DateContaining, Equatable {
    let dt: Double
}


class weatherTests: XCTestCase {

    func testForecastFilter() {

        let list: [ListMock] = [

            ListMock(dt: 1643835600.0),
            ListMock(dt: 1643857200.0),
            ListMock(dt: 1643922000.0)
        ]

        //not optimal because function lives everywhere but okay for Linas knowledge right now
        let filteredList = filterNoon(unfilteredList: list)

        let expectedList: [ListMock] = [

            ListMock(dt: 1643835600.0),
            ListMock(dt: 1643922000.0)
        ]

        XCTAssertEqual(filteredList, expectedList)

     //   XCTAssert(filteredList.count == 2)
    }

}
