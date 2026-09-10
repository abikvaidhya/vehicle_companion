class AppConstants {
  static const String appName = 'Vehicle Companion';
  static const String packageChannelPrefix =
      'com.abik.vaidhya.vehicle_companion';

  // Channel names (must match Kotlin side)
  static const String locationMethodChannel = '$packageChannelPrefix/location';
  static const String locationEventChannel =
      '$packageChannelPrefix/location_stream';
  static const String bluetoothMethodChannel =
      '$packageChannelPrefix/bluetooth';
  static const String bluetoothEventChannel =
      '$packageChannelPrefix/bluetooth_stream';

  // Defaults for cost calculator (SEK — adjust in settings later)
  static const double defaultPetrolPricePerLiter = 18.50;
  static const double defaultDieselPricePerLiter = 18.20;
  static const double defaultElectricityPricePerKwh = 2.20;
  static const double defaultPetrolConsumptionLPer100km = 7.5;
  static const double defaultDieselConsumptionLPer100km = 6.0;
  static const double defaultElectricConsumptionKwhPer100km = 18.0;
}
