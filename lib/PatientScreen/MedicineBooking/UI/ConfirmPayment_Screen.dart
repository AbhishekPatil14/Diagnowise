import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Payment_Databases.dart';
import '../Model/Payment_Model.dart';

class ConfirmOrderPage extends StatefulWidget {
  final List<String> selectedItems;
  final double totalAmount;

  const ConfirmOrderPage({
    Key? key,
    required this.selectedItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<ConfirmOrderPage> createState() => _ConfirmOrderPageState();
}

class _ConfirmOrderPageState extends State<ConfirmOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedPayment = 'UPI';
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        // Save payment details regardless of payment method
        final payment = Payment(
          customerName: _nameController.text,
          customerPhone: _contactController.text,
          customerAddress: _addressController.text,
          items: widget.selectedItems.join(', '),
          amount: widget.totalAmount,
          paymentMethod: _selectedPayment,
          timestamp: DateTime.now(),
        );

        await DatabaseHelper3.instance.insertPayment(payment);

        // Handle payment based on selected method
        if (_selectedPayment == "UPI") {
          // For "Other UPI Apps" option, just show success dialog
          _showSuccessDialog("Payment completed successfully!");
          return;
        }

        // For specific payment apps (GPay, PhonePe), use Intent approach
        // Prepare payment data
        const merchantUpiId = 'vyassaumya4@okaxis';
        const merchantName = 'Medicine Store';
        final amountString = widget.totalAmount.toStringAsFixed(2);

        // Create a generic UPI URL that works on all Android versions
        final upiUrl = 'upi://pay?pa=$merchantUpiId&pn=$merchantName&am=$amountString&cu=INR&tn=Medicine%20Purchase';

        // Include app package in URI for higher Android versions
        String intentUrl = upiUrl;
        if (_selectedPayment == "GPay") {
          intentUrl = '$upiUrl&package=com.google.android.apps.nbu.paisa.user';
        } else if (_selectedPayment == "PhonePe") {
          intentUrl = '$upiUrl&package=com.phonepe.app';
        }

        debugPrint("Payment URL: $intentUrl");

        final uri = Uri.parse(intentUrl);

        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (!launched) {
            // Fall back to generic UPI URL if specific app URL fails
            final genericUri = Uri.parse(upiUrl);
            final genericLaunched = await launchUrl(
              genericUri,
              mode: LaunchMode.externalApplication,
            );

            if (!genericLaunched) {
              _showErrorDialog("Could not launch payment app. Please choose 'Other UPI Apps' option.");
            }
          }
          // No success dialog for GPay or PhonePe options
        } catch (launchError) {
          debugPrint("Launch Error: $launchError");
          _showErrorDialog("Could not launch payment app: $launchError. Try using 'Other UPI Apps' option.");
        }
      } catch (e) {
        debugPrint("Payment Error: $e");
        _showErrorDialog("Payment failed: ${e.toString()}");
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Payment Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to home screen or order confirmation page
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Order"),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Processing payment...",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Order Summary Card
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Order",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(thickness: 1),
                      const SizedBox(height: 8),
                      for (var item in widget.selectedItems)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text("• $item"),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        "Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Customer Information
              const Text(
                "Customer Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Delivery Address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.home),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter phone number";
                  }
                  if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return "Enter valid 10-digit number";
                  }
                  return null;
                },
              ),

              // Payment Method Section
              const SizedBox(height: 24),
              const Text(
                "Payment Method",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/images/gpay.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.payment, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          const Text("Google Pay"),
                        ],
                      ),
                      value: "GPay",
                      groupValue: _selectedPayment,
                      onChanged: (value) => setState(() => _selectedPayment = value!),
                    ),
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/images/phonepe.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.payment, color: Colors.purple),
                          ),
                          const SizedBox(width: 12),
                          const Text("PhonePe"),
                        ],
                      ),
                      value: "PhonePe",
                      groupValue: _selectedPayment,
                      onChanged: (value) => setState(() => _selectedPayment = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text("Other UPI Apps"),
                      value: "UPI",
                      groupValue: _selectedPayment,
                      onChanged: (value) => setState(() => _selectedPayment = value!),
                    ),
                  ],
                ),
              ),

              // Proceed Button
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    "PROCEED TO PAYMENT",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}