import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to control the bottom navigation index
/// Allows child screens to switch tabs programmatically
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

