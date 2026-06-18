import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

Widget eventImageWidget(String? image, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
  if (image == null) {
    return _placeholder(height, width);
  }
  if (image.startsWith('data:image')) {
    try {
      final base64Str = image.split(',').last;
      final Uint8List bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        height: height,
        width: width ?? double.infinity,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(height, width),
      );
    } catch (_) {
      return _placeholder(height, width);
    }
  }
  return Image.network(
    image,
    height: height,
    width: width ?? double.infinity,
    fit: fit,
    errorBuilder: (_, __, ___) => _placeholder(height, width),
  );
}

Widget _placeholder(double? height, double? width) {
  return Container(
    height: height ?? 160,
    width: width ?? double.infinity,
    color: const Color(0xFFF5F5F5),
    child: Icon(Icons.event, size: 48, color: const Color(0xFF9E9E9E).withValues(alpha: 0.6)),
  );
}
