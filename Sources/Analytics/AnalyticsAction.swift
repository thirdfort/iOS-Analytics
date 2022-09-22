import SwiftUI

/// An action that logs an analytics event
///
/// When the ``EnvironmentValues/analytics`` environment value contains an instance
/// of this structure, your ``SwiftUI/View`` can log analytics events.
///
///     struct ContactDetailView: View {
///         @Environment(\.analytics) private var log
///
///         var body: some View {
///             List {
///                 Button("Submit") {
///                     log(.interaction)
///                 }
///             }
///             .onAppear {
///                 log(.view)
///             }
///         }
///     }
///
/// Sometimes you need custom logging behaviour, this can be achieved by defining a custom log method:
///
///     extension Analytics {
///         struct Interaction: RawRepresentable {
///             static var submit: Self { .init(rawValue: "submit") }
///         }
///     }
///
/// Then extend the action to include a custom `log` method that accepts your type:
///
///     extension AnalyticsAction {
///         // we define a custom `log` method here to append additional params automatically
///         func callAsFunction(interaction: Analytics.Interaction) {
///             var values = self.values
///             values[keyPath: \.interaction, interaction)
///             callAsFunction(event: .interaction, appending: values)
///         }
///     }
///
public struct AnalyticsAction: Sendable {
    /// The current set of values
    public private(set) var values: AnalyticsValues

    /// Logs the specified `event`
    /// - Parameters:
    ///    - event: The `event` to log
    ///    - appending: Any extra `values` to log with the existing `AnalyticsValues`
    public mutating func callAsFunction(_ event: AnalyticsEvent, appending newValues: AnalyticsValues? = nil) {
        if let newValues = newValues {
            values.appending(newValues)
        }
        Analytics.log(event: event, values: values)
    }
    
    /// Logs the specified `event`
    /// - Parameters:
    ///    - event: The `event` to log
    ///    - replacing: Any `values` to replace the existing `AnalyticsValues` in the `Environment`
    public mutating func callAsFunction(_ event: AnalyticsEvent, replacing values: AnalyticsValues?) {
        Analytics.log(event: event, values: values ?? .init())
    }
}

public extension EnvironmentValues {
    /// Returns the current analytics action for logging events
    ///
    ///     struct ContactDetailView: View {
    ///         @Environment(\.analytics) private var log
    ///         var body: some View {
    ///             List {
    ///                 Button("Submit") {
    ///                     log(interaction: .submit)
    ///                 }
    ///             }
    ///             .onAppear {
    ///                 log(view: .contactDetail)
    ///             }
    ///         }
    ///     }
    ///
    var analytics: AnalyticsAction {
        .init(values: analyticsValues)
    }
}
