import 'package:intl/intl.dart';

/// Helper terpusat untuk semua format tanggal & waktu.
/// Semua fungsi otomatis convert dari UTC ke local timezone device.
class AppDateUtils {
  // ─── Format dasar ────────────────────────────────────────────────────────

  /// "Jun 1, 2025"
  static String formatDate(dynamic date) {
    final d = _parse(date);
    if (d == null) return '-';
    return DateFormat('MMM d, yyyy').format(d.toLocal());
  }

  /// "Jun 1, 2025 · 17:00"
  static String formatDateTime(dynamic date) {
    final d = _parse(date);
    if (d == null) return '-';
    return DateFormat("MMM d, yyyy · HH:mm").format(d.toLocal());
  }

  /// "17:00"
  static String formatTime(dynamic date) {
    final d = _parse(date);
    if (d == null) return '-';
    final local = d.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// "1 Jun 2025"
  static String formatDateLong(dynamic date) {
    final d = _parse(date);
    if (d == null) return '-';
    return DateFormat('d MMM yyyy').format(d.toLocal());
  }

  /// "yyyy-MM-dd" — untuk form input
  static String formatDateInput(dynamic date) {
    final d = _parse(date);
    if (d == null) return '';
    return DateFormat('yyyy-MM-dd').format(d.toLocal());
  }

  /// "HH:mm" — untuk form input
  static String formatTimeInput(dynamic date) {
    final d = _parse(date);
    if (d == null) return '';
    return DateFormat('HH:mm').format(d.toLocal());
  }

  // ─── Time ago ────────────────────────────────────────────────────────────

  /// "5 min ago", "2 hr ago", "3 days ago"
  /// Membandingkan waktu server (UTC) dengan waktu sekarang secara benar.
  static String timeAgo(dynamic date) {
    final d = _parse(date);
    if (d == null) return '';
    // Bandingkan dalam UTC — menghindari bug offset device vs server
    final diff = DateTime.now().toUtc().difference(d.toUtc());
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  // ─── ISO 8601 untuk kirim ke backend ────────────────────────────────────

  /// Gabungkan date string ("yyyy-MM-dd") + time string ("HH:mm")
  /// menjadi ISO 8601 dengan offset timezone lokal device.
  /// Contoh output: "2025-06-01T10:00:00+07:00"
  static String toIso8601WithOffset(String dateStr, String timeStr) {
    try {
      final parts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      if (parts.length < 3 || timeParts.length < 2) return '$dateStr $timeStr';

      final local = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final offset = local.timeZoneOffset;
      final sign = offset.isNegative ? '-' : '+';
      final hours = offset.inHours.abs().toString().padLeft(2, '0');
      final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
      final offsetStr = '$sign$hours:$minutes';

      return '${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(local)}$offsetStr';
    } catch (_) {
      return '$dateStr $timeStr';
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  static DateTime? _parse(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    final str = date.toString().trim();
    if (str.isEmpty || str == 'null') return null;
    return DateTime.tryParse(str);
  }
}