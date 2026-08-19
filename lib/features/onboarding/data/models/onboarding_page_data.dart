import 'package:equatable/equatable.dart';

class OnboardingPageData extends Equatable {
  final String image;
  final bool showLocationPill;
  final String? locationText;
  final String title;
  final String subtitle;
  final bool showButtons;

  const OnboardingPageData({
    required this.image,
    this.showLocationPill = false,
    this.locationText,
    required this.title,
    required this.subtitle,
    this.showButtons = false,
  });

  static const List<OnboardingPageData> defaultPages = [
    OnboardingPageData(
      image: 'assets/images/onboarding_1.jpg',
      showLocationPill: true,
      locationText: 'Cabinet Central, Paris',
      title: 'Sterilization\n& Stock Tracking',
      subtitle: 'Complete traceability for your dental practice. Scan, track, and audit every instrument.',
      showButtons: false,
    ),
    OnboardingPageData(
      image: 'assets/images/onboarding_2.jpg',
      showLocationPill: false,
      title: 'Never Miss\nan Expiration',
      subtitle: 'Automatic alerts for DLC, sterilization cycles, and low stock levels.',
      showButtons: false,
    ),
    OnboardingPageData(
      image: 'assets/images/onboarding_3.jpg',
      showLocationPill: false,
      title: 'Scan & Record\nin Seconds',
      subtitle: 'Use your camera to scan instrument labels and record usage instantly.',
      showButtons: false,
    ),
    OnboardingPageData(
      image: 'assets/images/onboarding_4.jpg',
      showLocationPill: false,
      title: 'Compliance\nMade Simple',
      subtitle: 'Full audit trails, sterilization validation, and regulatory readiness.',
      showButtons: true,
    ),
  ];

  @override
  List<Object?> get props => [
        image,
        showLocationPill,
        locationText,
        title,
        subtitle,
        showButtons,
      ];
}
