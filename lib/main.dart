import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/maintenance/maintenance_controller.dart';
import 'features/trips/trips_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(TripsController(), permanent: true);
  Get.put(MaintenanceController(), permanent: true);

  runApp(const VehicleCompanionApp());
}

class VehicleCompanionApp extends StatelessWidget {
  const VehicleCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
