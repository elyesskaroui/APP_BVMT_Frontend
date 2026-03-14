import 'package:bvmt/core/services/local_storage_service.dart';
import 'package:get_it/get_it.dart';

/// Mock de LocalStorageService pour les tests (stockage en mémoire)
class MockLocalStorageService extends LocalStorageService {
  bool _onboardingSeen = false;
  bool _loggedIn = false;
  String? _name;

  @override
  Future<void> init() async {}

  @override
  bool get hasSeenOnboarding => _onboardingSeen;

  @override
  void setOnboardingSeen() => _onboardingSeen = true;

  @override
  bool get isLoggedIn => _loggedIn;

  @override
  String? get userName => _name;

  @override
  void setLoggedIn(String name) {
    _loggedIn = true;
    _name = name;
  }

  @override
  void setLoggedOut() {
    _loggedIn = false;
    _name = null;
  }

  @override
  void clearAll() {
    _onboardingSeen = false;
    _loggedIn = false;
    _name = null;
  }
}

/// Configure GetIt pour les tests avec un MockLocalStorageService
MockLocalStorageService setupTestDependencies() {
  final sl = GetIt.instance;
  if (sl.isRegistered<LocalStorageService>()) {
    sl.unregister<LocalStorageService>();
  }
  final mockStorage = MockLocalStorageService();
  sl.registerSingleton<LocalStorageService>(mockStorage);
  return mockStorage;
}

/// Nettoie GetIt après les tests
void tearDownTestDependencies() {
  final sl = GetIt.instance;
  if (sl.isRegistered<LocalStorageService>()) {
    sl.unregister<LocalStorageService>();
  }
}
