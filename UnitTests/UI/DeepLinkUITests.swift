//
//  DeepLinkUITests.swift
//  UnitTests
//
//  Created by Alexey Naumov on 10.01.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import XCTest
import ViewInspector
import Combine
@testable import CountriesSwiftUI

final class DeepLinkUITests: XCTestCase {
    
    func test_countriesList_selectsCountry() {
        
        let store = appStateWithDeepLink()
        let services = mockedServices(store: store)
        let container = DIContainer(appState: store, services: services)
        let sut = CountriesList(viewModel: .init(container: container))
        let exp = sut.inspection.inspect(after: 0.1) { view in
            let firstRowLink = try view.firstRowLink()
            XCTAssertTrue(try firstRowLink.isActive())
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
    
    func test_countryDetails_presentsSheet() {
        
        let store = appStateWithDeepLink()
        let services = mockedServices(store: store)
        let container = DIContainer(appState: store, services: services)
        let sut = CountryDetails(viewModel: .init(container: container, country: Country.mockedData[0]))
        let exp = sut.inspection.inspect(after: 0.1) { view in
            XCTAssertNoThrow(try view.content().list())
            XCTAssertTrue(store.value.routing.countryDetails.detailsSheet)
        }
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 2)
    }
}

// MARK: - Setup

private extension DeepLinkUITests {
    
    func appStateWithDeepLink() -> Store<AppState> {
        let countries = Country.mockedData
        var appState = AppState()
        appState.routing.countriesList.countryDetails = countries[0].alpha3Code
        appState.routing.countryDetails.detailsSheet = true
        return Store(appState)
    }
    
    func mockedServices(store: Store<AppState>) -> DIContainer.Services {
        let countriesRepo = MockedCountriesWebRepository()
        countriesRepo.countriesResponse = .success(Country.mockedData)
        let details = Country.Details.Intermediate(capital: "", currencies: [], borders: [])
        countriesRepo.detailsResponse = .success(details)
        let imagesRepo = MockedImageWebRepository()
        let testImage = UIColor.red.image(CGSize(width: 40, height: 40))
        imagesRepo.imageResponse = .success(testImage)
        
        let countriesService = RealCountriesService(webRepository: countriesRepo, appState: store)
        let imagesService = RealImagesService(webRepository: imagesRepo)
        return DIContainer.Services(countriesService: countriesService,
                                       imagesService: imagesService)
    }
}
