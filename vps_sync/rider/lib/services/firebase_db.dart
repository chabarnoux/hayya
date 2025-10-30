import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class AppDatabase {
  static final String dbUrl = const String.fromEnvironment(
    'HAYYARIDE_RTDB',
    defaultValue: 'https://hayyaride-default-rtdb.firebaseio.com/',
  );

  // Central accessor
  static FirebaseDatabase dbInstance() {
    return FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: dbUrl);
  }
}
