//
//  DeviceIdiomView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 19/09/2021.
//

import SwiftUI

struct DeviceIdiomView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            MainView()
        } else {
            if horizontalSizeClass == .compact {
                MainView()
            } else {
                MainPadDeviceView()
            }
        }
        
    }
}

struct DeviceIdiomView_Previews: PreviewProvider {
    static var previews: some View {
//        DeviceIdiomView()
        
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Air (3rd generation)"))
            .environment(\.horizontalSizeClass, .regular)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "iPad Air (3rd generation)"))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
