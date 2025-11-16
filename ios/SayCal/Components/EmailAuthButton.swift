//
//  EmailAuthButton.swift
//  SayCal
//
//  Created by Luke on 11/15/25.
//

import SwiftUI

struct EmailAuthButton: View {
    @State private var showEmailAuth = false

    var body: some View {
        Button {
            showEmailAuth = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Continue with Email")
                    .font(.system(size: 22, weight: .medium))
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color(.systemGray5))
            .cornerRadius(16)
        }
        .sheet(isPresented: $showEmailAuth) {
            EmailAuthView()
        }
    }
}

#Preview {
    EmailAuthButton()
}
