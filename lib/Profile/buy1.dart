import 'package:flutter/material.dart';

class BuyNowPage extends StatefulWidget {
  const BuyNowPage({super.key});

  @override
  _BuyNowPageState createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String mobile = '';
  String email = '';
  String city = '';
  String address = '';
  String paymentMode = 'Cash on Delivery';

  List<String> paymentOptions = [
    'Cash on Delivery',
    'Credit/Debit Card',
    'UPI',
    'Net Banking'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Now'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter your name' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? 'Please enter mobile number' : null,
                onSaved: (value) => mobile = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value!.isEmpty ? 'Please enter email' : null,
                onSaved: (value) => email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter city' : null,
                onSaved: (value) => city = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter address' : null,
                onSaved: (value) => address = value!,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: paymentMode,
                decoration: InputDecoration(labelText: 'Payment Mode'),
                items: paymentOptions
                    .map((mode) => DropdownMenuItem(
                  value: mode,
                  child: Text(mode),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    paymentMode = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Here, you can send this data to your backend
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Order Placed'),
                        content: Text(
                            'Thank you $name!\nYour order will be processed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: Text('Confirm Buy'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
