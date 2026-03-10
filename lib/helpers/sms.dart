import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:budget_scanner/helpers/parser.dart';
import 'package:budget_scanner/helpers/categorizer.dart'; // Import Categorizer
import 'package:budget_scanner/models/transaction.dart';
import 'package:budget_scanner/main.dart';
import 'package:budget_scanner/objectbox.g.dart'; // Import Generated Code

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<void> scanMessages() async {
    // 1. Ask Permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) return;
    }

    print("✅ PERMISSION GRANTED - SCANNING...");

    // 2. Read SMS
    List<SmsMessage> messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 20, 
    );

    final box = objectbox.store.box<Transaction>();

    // 3. Process Loop
    for (var msg in messages) {
      String body = msg.body ?? "";
      var data = TransactionParser.parse(body);
      
      if (data != null) {
        String uniqueRef;

        // 🛡️ THE HARDENED LOGIC
        if (data['bankRef'] != null) {
          // Case A: We found a real Bank RefNo. Use it.
          uniqueRef = "BANK_${data['bankRef']}";
        } else {
          // Case B: Fallback for messages without RefNo (use Body Hash)
          uniqueRef = "HASH_${body.hashCode}";
        }

        // Check Database
        final query = box.query(Transaction_.refNo.equals(uniqueRef)).build();
        final existing = query.find();
        query.close();

        if (existing.isEmpty) {
          final tx = Transaction(
            amount: data['amount'],
            payeeName: data['merchant'], 
            bankName: "SBI", 
            timestamp: msg.date?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
            refNo: uniqueRef,
            // 🧠 CALL THE BRAIN
           // category: Categorizer.classify(data['merchant'], body), 
            category: Categorizer.classify(data['merchant']),
            accountNum: data['accountNum'], 
          );

          int id = box.put(tx); 
          print("💰 SAVED NEW: ₹${tx.amount} (ID: $id) [Ref: $uniqueRef]");
        } else {
          print("🛡️ BLOCKED DUPLICATE: ${data['merchant']}");
        }
      }
    }
  }
}