import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:budget_scanner/objectbox.g.dart'; // This file was just created!
import 'package:budget_scanner/models/transaction.dart';

class ObjectBox {
  late final Store store;
  late final Box<Transaction> transactionBox;

  ObjectBox._create(this.store) {
    transactionBox = Box<Transaction>(store);
  }

  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "budget-scanner-db"));
    return ObjectBox._create(store);
  }
}
