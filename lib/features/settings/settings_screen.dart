import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/cost_calculator.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SettingsController());

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        if (!ctrl.isLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {ctrl.themeMode.value},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) ctrl.setThemeMode(set.first);
              },
            ),

            const SizedBox(height: 28),
            Text(
              'Fuel / energy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Used when estimating trip cost',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),

            Text('Default fuel type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: FuelType.values.map((type) {
                final selected = ctrl.fuelType.value == type;
                return ChoiceChip(
                  label: Text(const CostCalculator().labelFor(type)),
                  selected: selected,
                  onSelected: (_) => ctrl.setFuelType(type),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            _PriceField(
              label: 'Petrol price (kr/L)',
              value: ctrl.petrolPrice.value,
              onChanged: ctrl.setPetrolPrice,
            ),
            _PriceField(
              label: 'Diesel price (kr/L)',
              value: ctrl.dieselPrice.value,
              onChanged: ctrl.setDieselPrice,
            ),
            _PriceField(
              label: 'Electricity (kr/kWh)',
              value: ctrl.electricPrice.value,
              onChanged: ctrl.setElectricPrice,
            ),

            const SizedBox(height: 12),
            _PriceField(
              label: 'Petrol use (L/100 km)',
              value: ctrl.petrolConsumption.value,
              onChanged: ctrl.setPetrolConsumption,
            ),
            _PriceField(
              label: 'Diesel use (L/100 km)',
              value: ctrl.dieselConsumption.value,
              onChanged: ctrl.setDieselConsumption,
            ),
            _PriceField(
              label: 'Electric use (kWh/100 km)',
              value: ctrl.electricConsumption.value,
              onChanged: ctrl.setElectricConsumption,
            ),

            const SizedBox(height: 28),
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text('Vehicle Companion'),
              subtitle: const Text(
                'Flutter UI + Kotlin native channels\n'
                'Location · Bluetooth · WorkManager',
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _PriceField extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _PriceField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_PriceField> createState() => _PriceFieldState();
}

class _PriceFieldState extends State<_PriceField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant _PriceField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final text = widget.value.toStringAsFixed(2);
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onSubmitted: (raw) {
          final v = double.tryParse(raw.replaceAll(',', '.'));
          if (v != null && v >= 0) widget.onChanged(v);
        },
        onEditingComplete: () {
          final v = double.tryParse(_controller.text.replaceAll(',', '.'));
          if (v != null && v >= 0) widget.onChanged(v);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
