import 'package:_core/core.dart';
import 'package:_env/env.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:powersync_repo/src/src.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// {@template powersync_repo}
/// A package that manages connection to the PowerSync cloud service and
/// database.
///
/// The [PowersyncRepo] class is responsible for managing the local
/// database and interacting with the Supabase client.
/// {@endtemplate}
class PowersyncRepo {
  /// Initializes a new instance of the [PowersyncRepo] class.
  PowersyncRepo({required this.env});

  /// Environment values.
  final EnvValue env;

  bool _isInitialized = false;

  late final PowerSyncDatabase _db;

  /// The Supabase client.
  late final supabase = Supabase.instance.client;

  /// Initializes the local database and opens a new instance of the database.
  Future<void> initialize({bool offlineMode = false}) async {
    if (!_isInitialized) {
      await _openDatabase();
      _isInitialized = true;
    }
  }

  /// Returns the PowerSync database instance.
  PowerSyncDatabase db() {
    if (!_isInitialized) {
      throw Exception(
        'PowerSyncDatabase not initialized. Call initialize() first.',
      );
    }
    return _db;
  }

  /// Checks if a user is logged in.
  bool isLoggedIn() {
    return supabase.auth.currentSession?.accessToken != null;
  }

  /// Returns the relative directory of the local database.
  Future<String> getDatabasePath() async {
    final dir = await getApplicationSupportDirectory();
    return join(dir.path, 'flutter-instagram-offline-first.db');
  }

  /// Loads the Supabase client with the provided environment values.
  Future<void> _loadSupabase() async {
    await Supabase.initialize(
      url: env(Env.supabaseUrl),
      anonKey: env(Env.supabaseAnonKey),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  }

  /// Opens the local database, initializes the Supabase client, and connects
  /// to the database if the user is logged in.
  Future<void> _openDatabase() async {
    _db = PowerSyncDatabase(
      schema: schema,
      path: await getDatabasePath(),
    );
    await _db.initialize();

    await _loadSupabase();

    SupabaseConnector? currentConnector;

    if (isLoggedIn()) {
      currentConnector = SupabaseConnector(_db, env: env);
      await _db.connect(connector: currentConnector);
    }

    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.passwordRecovery) {
        logD('Connect to PowerSync');
        currentConnector = SupabaseConnector(_db, env: env);
        await _db.connect(connector: currentConnector!);
      } else if (event == AuthChangeEvent.signedOut) {
        currentConnector = null;
        await _db.disconnect();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        await currentConnector?.prefetchCredentials();
      }
    });
  }

  /// Returns a stream of authentication state changes from the Supabase client.
  Stream<AuthState> authStateChanges() =>
      supabase.auth.onAuthStateChange.asBroadcastStream();

  /// Updates the user app metadata.
  Future<void> updateUser({
    String? email,
    String? phone,
    String? password,
    String? nonce,
    Object? data,
  }) =>
      supabase.auth.updateUser(
        UserAttributes(
          email: email,
          phone: phone,
          password: password,
          nonce: nonce,
          data: data,
        ),
      );

  /// Sends a password reset email to the specified email address.
  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) =>
      supabase.auth.resetPasswordForEmail(email, redirectTo: redirectTo);

  /// Verifies the OTP token for password recovery.
  Future<void> verifyOTP({
    required String token,
    required String email,
  }) =>
      supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
}
