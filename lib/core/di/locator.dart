import 'package:get_it/get_it.dart';
import '../network/http_client.dart';
import '../config/app_config.dart';

// User
import '../../features/user/data/user_service.dart';
import '../../features/user/data/user_repository.dart';

// Auth
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_controller.dart';

// OLTs (nuevos)
import '../../features/olts/data/olts_service.dart';
import '../../features/olts/data/olts_repository.dart';
import '../../features/olts/presentation/olts_controller.dart';
final locator = GetIt.instance;

void setupLocator() {
  // Core
  locator.registerLazySingleton<HttpClient>(() => HttpClient());

  // Services
  locator.registerLazySingleton<UserService>(
        () => UserService(locator<HttpClient>(), baseUrl: AppConfig.baseUrl),
  );
  locator.registerLazySingleton<AuthService>(
        () => AuthService(
      locator<HttpClient>(),
      baseUrl: AppConfig.baseUrl,
      token: AppConfig.apiToken,
    ),
  );
  locator.registerLazySingleton<OltsService>(
        () => OltsService(
      locator<HttpClient>(),
      baseUrl: AppConfig.baseUrl,
      token: AppConfig.apiToken,
      path: AppConfig.oltsPath,
    ),
  );

  // Repositories
  locator.registerLazySingleton<UserRepository>(() => UserRepository(locator<UserService>()));
  locator.registerLazySingleton<AuthRepository>(() => AuthRepository(locator<AuthService>()));
  locator.registerLazySingleton<OltsRepository>(() => OltsRepository(locator<OltsService>()));
  // Controllers
  locator.registerLazySingleton<AuthController>(() => AuthController(locator<AuthRepository>()));
  locator.registerLazySingleton<OltsController>(() => OltsController(locator<OltsRepository>()));
}
