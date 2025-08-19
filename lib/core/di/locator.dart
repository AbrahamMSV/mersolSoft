import 'package:get_it/get_it.dart';
import '../network/http_client.dart';
import '../config/app_config.dart';

// Auth / User / OLTs (existentes)
import '../../features/user/data/user_service.dart';
import '../../features/user/data/user_repository.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/olts/data/olts_service.dart';
import '../../features/olts/data/olts_repository.dart';
import '../../features/olts/presentation/olts_controller.dart';

// NUEVO: foto por OLT
import '../../features/olt_photo/data/olt_photo_service.dart';
import '../../features/olt_photo/data/olt_photo_repository.dart';
import '../../features/olt_photo/presentation/olt_photo_controller.dart';
//SESSION STORE
import '../session/session_store.dart';

//DIAGNOSTICO ORDENSERVICIO
import '../../features/diagnostico_ordenservicio/data/diagnostico_service.dart';
import '../../features/diagnostico_ordenservicio/data/diagnostico_repository.dart';
import '../../features/diagnostico_ordenservicio/presentation/diagnostico_controller.dart';
//FORM DIAGNOSTICO
import '../../features/form_diagnostico/data/form_diagnostico_service.dart';
import '../../features/form_diagnostico/data/form_diagnostico_repository.dart';
import '../../features/form_diagnostico/presentation/form_diagnostico_controller.dart';
final locator = GetIt.instance;
void setupLocator() {
  // Core
  locator.registerLazySingleton<HttpClient>(() => HttpClient());

  // Services
  locator.registerLazySingleton<UserService>(
        () => UserService(locator<HttpClient>(), baseUrl: AppConfig.baseUrl),
  );
  locator.registerLazySingleton<AuthService>(
        () => AuthService(locator<HttpClient>(), baseUrl: AppConfig.baseUrl, asignar: AppConfig.asignarPath),
  );
  locator.registerLazySingleton<OltsService>(
        () => OltsService(locator<HttpClient>(), baseUrl: AppConfig.baseUrl, asignar: AppConfig.asignarPath),
  );
  // NUEVO
  locator.registerLazySingleton<OltPhotoService>(
        () => OltPhotoService(
      locator<HttpClient>(),
      baseUrl: AppConfig.baseUrl,
      asignarPath: AppConfig.asignarPath,
    ),
  );
// Diagnóstico (listado)
  locator.registerLazySingleton<DiagnosticoService>(() => DiagnosticoService(
    locator<HttpClient>(),
    baseUrl: AppConfig.baseUrl,
    asignarPath: AppConfig.asignarPath,
  ));
  // Repositories
  locator.registerLazySingleton<UserRepository>(() => UserRepository(locator<UserService>()));
  locator.registerLazySingleton<AuthRepository>(() => AuthRepository(locator<AuthService>()));
  locator.registerLazySingleton<OltsRepository>(() => OltsRepository(locator<OltsService>()));
  // NUEVO
  locator.registerLazySingleton<OltPhotoRepository>(
        () => OltPhotoRepository(locator<OltPhotoService>()),
  );

  // Controllers
  locator.registerLazySingleton<AuthController>(() => AuthController(locator<AuthRepository>()));
  locator.registerLazySingleton<OltsController>(() => OltsController(locator<OltsRepository>()));
  // NUEVO
  locator.registerFactory<OltPhotoController>(
        () => OltPhotoController(locator<OltPhotoRepository>()),
  );

  //SESSION STORE
  locator.registerLazySingleton<SessionStore>(() => SessionStore());
  //DIAGNOSTICO ORDENSERVICIO
  locator.registerLazySingleton<DiagnosticoRepository>(
        () => DiagnosticoRepository(locator<DiagnosticoService>()),
  );

  locator.registerLazySingleton<DiagnosticoController>(
        () => DiagnosticoController(locator<DiagnosticoRepository>()),
  );
  //FORM DIAGNOSTICO
  locator.registerLazySingleton<FormDiagnosticoService>(() => FormDiagnosticoService(
    locator<HttpClient>(),
    baseUrl: AppConfig.baseUrl,
    asignarPath: AppConfig.asignarPath,
  ));

  locator.registerLazySingleton<FormDiagnosticoRepository>(
        () => FormDiagnosticoRepository(locator<FormDiagnosticoService>()),
  );

  locator.registerFactory<FormDiagnosticoController>(
        () => FormDiagnosticoController(locator<FormDiagnosticoRepository>()),
  );
}
