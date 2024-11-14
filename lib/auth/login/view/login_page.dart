import 'package:_core/core.dart';
import 'package:_env/env.dart';
import 'package:demo_app/app/app.dart';
import 'package:demo_app/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return const Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GoogleSignInButton(),
                  SizedBox(height: 16),
                  LogOutButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  Future<void> _signInWithGoogle() async {
    final iOSClientId = getIt<AppFlavor>().getEnv(Env.iOSClientId);
    final webClientId = getIt<AppFlavor>().getEnv(Env.webClientId);

    final googleSignIn = GoogleSignIn(
      clientId: iOSClientId,
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    if (googleAuth == null) {
      throw Exception('Google sign in failed');
    }
    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      throw Exception('Google sign in failed, tokens are null');
    }
    final accessToken = googleAuth.accessToken!;
    final idToken = googleAuth.idToken!;

    await Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      accessToken: accessToken,
      idToken: idToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await _signInWithGoogle();
        } catch (error, stackTrace) {
          logE(
            'Google sign in failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      },
      label: Text(
        'Sign in with Google',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      icon: const Icon(Icons.login),
    );
  }
}

class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  void _logOut() => Supabase.instance.client.auth.signOut();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      // initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session == null) {
            return const SizedBox.shrink();
          }
          return ElevatedButton.icon(
            onPressed: _logOut,
            label: Text(
              'Log out',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                  ),
            ),
            icon: const Icon(Icons.logout),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
