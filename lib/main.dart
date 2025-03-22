import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:catering_app/book.dart';
import 'package:catering_app/packages.dart';
import 'package:catering_app/orders.dart';

void main() async {
  await Hive.initFlutter();
  runApp(CateringApp());
}

class CateringApp extends StatelessWidget {
  const CateringApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catering Services',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalEarnings = 0;
  int totalOrders = 0;
  int totalSales = 0;
  String selectedFilter = 'Daily';

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    var box = await Hive.openBox('bookings');
    DateTime now = DateTime.now();
    setState(() {
      totalOrders = box.length;
      totalEarnings = box.values.fold(0.0, (sum, booking) => sum + (double.tryParse(booking['price'].toString()) ?? 0.0));

      if (selectedFilter == 'Daily') {
        totalSales = box.values.where((booking) => booking['status'] == 'Done' && DateTime.parse(booking['date']).day == now.day).length;
      } else if (selectedFilter == 'Weekly') {
        totalSales = box.values.where((booking) => booking['status'] == 'Done' && now.difference(DateTime.parse(booking['date'])).inDays <= 7).length;
      } else if (selectedFilter == 'Monthly') {
        totalSales = box.values.where((booking) => booking['status'] == 'Done' && DateTime.parse(booking['date']).month == now.month).length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catering Services'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: () => fetchDashboardData()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange,
              ),
              child: SizedBox.shrink(),
            ),
            ListTile(
              leading: Icon(Icons.fastfood),
              title: Text('Book Package'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BookPackageScreen())),
            ),
            ListTile(
              leading: Icon(Icons.local_shipping),
              title: Text('Track Orders'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TrackOrdersScreen())),
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts),
              title: Text('Manage Packages'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ManagePackagesScreen())),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
              SizedBox(height: 20),
              dashboardCard('Total Earnings', '\$${totalEarnings.toStringAsFixed(2)}', Colors.blueAccent, Icons.attach_money),
              SizedBox(height: 16),
              dashboardCard('Total Orders', totalOrders.toString(), Colors.greenAccent, Icons.shopping_cart),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: selectedFilter,
                    items: ['Daily', 'Weekly', 'Monthly'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedFilter = newValue!;
                        fetchDashboardData();
                      });
                    },
                  ),
                ],
              ),
              dashboardCard('Total Sales', totalSales.toString(), Colors.redAccent, Icons.bar_chart),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(String title, String value, Color color, IconData icon) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              ],
            ),
            Icon(icon, color: Colors.white, size: 50),
          ],
        ),
      ),
    );
  }
}
