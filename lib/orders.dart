import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TrackOrdersScreen extends StatefulWidget {
  @override
  _TrackOrdersScreenState createState() => _TrackOrdersScreenState();
}

class _TrackOrdersScreenState extends State<TrackOrdersScreen> {
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    var box = await Hive.openBox('bookings');
    setState(() {
      bookings = box.values.map((e) {
        var booking = Map<String, dynamic>.from(e);
        // Ensure price is parsed as a double (default to 0.0 if invalid)
        booking['price'] = double.tryParse(booking['price'].toString()) ?? 0.0;
        return booking;
      }).toList();
    });
  }

  void toggleStatus(int index) async {
    var box = await Hive.openBox('bookings');
    setState(() {
      bookings[index]['status'] = bookings[index]['status'] == 'Done' ? 'Not Yet' : 'Done';
      box.putAt(index, bookings[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Your Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Your Booked Packages:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            SizedBox(height: 10),
            Expanded(
              child: bookings.isEmpty
                  ? Text('No bookings yet!', style: TextStyle(color: Colors.grey))
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        var booking = bookings[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text('${booking['package']} - ${booking['date']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Booked by: ${booking['name']}'),
                                Text('Contact: ${booking['contact']}'),
                                SizedBox(height: 5),
                                Text('Inclusions: ${(booking['inclusions'] as List<dynamic>?)?.join(", ") ?? "None"}',
                                    style: TextStyle(color: Colors.blueGrey)),
                                SizedBox(height: 5),
                                Text('Price: \$${booking['price'].toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                                SizedBox(height: 5),
                                Text('Status: ${booking['status'] ?? 'Not Yet'}',
                                    style: TextStyle(
                                        color: booking['status'] == 'Done' ? Colors.green : Colors.red)),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                booking['status'] == 'Done' ? Icons.check_circle : Icons.cancel,
                                color: booking['status'] == 'Done' ? Colors.green : Colors.red,
                              ),
                              onPressed: () => toggleStatus(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}