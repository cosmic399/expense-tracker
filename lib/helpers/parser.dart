class TransactionParser {
  static final RegExp _amountRegex = RegExp(r"debited by\s*([\d\.]+)", caseSensitive: false);
  static final RegExp _payeeRegex = RegExp(r"trf to\s*(.*?)\s*Refno", caseSensitive: false);
  static final RegExp _refRegex = RegExp(r"Refno\s*(\d+)", caseSensitive: false);
  
  // 🆕 NEW REGEX: Finds "A/C X1234" or "A/C XX1234"
  static final RegExp _accRegex = RegExp(r"A/C\s*X+(\d+)", caseSensitive: false);

  static Map<String, dynamic>? parse(String body) {
    String cleanBody = body.replaceAll("\n", " ").trim();

    // 1. Amount
    final amountMatch = _amountRegex.firstMatch(cleanBody);
    if (amountMatch == null) return null; 
    double amount = double.tryParse(amountMatch.group(1)!) ?? 0.0;

    // 2. Payee
    final payeeMatch = _payeeRegex.firstMatch(cleanBody);
    String payee = payeeMatch != null ? payeeMatch.group(1)!.trim() : "Unknown Payee";

    // 3. RefNo
    final refMatch = _refRegex.firstMatch(cleanBody);
    String? bankRef = refMatch?.group(1);

    // 4. Account Number
    final accMatch = _accRegex.firstMatch(cleanBody);
    // If found, format as "XX3627". If not, "Unknown".
    String accNum = accMatch != null ? "XX${accMatch.group(1)}" : "Unknown";

    return {
      "amount": amount,
      "merchant": payee,
      "bankRef": bankRef,
      "accountNum": accNum, 
    };
  }
}