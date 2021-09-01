import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initHive() async {
  var path = await getApplicationDocumentsDirectory();
  Hive.init(path.path);
}
