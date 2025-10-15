import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/constants/app_constants.dart';
import 'core/services/error_handler_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/network_service.dart';
import 'core/themes/app_theme.dart';
import 'routes/app_pages.dart';

/// Main entry point of the TaskMaster Pro application
/// Initializes all core services and starts the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Initialize core services
    await _initializeServices();
    
    // Run the app
    runApp(TaskMasterApp());
  } catch (e, stackTrace) {
    // Handle initialization errors
    debugPrint('App initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Run a minimal error app
    runApp(const ErrorApp());
  }
}

/// Initialize all core services
Future<void> _initializeServices() async {
  // Initialize services in dependency order
  Get.put(ErrorHandlerService(), permanent: true);
  Get.put(StorageService(), permanent: true);
  Get.put(NetworkService(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  
  // Wait for all services to initialize
  await Get.find<ErrorHandlerService>().onInit();
  await Get.find<StorageService>().onInit();
  await Get.find<NetworkService>().onInit();
  await Get.find<ThemeController>().onInit();
}

/// Main application widget
class TaskMasterApp extends StatelessWidget {
  TaskMasterApp({super.key});
  
  final ThemeController _themeController = Get.find<ThemeController>();
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      // App configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(),
      
      // Routing configuration
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: '/404',
        page: () => const NotFoundView(),
      ),
      
      // Localization configuration (for future implementation)
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      
      // GetX configuration
      enableLog: true,
      logWriterCallback: _logWriter,
      
      // Default transitions
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      
      // Builder for global configurations
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling doesn't break the UI
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    ));
  }
  
  /// Get theme mode based on controller state
  ThemeMode _getThemeMode() {
    switch (_themeController.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
  
  /// Custom log writer for GetX
  void _logWriter(String text, {bool isError = false}) {
    if (isError) {
      ErrorHandlerService.instance.logError('GetX Error: $text');
    } else {
      ErrorHandlerService.instance.logDebug('GetX: $text');
    }
  }
}

/// Error app widget shown when initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMaster Pro - Error',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const ErrorScreen(),
    );
  }
}

/// Error screen widget
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Initialization Failed',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The app failed to initialize properly. Please restart the app or contact support if the problem persists.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder views for routing (will be implemented in future phases)
class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
