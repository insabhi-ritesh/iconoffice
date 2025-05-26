import 'dart:ui';

/// Represents a field placed on the PDF (text, date, dateTime, or signature).
class PlacedField {
  final String id;
  Offset position;
  final dynamic value; // String for text, DateTime for dates, Uint8List for signature
  Size size;

  PlacedField({
    required this.id,
    required this.position,
    required this.value,
    required this.size,
  });

  PlacedField copyWith({
    String? id,
    Offset? position,
    dynamic value,
    Size? size,
  }) {
    return PlacedField(
      id: id ?? this.id,
      position: position ?? this.position,
      value: value ?? this.value,
      size: size ?? this.size,
    );
  }
}