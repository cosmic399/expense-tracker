import 'package:objectbox/objectbox.dart';

@Entity()
class Transaction {
  @Id()
  int id = 0; 

  @Index()
  String refNo; 

  String bankName;    
  String payeeName;   
  double amount;
  int timestamp;
  String category;
  
  // 🆕 NEW FIELD: "X3627"
  String accountNum; 

  Transaction({
    this.id = 0,
    required this.refNo,
    required this.bankName,
    required this.payeeName,
    required this.amount,
    required this.timestamp,
    this.category = "Uncategorized",
    this.accountNum = "Unknown", 
  });
}