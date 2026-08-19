import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/onboarding_page_data.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_page_view.dart';

class OnboardingScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class OnboardingPage extends StatefulWidget {
  final OnboardingBloc? onboardingBloc;
  final List<OnboardingPageData> pages;

  const OnboardingPage({
    super.key,
    this.onboardingBloc,
    this.pages = OnboardingPageData.defaultPages,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  late final OnboardingBloc _bloc;
  bool _isInternalBloc = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.onboardingBloc != null) {
      _bloc = widget.onboardingBloc!;
    } else {
      try {
        _bloc = sl<OnboardingBloc>();
      } catch (_) {
        _bloc = OnboardingBloc(localDataSource: sl());
        _isInternalBloc = true;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_isInternalBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  void _handleNext() {
    final nextIndex = (_pageController.page?.round() ?? 0) + 1;
    if (nextIndex < widget.pages.length) {
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _handleGetStarted();
    }
  }

  void _handleDotTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleGetStarted() {
    _bloc.add(const OnboardingCompletedEvent());
    context.go('/register');
  }

  void _handleLogin() {
    _bloc.add(const OnboardingCompletedEvent());
    context.go('/login');
  }

  void _handleSkip() {
    _bloc.add(const OnboardingSkippedEvent());
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ScrollConfiguration(
          behavior: OnboardingScrollBehavior(),
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              return PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemCount: widget.pages.length,
                onPageChanged: (index) {
                  _bloc.add(OnboardingPageChanged(index));
                },
                itemBuilder: (context, index) {
                  final pageData = widget.pages[index];
                  return OnboardingPageViewItem(
                    pageData: pageData,
                    pageIndex: index,
                    totalPages: widget.pages.length,
                    onSkip: _handleSkip,
                    onNext: _handleNext,
                    onGetStarted: _handleGetStarted,
                    onLogin: _handleLogin,
                    onDotTapped: _handleDotTapped,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
