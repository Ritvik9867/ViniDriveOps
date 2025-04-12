import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class LogTripScreen extends StatefulWidget {
  const LogTripScreen({super.key});

  @override
  State<LogTripScreen> createState() => _LogTripScreenState();
}

class _LogTripScreenState extends State<LogTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _tripKmController = TextEditingController();
  final _tollController = TextEditingController();
  final _apiService = ApiService();

  String _paymentMode = 'cash'; // 'cash' or 'online'
  String _paymentType = 'prepaid'; // 'prepaid' or 'postpaid'
  bool _hasToll = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiService.logTrip(
        amount: double.parse(_amountController.text),
        tripKm: double.parse(_tripKmController.text),
        paymentMode: _paymentMode,
        paymentType: _paymentType,
        toll: _hasToll ? double.parse(_tollController.text) : null,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip logged successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to log trip';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Trip'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tripKmController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Trip KM',
                    prefixIcon: Icon(Icons.speed),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the trip KM';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid distance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Mode',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Cash'),
                                value: 'cash',
                                groupValue: _paymentMode,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMode = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Online'),
                                value: 'online',
                                groupValue: _paymentMode,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMode = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Prepaid'),
                                value: 'prepaid',
                                groupValue: _paymentType,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentType = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Postpaid'),
                                value: 'postpaid',
                                groupValue: _paymentType,
                                onChanged: (value) {
                                  setState(() {
                                    _paymentType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Add Toll Charges'),
                  value: _hasToll,
                  onChanged: (value) {
                    setState(() {
                      _hasToll = value;
                      if (!value) {
                        _tollController.clear();
                      }
                    });
                  },
                ),
                if (_hasToll) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tollController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Toll Amount',
                      prefixIcon: Icon(Icons.toll),
                    ),
                    validator: (value) {
                      if (_hasToll) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the toll amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitTrip,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _tripKmController.dispose();
    _tollController.dispose();
    super.dispose();
  }
}
