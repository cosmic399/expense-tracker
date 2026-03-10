import 'dart:async'; // REQUIRED FOR HEARTBEAT
import 'package:flutter/material.dart';
import 'package:budget_scanner/helpers/objectbox.dart';
import 'package:budget_scanner/helpers/sms.dart';
import 'package:budget_scanner/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:budget_scanner/widgets/toxic_mist.dart';
import 'package:budget_scanner/screens/splash_rain.dart';

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    // CHANGE HOME TO THE SPLASH SCREEN
    home: SplashRain(), 
  ));
}

// 🎨 NEO-POP PALETTE
class NeoColors {
  static const lime = Color(0xFFE5FF65);    
  static const cyan = Color(0xFF00FFFF);    
  static const pink = Color(0xFFFF007F);    
  static const voidBlack = Color(0xFF000000); 
  static const surface = Color(0xFF111111);   
}

class CredDashboard extends StatefulWidget {
  const CredDashboard({super.key});

  @override
  State<CredDashboard> createState() => _CredDashboardState();
}

class _CredDashboardState extends State<CredDashboard> with WidgetsBindingObserver {
  final SmsService _smsService = SmsService();
  List<Transaction> _transactions = [];
  Map<String, double> _accountSpends = {}; 
  double _totalSpent = 0;
  
  // ⚡ THE HEARTBEAT TIMER
  Timer? _heartbeat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); 
    
    // 1. INITIAL SCAN
    _autoSync();

    // 2. START THE HEARTBEAT (Polls every 2 seconds)
    // This is "Real Time" enough for human perception.
    _heartbeat = Timer.periodic(const Duration(seconds: 2), (timer) {
      _autoSync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeat?.cancel(); 
    super.dispose();
  }

  // 🔄 LIFECYCLE TRIGGER (Updates instantly when you switch apps)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _autoSync(); 
    }
  }

  Future<void> _autoSync() async {
    if (!mounted) return;
    // Silent Scan: Updates data without blocking UI
    await _smsService.scanMessages();
    _refreshFromDB();
  }

  void _refreshFromDB() {
    final box = objectbox.store.box<Transaction>();
    final data = box.getAll();
    data.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    Map<String, double> accSpends = {};
    double total = 0;
    
    for (var tx in data) {
      total += tx.amount;
      accSpends[tx.accountNum] = (accSpends[tx.accountNum] ?? 0) + tx.amount;
    }

    if (mounted) {
      setState(() {
        _transactions = data;
        _totalSpent = total;
        _accountSpends = accSpends;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.voidBlack,
      body: ToxicMist(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSystemHeader(),
              const SizedBox(height: 24),
              _buildHeroTotal(),
              const SizedBox(height: 32),
              _buildBankCarousel(),
              const SizedBox(height: 32),
              _buildSectionLabel("LIVE_FEED // LEDGER"),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEO-POP COMPONENTS ---

  Widget _buildSystemHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SYSTEM", style: TextStyle(color: NeoColors.lime, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w700)),
              Text("ACTIVE_MONITORING", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          // Pulsing Heartbeat Indicator
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.2, end: 1.0),
            duration: const Duration(milliseconds: 1000), // Fast Pulse
            builder: (context, val, child) {
              return Container(
                height: 8, width: 8,
                decoration: BoxDecoration(
                  color: NeoColors.lime.withOpacity(val),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: NeoColors.lime.withOpacity(0.8), blurRadius: 10)]
                ),
              );
            },
            onEnd: () => setState((){}), 
          )
        ],
      ),
    );
  }

  Widget _buildHeroTotal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: NeoColors.surface,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(6, 6), blurRadius: 0)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("TOTAL_OUTFLOW", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontFamily: 'Courier')),
            const SizedBox(height: 12),
            Text(
              "₹${NumberFormat("#,##0").format(_totalSpent)}",
              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'Courier'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankCarousel() {
    if (_accountSpends.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24, right: 8),
        children: _accountSpends.entries.map((entry) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16, bottom: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NeoColors.voidBlack,
              border: Border.all(color: NeoColors.cyan, width: 1.5),
              boxShadow: const [BoxShadow(color: NeoColors.cyan, offset: Offset(4, 4), blurRadius: 0)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Courier')),
                Text("₹${entry.value.toInt()}", 
                  style: const TextStyle(color: NeoColors.cyan, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTransactionList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          final isLarge = tx.amount > 1000; 
          final accentColor = isLarge ? NeoColors.pink : NeoColors.lime;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              border: Border(left: BorderSide(color: accentColor, width: 4)),
            ),
            child: Row(
              children: [
                Text(tx.payeeName.isNotEmpty ? tx.payeeName[0].toUpperCase() : "?", 
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Courier')),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.payeeName.toUpperCase(), 
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(tx.accountNum, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'Courier')),
                    ],
                  ),
                ),
                Text("₹${tx.amount.toInt()}", 
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Courier')),
              ],
            ),
          );
        },
      ),
    );
  }
}