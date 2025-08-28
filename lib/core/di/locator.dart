import 'dart:io' as io;
import 'package:get_it/get_it.dart';
import '../network/http_client.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import '../network/http_client.dart' as core_http;
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/ordenes/data/ordenes_service.dart';
import '../../features/ordenes/data/ordenes_repository.dart';
import '../../features/ordenes/presentation/ordenes_controller.dart';

// NUEVO: foto por OLT
import '../../features/ordenes_foto/data/ordenes_foto_service.dart';
import '../../features/ordenes_foto/data/ordenes_foto_repository.dart';
import '../../features/ordenes_foto/presentation/ordenes_foto_controller.dart';
//SESSION STORE
import '../session/session_store.dart';

//DIAGNOSTICO ORDENSERVICIO
import '../../features/diagnostico_orden/data/diagnostico_service.dart';
import '../../features/diagnostico_orden/data/diagnostico_repository.dart';
import '../../features/diagnostico_orden/presentation/diagnostico_controller.dart';
//FORM DIAGNOSTICO
import '../../features/form_diagnostico/data/form_diagnostico_service.dart';
import '../../features/form_diagnostico/data/form_diagnostico_repository.dart';
import '../../features/form_diagnostico/presentation/form_diagnostico_controller.dart';
//CARD REFACCIONES
import '../../features/card_refacciones/data/refacciones_service.dart';
import '../../features/card_refacciones/data/refacciones_repository.dart';
import '../../features/card_refacciones/presentation/refacciones_controller.dart';
//FORM REFACCIONES
import '../../features/form_refacciones/data/form_refacciones_service.dart';
import '../../features/form_refacciones/data/form_refacciones_repository.dart';
import '../../features/form_refacciones/presentation/form_refacciones_controller.dart';
//ORDER STATUS
import '../../features/ordenes_status/data/order_status_service.dart';
import '../../features/ordenes_status/data/order_status_repository.dart';
import '../../features/ordenes_status/presentation/order_status_controller.dart';
final locator = GetIt.instance;
void setupLocator() {
  // Core
  locator.registerLazySingleton<core_http.HttpClient>(() {
    // Si quieres permitir MÁS de un host, agrégalos aquí:
    const allowedHost = '187.210.65.46';

    final ioHttp = io.HttpClient()
      ..badCertificateCallback = (io.X509Certificate cert, String host, int port) {
        // Acepta ÚNICAMENTE el certificado presentado por esa IP/host.
        // (Esto desactiva la verificación de CA/SAN SOLO para ese host.)
        return host == allowedHost;
      };

    final baseClient = http_io.IOClient(ioHttp);
    return core_http.HttpClient(client: baseClient);
  });

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
  // Refacciones (lista por orden)
  locator.registerLazySingleton<RefaccionesService>(() => RefaccionesService(
    locator<HttpClient>(),
    baseUrl: AppConfig.baseUrl,
    csaPath: AppConfig.csaPath,
    listaPath: AppConfig.refaccionesListaPath,
  ));
  locator.registerLazySingleton<RefaccionesRepository>(() => RefaccionesRepository(locator<RefaccionesService>()));
  locator.registerLazySingleton<RefaccionesController>(() => RefaccionesController(locator<RefaccionesRepository>()));

// Form Refacciones (buscador tipo select2)
  locator.registerLazySingleton<FormRefaccionesService>(() => FormRefaccionesService(
    locator<HttpClient>(),
    baseUrl: AppConfig.baseUrl,
    intelPath: AppConfig.intelPath,
    searchPath: AppConfig.articulosSearchPath,
    csaPath: AppConfig.csaPath,
    agregarPath: AppConfig.refaccionesAgregarPath,
  ));
  locator.registerLazySingleton<FormRefaccionesRepository>(() => FormRefaccionesRepository(locator<FormRefaccionesService>()));
  locator.registerFactory<FormRefaccionesController>(() => FormRefaccionesController(locator<FormRefaccionesRepository>()));
//ORDER STATUS
  locator.registerLazySingleton<OrderStatusService>(() => OrderStatusService(
    locator<HttpClient>(),
    baseUrl: AppConfig.baseUrl,
    asignarPath: AppConfig.asignarPath,
    estatusPath: AppConfig.estatusPath,
  ));
  locator.registerLazySingleton<OrderStatusRepository>(() => OrderStatusRepository(locator<OrderStatusService>()));
  locator.registerFactory<OrderStatusController>(() => OrderStatusController(locator<OrderStatusRepository>()));

}
