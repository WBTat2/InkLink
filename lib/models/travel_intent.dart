class TravelIntent {
  final String city;
  final DateTime start;
  final DateTime end;
  final String note; // e.g. "Guest spot", "Booking", "Hosting"

  const TravelIntent({
    required this.city,
    required this.start,
    required this.end,
    required this.note,
  });
}
