import SwiftUI

// MARK: - Loading State
enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    
    var isLoading: Bool {
        self == .loading
    }
    
    var hasError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Restaurant Card Skeleton
struct RestaurantCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image skeleton
            SkeletonView(width: .infinity, height: 200)
                .cornerRadius(16, corners: [.topLeft, .topRight])
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        SkeletonView(width: 150, height: 20)
                        SkeletonView(width: 100, height: 16)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        SkeletonView(width: 60, height: 16)
                        SkeletonView(width: 80, height: 14)
                    }
                }
                
                HStack {
                    SkeletonView(width: 120, height: 14)
                    
                    Spacer()
                    
                    SkeletonView(width: 100, height: 14)
                }
            }
            .padding(16)
            .background(Color.black.opacity(0.3))
            .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }
} 