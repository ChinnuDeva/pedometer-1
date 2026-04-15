import 'package:flutter/material.dart';

/// Butter Theme Color Palette
class ButterTheme {
  ButterTheme._();

  // Primary butter colors
  static const Color butterYellow = Color(0xFFFFF9C4);
  static const Color butterGold = Color(0xFFFFD54F);
  static const Color butterOrange = Color(0xFFFFB74D);
  static const Color butterCream = Color(0xFFFFFDE7);

  // Accent colors
  static const Color butterAccent = Color(0xFFFFAB40);
  static const Color butterPeach = Color(0xFFFFCC80);

  // Semantic colors
  static const Color butterSuccess = Color(0xFF81C784);
  static const Color butterError = Color(0xFFE57373);
  static const Color butterWarning = Color(0xFFFFB74D);
  static const Color butterInfo = Color(0xFF64B5F6);

  // Dark theme colors
  static const Color butterDark = Color(0xFF2C2C2C);
  static const Color butterDarkSurface = Color(0xFF3C3C3C);
  static const Color butterDarkCard = Color(0xFF4C4C4C);

  // Gradients
  static const LinearGradient butterGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [butterGold, butterOrange],
  );

  static const LinearGradient butterGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [butterCream, butterYellow],
  );

  static const LinearGradient smoothCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFBF0),
      Color(0xFFFFF8E1),
    ],
  );

  // Animation durations
  static const Duration butterSmoothDuration = Duration(milliseconds: 300);
  static const Duration butterFastDuration = Duration(milliseconds: 150);
  static const Duration butterSlowDuration = Duration(milliseconds: 500);

  // Curves for buttery smooth animations
  static const Curve butterSmoothCurve = Curves.easeOutCubic;
  static const Curve butterBounceCurve = Curves.elasticOut;
}

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ButterTheme.butterGold,
        brightness: Brightness.light,
        primary: ButterTheme.butterGold,
        secondary: ButterTheme.butterOrange,
        tertiary: ButterTheme.butterAccent,
        surface: ButterTheme.butterCream,
        error: ButterTheme.butterError,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFF8),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ButterTheme.butterDark,
          fontSize: 20,
           fontWeight: FontWeight.w600,
  ),
  iconTheme: IconThemeData(color: ButterTheme.butterDark),
),
cardTheme: CardTheme(
cardTheme: CardThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
        color: Colors.white,
        shadowColor: ButterTheme.butterGold.withOpacity(0.2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ButterTheme.butterGold,
          foregroundColor: ButterTheme.butterDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ButterTheme.butterGold,
          side: const BorderSide(color: ButterTheme.butterGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ButterTheme.butterOrange,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ButterTheme.butterGold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ButterTheme.butterGold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ButterTheme.butterCream,
        selectedColor: ButterTheme.butterGold,
        labelStyle: const TextStyle(color: ButterTheme.butterDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ButterTheme.butterDark,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ButterTheme.butterDark,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ButterTheme.butterDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ButterTheme.butterDark,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ButterTheme.butterDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ButterTheme.butterDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ButterTheme.butterDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ButterTheme.butterGold,
        brightness: Brightness.dark,
        primary: ButterTheme.butterGold,
        secondary: ButterTheme.butterOrange,
        tertiary: ButterTheme.butterAccent,
        surface: ButterTheme.butterDarkSurface,
        error: ButterTheme.butterError,
      ),
      scaffoldBackgroundColor: ButterTheme.butterDark,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
  ),
  iconTheme: IconThemeData(color: Colors.white),
),
cardTheme: CardTheme(
cardTheme: CardThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
        ),
        color: ButterTheme.butterDarkCard,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ButterTheme.butterGold,
          foregroundColor: ButterTheme.butterDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ButterTheme.butterDarkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ButterTheme.butterGold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// Page transition helpers for buttery smooth navigation
class PageTransitions {
  PageTransitions._();

  static Route<T> butterySmooth<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: ButterTheme.butterSmoothDuration,
      reverseTransitionDuration: ButterTheme.butterSmoothDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: ButterTheme.butterSmoothCurve,
          reverseCurve: ButterTheme.butterSmoothCurve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static Route<T> butterySlideUp<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: ButterTheme.butterSmoothDuration,
      reverseTransitionDuration: ButterTheme.butterSmoothDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: ButterTheme.butterSmoothCurve,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  static Route<T> butteryScale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: ButterTheme.butterSmoothDuration,
      reverseTransitionDuration: ButterTheme.butterSmoothDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: ButterTheme.butterSmoothCurve,
          reverseCurve: Curves.easeInCubic,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Animated widget helpers
class ButterAnimatedWidget extends StatelessWidget {
  const ButterAnimatedWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration,
    this.verticalOffset = 20,
  });

  final Widget child;
  final Duration delay;
  final Duration? duration;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? ButterTheme.butterSmoothDuration,
      curve: ButterTheme.butterSmoothCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, verticalOffset * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
