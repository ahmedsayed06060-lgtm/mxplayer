import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});
