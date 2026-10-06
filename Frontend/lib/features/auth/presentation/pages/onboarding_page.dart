import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Welcome to DCMS",
      "description": "Easily submit and track your academic complaints with institutional transparency.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuB3UohYIReaKwAPAhrmcYvgaRmB8i4bp9mFwKE8SoW5qmbqnNQYGiqkIzLAPtXe0LWr2zO0c6ahAuFxb4he5GF7AQjz5cO2DWAC6CAHd3AdiZspmEW2ie-yGbTBa1tNdiBCSJg3MdaMhbr9gAPLrulKDtMdWXsjOaOQDVL-fy32l-i-3P5lXAynA0BOSRe1YX2ejunm-54kdbCCIC1ekNz2HLIrOopf-NfpqId-UefiTxCsYP99eZn9XZtYAfjZOZiaRt0TlkFoYpVj"
    },
    {
      "title": "Real-time Updates",
      "description": "Get notified immediately when your complaint moves to the next administrative level.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuAEBaFBnczY6VVF_J45VWV9CEu6Hg9tXZqG68Rdb5Ol20r0uSL0qq88Tau2fWtW1pdsHHhX7H63U8-OJ9C_S6V8q9jYoVTfOzPY35ukJp7M72L-pWk3iXUdZYhEO_Sfgub9O-w38DkUKGq7npqI4OxgPstrDN2r3YikYDWBrKVtE2_5SVp1_eqKYslpzVOGOw-vmqJ_z7Pd4Z1vJQe1K-mocR19kLQtSFj6G0wePId_lOYVUEQcJduJBI3vK_yL9pDtOcVUq8eitcex"
    },
    {
      "title": "Department Notices",
      "description": "Stay updated with the latest announcements and directives from the Chairman.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuAKBlrlMGRwInbbIkzGEx2bersHm8CKpq6cX5r-33Dq__gv2IjZTW4e1DtCE8qmo8xT7mdEKXEi9yz3-SAxDjes9xlTRCjNoXmag76vbbcFsB2KjN7dhurzPEp9Tu7OqUcKw3wKrFQMnkAuLNFLd5jX1byWjaA41fiCBIf_Tf56iSDCFP0sI_V-USKAviaxFe-sMDzFF9BZbN6XtwXbV2c6tZAw-C2z38vSWJtSDMBGWQ6o0ZEVJTkryujJK_rq2MS7V69UhWh26tcQ"
    }
  ];

  void _nextPage() async {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Finished onboarding, set flag and go to splash
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dcms_onboarding_complete', true);
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    image: _onboardingData[index]["image"]!,
                    title: _onboardingData[index]["title"]!,
                    description: _onboardingData[index]["description"]!,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8.0),
                        height: 6,
                        width: _currentPage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _onboardingData.length - 1
                                ? "Get Started"
                                : "Next",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  // Intentionally removed "Skip" button based on user request.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
