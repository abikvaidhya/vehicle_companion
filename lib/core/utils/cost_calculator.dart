import '../constants.dart';

enum FuelType { petrol, diesel, electric, hybrid }

/// Simple cost estimate from distance + fuel type.
/// Hybrid uses petrol defaults for now; refine later.
class CostCalculator {
  const CostCalculator({
    this.petrolPrice = AppConstants.defaultPetrolPricePerLiter,
    this.dieselPrice = AppConstants.defaultDieselPricePerLiter,
    this.electricityPrice = AppConstants.defaultElectricityPricePerKwh,
    this.petrolLPer100 = AppConstants.defaultPetrolConsumptionLPer100km,
    this.dieselLPer100 = AppConstants.defaultDieselConsumptionLPer100km,
    this.electricKwhPer100 =
        AppConstants.defaultElectricConsumptionKwhPer100km,
  });

  final double petrolPrice;
  final double dieselPrice;
  final double electricityPrice;
  final double petrolLPer100;
  final double dieselLPer100;
  final double electricKwhPer100;

  double estimate({
    required double distanceKm,
    required FuelType fuelType,
  }) {
    if (distanceKm <= 0) return 0;
    switch (fuelType) {
      case FuelType.petrol:
      case FuelType.hybrid:
        final liters = distanceKm * petrolLPer100 / 100;
        return liters * petrolPrice;
      case FuelType.diesel:
        final liters = distanceKm * dieselLPer100 / 100;
        return liters * dieselPrice;
      case FuelType.electric:
        final kwh = distanceKm * electricKwhPer100 / 100;
        return kwh * electricityPrice;
    }
  }

  String labelFor(FuelType type) {
    switch (type) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
    }
  }
}
