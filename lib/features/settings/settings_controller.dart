import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/utils/cost_calculator.dart';

class SettingsController extends GetxController {
  static const _kFuelType = 'fuel_type';
  static const _kPetrolPrice = 'petrol_price';
  static const _kDieselPrice = 'diesel_price';
  static const _kElectricPrice = 'electric_price';
  static const _kPetrolCons = 'petrol_consumption';
  static const _kDieselCons = 'diesel_consumption';
  static const _kElectricCons = 'electric_consumption';
  static const _kThemeMode = 'theme_mode'; // system | light | dark

  final fuelType = FuelType.petrol.obs;
  final petrolPrice = AppConstants.defaultPetrolPricePerLiter.obs;
  final dieselPrice = AppConstants.defaultDieselPricePerLiter.obs;
  final electricPrice = AppConstants.defaultElectricityPricePerKwh.obs;
  final petrolConsumption = AppConstants.defaultPetrolConsumptionLPer100km.obs;
  final dieselConsumption = AppConstants.defaultDieselConsumptionLPer100km.obs;
  final electricConsumption =
      AppConstants.defaultElectricConsumptionKwhPer100km.obs;
  final themeMode = ThemeMode.system.obs;

  final isLoaded = false.obs;

  CostCalculator get costCalculator => CostCalculator(
        petrolPrice: petrolPrice.value,
        dieselPrice: dieselPrice.value,
        electricityPrice: electricPrice.value,
        petrolLPer100: petrolConsumption.value,
        dieselLPer100: dieselConsumption.value,
        electricKwhPer100: electricConsumption.value,
      );

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final fuelName = prefs.getString(_kFuelType);
    if (fuelName != null) {
      fuelType.value = FuelType.values.firstWhere(
        (e) => e.name == fuelName,
        orElse: () => FuelType.petrol,
      );
    }

    petrolPrice.value =
        prefs.getDouble(_kPetrolPrice) ?? AppConstants.defaultPetrolPricePerLiter;
    dieselPrice.value =
        prefs.getDouble(_kDieselPrice) ?? AppConstants.defaultDieselPricePerLiter;
    electricPrice.value = prefs.getDouble(_kElectricPrice) ??
        AppConstants.defaultElectricityPricePerKwh;
    petrolConsumption.value = prefs.getDouble(_kPetrolCons) ??
        AppConstants.defaultPetrolConsumptionLPer100km;
    dieselConsumption.value = prefs.getDouble(_kDieselCons) ??
        AppConstants.defaultDieselConsumptionLPer100km;
    electricConsumption.value = prefs.getDouble(_kElectricCons) ??
        AppConstants.defaultElectricConsumptionKwhPer100km;

    final themeName = prefs.getString(_kThemeMode) ?? 'system';
    themeMode.value = switch (themeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    isLoaded.value = true;
  }

  Future<void> setFuelType(FuelType type) async {
    fuelType.value = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFuelType, type.name);
  }

  Future<void> setPetrolPrice(double v) async {
    petrolPrice.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPetrolPrice, v);
  }

  Future<void> setDieselPrice(double v) async {
    dieselPrice.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kDieselPrice, v);
  }

  Future<void> setElectricPrice(double v) async {
    electricPrice.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kElectricPrice, v);
  }

  Future<void> setPetrolConsumption(double v) async {
    petrolConsumption.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPetrolCons, v);
  }

  Future<void> setDieselConsumption(double v) async {
    dieselConsumption.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kDieselCons, v);
  }

  Future<void> setElectricConsumption(double v) async {
    electricConsumption.value = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kElectricCons, v);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    final prefs = await SharedPreferences.getInstance();
    final name = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_kThemeMode, name);
  }
}
