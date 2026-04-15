import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_pedometer/core/constants/butter_theme.dart';
import 'package:word_pedometer/features/authentication/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFF8),
                  Color(0xFFFFFDF5),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: ButterTheme.butterGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: ButterTheme.butterGold.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Word Pedometer',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your English speaking accuracy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const Spacer(),
                    _buildFeaturesList(context),
                    const SizedBox(height: 32),
                    _buildGoogleSignInButton(context, state),
                    const SizedBox(height: 12),
                    _buildDemoSignInButton(context, state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {'icon': Icons.mic, 'text': 'Record your speech'},
      {'icon': Icons.check_circle, 'text': 'Analyze grammar mistakes'},
      {'icon': Icons.trending_up, 'text': 'Track daily accuracy'},
      {'icon': Icons.history, 'text': 'View correction history'},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                feature['icon'] as IconData,
                color: ButterTheme.butterGold,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                feature['text'] as String,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                context.read<AuthBloc>().add(const AuthSignInRequested());
              },
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.g_mobiledata, size: 28),
        label: Text(isLoading ? 'Signing in...' : 'Sign in with Google'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ButterTheme.butterGold,
          foregroundColor: ButterTheme.butterDark,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDemoSignInButton(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                context.read<AuthBloc>().add(const AuthSignInWithDemoRequested());
              },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Try Demo Mode'),
        style: OutlinedButton.styleFrom(
          foregroundColor: ButterTheme.butterOrange,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: ButterTheme.butterOrange.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
