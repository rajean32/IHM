String displayPlace(String? numeroPlace) {
  if (numeroPlace == null) return '—';
  final parts = numeroPlace.split('-');
  if (parts.length >= 2) return parts.last;
  return numeroPlace;
}

String extractSeatNumber(String numeroPlace) {
  final parts = numeroPlace.split('-');
  if (parts.isEmpty) return numeroPlace;
  final seatCode = parts.last;
  return seatCode.replaceAll(RegExp(r'^[A-Za-z]*'), '');
}
