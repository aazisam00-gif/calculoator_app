import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timber Log Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green.shade700,
          primary: Colors.green.shade700,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      home: const TimberLogCalculator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TimberLogCalculator extends StatefulWidget {
  const TimberLogCalculator({super.key});

  @override
  State<TimberLogCalculator> createState() => _TimberLogCalculatorState();
}

class _TimberLogCalculatorState extends State<TimberLogCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _circumferenceController = TextEditingController();
  
  double? _volumeCubicFeet;
  int? _wholeFeet;
  int? _inches;
  
  // Input validation for positive numbers
  String? _validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (number <= 0) {
      return 'Please enter a positive number';
    }
    
    return null;
  }
  
  // Calculate volume using Hoppus formula
  void _calculateVolume() {
    if (_formKey.currentState!.validate()) {
      final length = double.parse(_lengthController.text);
      final circumference = double.parse(_circumferenceController.text);
      
      // Hoppus formula: (Girth in inches / 4)² × (Length in feet) / 144
      final quarterGirth = circumference / 4;
      final volume = (quarterGirth * quarterGirth * length) / 144;
      
      // Round to 2 decimal places for internal calculation
      final roundedVolume = double.parse(volume.toStringAsFixed(2));
      
      // Convert to feet, inches, and yarns format without rounding
      final wholeFeet = roundedVolume.floor();
      final fractionalFeet = roundedVolume - wholeFeet;
      
      final totalInches = fractionalFeet * 12;
      final wholeInches = totalInches.floor();
      
      final fractionalInches = totalInches - wholeInches;
      (fractionalInches * 12).floor(); // 1 inch = 12 yarns
      
      setState(() {
        _volumeCubicFeet = roundedVolume;
        _wholeFeet = wholeFeet;
        _inches = wholeInches;
      });
    }
  }
  
  // Reset all fields and results
  void _resetFields() {
    _lengthController.clear();
    _circumferenceController.clear();
    setState(() {
      _volumeCubicFeet = null;
      _wholeFeet = null;
      _inches = null;
    });
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _circumferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timber Log Calculator (Hoppus)'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input fields
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: 'Enter Length (ft)',
                  hintText: 'e.g., 12',
                  prefixIcon: Icon(Icons.straighten),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveNumber,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _circumferenceController,
                decoration: const InputDecoration(
                  labelText: 'Enter Circumference (in)',
                  hintText: 'e.g., 36',
                  prefixIcon: Icon(Icons.radio_button_unchecked),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validatePositiveNumber,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
              ),
              const SizedBox(height: 24.0),
              
              // Calculate button
              ElevatedButton(
                onPressed: _calculateVolume,
                child: const Text('Calculate Volume', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 24.0),
              
              // Results display
              if (_volumeCubicFeet != null)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Results:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8.0),
                        Text(
                          'Result: $_wholeFeet feet $_inches inch',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 16.0),
              
              // Reset button
              if (_volumeCubicFeet != null)
                TextButton.icon(
                  onPressed: _resetFields,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Calculator'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
