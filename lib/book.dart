import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookPackageScreen extends StatefulWidget {
  @override
  _BookPackageScreenState createState() => _BookPackageScreenState();
}

class _BookPackageScreenState extends State<BookPackageScreen> {
  List<Map<String, dynamic>> packages = [];

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  Future<void> loadPackages() async {
    var packageBox = await Hive.openBox('packages');
    setState(() {
      packages = packageBox.values.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    });
  }

  void openBookingForm(Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => BookingForm(package: package),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catering Services', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select a Catering Package:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  var package = packages[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      title: Text(
                        "${package['name']} - \$${package['price']}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Inclusions: ${package['inclusions'].join(', ')}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                        onPressed: () => openBookingForm(package),
                        child: Text('Book Now', style: TextStyle(color: Colors.white)),
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

class BookingForm extends StatefulWidget {
  final Map<String, dynamic> package;
  BookingForm({required this.package});

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController suggestionController = TextEditingController();

  Future<void> saveBooking(String packageName, String price, List<String> inclusions, String name, String date, String contact, String suggest) async {
    var box = await Hive.openBox('bookings');
    box.add({
      'package': packageName,
      'price': price,
      'inclusions': inclusions,
      'name': name,
      'date': date,
      'contact': contact,
      'suggestions': suggest
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Book ${widget.package['name']}', style: TextStyle(color: Colors.orange)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Price: \$${widget.package['price']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          Text("Inclusions: ${widget.package['inclusions'].join(', ')}", style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 10),
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'Full Name')),
          TextField(
            controller: dateController,
            decoration: InputDecoration(labelText: 'Event Date'),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          TextField(controller: contactController, decoration: InputDecoration(labelText: 'Contact Number')),
          TextField(controller: suggestionController, decoration: InputDecoration(labelText: 'Suggestions')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () async {
            await saveBooking(
              widget.package['name'],
              widget.package['price'],
              List<String>.from(widget.package['inclusions']),
              nameController.text,
              dateController.text,
              contactController.text,
              suggestionController.text,
            );
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Booking Confirmed!', style: TextStyle(color: Colors.orange)),
                content: Text('${widget.package['name']} has been booked successfully.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK', style: TextStyle(color: Colors.lightGreen)),
                  )
                ],
              ),
            );
          },
          child: Text('Confirm Booking', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
