//
//  RootViewModifier.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 09.11.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - RootViewAppearance

struct RootViewAppearance: ViewModifier {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    func body(content: Content) -> some View {
        content
            .blur(radius: viewModel.isActive ? 0 : 10)
    }
}

extension RootViewAppearance {
    class ViewModel: ObservableObject {
        
        @Published var isActive: Bool = false
        private let cancelBag = CancelBag()
        
        init(container: DIContainer) {
            container.appState.map(\.system.isActive)
                .assign(to: \.isActive, on: self)
                .store(in: cancelBag)
        }
    }
}
