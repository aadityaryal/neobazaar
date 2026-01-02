import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/app/app.dart';

void main() {
  // use provider scope 

  runApp(const ProviderScope(child: MyApp()));
}
