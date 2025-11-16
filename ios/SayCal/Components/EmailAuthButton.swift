//
//  EmailAuthButton.swift
//  SayCal
//
//  Created by Luke on 11/15/25.
//

import SwiftUI

struct EmailAuthButton: View {
    var body: some View {
        Button {
            // TODO: Implement Email Sign-In
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
    }
}

#Preview {
    EmailAuthButton()
}
