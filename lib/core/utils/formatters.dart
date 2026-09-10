import 'package:intl/intl.dart';

final _dateTime = DateFormat('d MMM yyyy, HH:mm');
final _dateOnly = DateFormat('d MMM yyyy');
final _timeOnly = DateFormat('HH:mm');
final _currency = NumberFormat.currency(locale: 'sv_SE', symbol: 'kr');

String formatDateTime(DateTime dt) => _dateTime.format(dt);
String formatDate(DateTime dt) => _dateOnly.format(dt);
String formatTime(DateTime dt) => _timeOnly.format(dt);

String formatDuration(Duration? d) {
  if (d == null) return '—';
  if (d.inHours > 0) {
    return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
  }
  if (d.inMinutes > 0) return '${d.inMinutes} min';
  return '${d.inSeconds}s';
}

String formatKm(double km) {
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  return '${km.toStringAsFixed(0)} km';
}

String formatCost(double? cost) {
  if (cost == null) return '—';
  return _currency.format(cost);
}
