class Categorizer {
  // FIXED: Now accepts only ONE argument (payee)
  static String classify(String payee) {
    String name = payee.toLowerCase();

    // 1. FOOD
    if (name.contains("zomato") || 
        name.contains("bundl") || // Swiggy
        name.contains("swiggy") || 
        name.contains("domin")) { 
      return "🍔 Food";
    }

    // 2. TRAVEL
    if (name.contains("uber") || 
        name.contains("ola") || 
        name.contains("rapido") ||
        name.contains("irctc")) {
      return "🚕 Travel";
    }

    // 3. SHOPPING
    if (name.contains("amazon") || 
        name.contains("flipkart") || 
        name.contains("myntra") ||
        name.contains("retail")) { 
      return "🛍️ Shopping";
    }
    
    // 4. BILLS
    if (name.contains("airtel") || 
        name.contains("jio") || 
        name.contains("bescom") || 
        name.contains("billdesk")) {
      return "📱 Bills";
    }

    return "💸 General"; 
  }
}