import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AdvanceRepaymentScreen extends StatefulWidget {
  const AdvanceRepaymentScreen({super.key});

  @override
  State<AdvanceRepaymentScreen> createState() => _AdvanceRepaymentScreenState();
}

class _AdvanceRepaymentScreenState extends State<AdvanceRepaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _apiService = ApiService();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  double _advanceBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAdvanceBalance();
  }

  Future<void> _loadAdvanceBalance() async {
    try {
      final result = await _apiService.getDriverDashboard();
      if (result['success']) {
        setState(() {
          _advanceBalance = result['data']['advanceBalance'] ?? 0.0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load advance balance')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<void> _submitRepayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a payment screenshot')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First upload the image
      final uploadResult = await _apiService.uploadImage(_selectedImage!, 'payment');

      if (!uploadResult['success']) {
        throw Exception(uploadResult['message']);
      }

      // Then submit the repayment
      final result = await _apiService.submitAdvanceRepayment(
        amount: double.parse(_amountController.text),
        screenshotUrl: uploadResult['imageUrl'],
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repayment submitted successfully. Pending admin approval.')),
        );
        Navigator.pop(context, true);
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to submit repayment';
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
        title: const Text('Advance Repayment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Advance Balance',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${_advanceBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Repayment Amount',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Please enter a valid amount';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    if (amount > _advanceBalance) {
                      return 'Amount cannot exceed advance balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Screenshot',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please upload a screenshot of your payment',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedImage != null)
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: Image.file(_selectedImage!),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          Center(
                            child: TextButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Upload Screenshot'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
                  onPressed: _isLoading ? null : _submitRepayment,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Submit Repayment'),
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
    super.dispose();
  }
}