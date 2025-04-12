import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final _currencyFormat = NumberFormat.currency(symbol: '₹');

  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedDriver;
  Map<String, dynamic>? _dashboardData;
  List<Map<String, String>> _drivers = [];
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _loadDashboardData();
  }

  Future<void> _loadDrivers() async {
    try {
      final result = await _apiService.getAllDrivers();
      if (result['success']) {
        setState(() {
          _drivers = List<Map<String, String>>.from(
            result['data'].map((driver) => {
                  'id': driver['id'] as String,
                  'name': driver['name'] as String,
                }),
          );
        });
      }
    } catch (e) {
      // Handle error silently as this is not critical
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _apiService.getAdminDashboard(
        driverId: _selectedDriver,
        startDate: _selectedDateRange?.start.toIso8601String(),
        endDate: _selectedDateRange?.end.toIso8601String(),
      );

      if (result['success']) {
        setState(() {
          _dashboardData = result['data'];
        });
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadDashboardData();
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovals() {
    final pendingCNG = _dashboardData?['pendingApprovals']?['cng'] ?? [];
    final pendingRepayments =
        _dashboardData?['pendingApprovals']?['repayments'] ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Approvals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (pendingCNG.isEmpty && pendingRepayments.isEmpty)
              const Text('No pending approvals')
            else ...[
              if (pendingCNG.isNotEmpty) ...[
                const Text(
                  'CNG Expenses',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingCNG.length,
                  itemBuilder: (context, index) {
                    final item = pendingCNG[index];
                    return ListTile(
                      title: Text('Driver: ${item['driverName']}'),
                      subtitle: Text(
                        'Amount: ${_currencyFormat.format(item['amount'])}\nDate: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(item['date']))}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await _apiService.updateApprovalStatus(
                                itemId: item['id'],
                                type: 'cng_expense',
                                approved: true,
                              );
                              _loadDashboardData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await _apiService.updateApprovalStatus(
                                itemId: item['id'],
                                type: 'cng_expense',
                                approved: false,
                              );
                              _loadDashboardData();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              if (pendingRepayments.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Advance Repayments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingRepayments.length,
                  itemBuilder: (context, index) {
                    final item = pendingRepayments[index];
                    return ListTile(
                      title: Text('Driver: ${item['driverName']}'),
                      subtitle: Text(
                        'Amount: ${_currencyFormat.format(item['amount'])}\nDate: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(item['date']))}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await _apiService.updateApprovalStatus(
                                itemId: item['id'],
                                type: 'advance_repayment',
                                approved: true,
                              );
                              _loadDashboardData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await _apiService.updateApprovalStatus(
                                itemId: item['id'],
                                type: 'advance_repayment',
                                approved: false,
                              );
                              _loadDashboardData();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
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
                                  'Filters',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedDriver,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Driver',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('All Drivers'),
                                    ),
                                    ..._drivers.map((driver) {
                                      return DropdownMenuItem(
                                        value: driver['id'],
                                        child: Text(driver['name']!),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDriver = value;
                                    });
                                    _loadDashboardData();
                                  },
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _selectDateRange,
                                  icon: const Icon(Icons.date_range),
                                  label: Text(
                                    _selectedDateRange != null
                                        ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                                        : 'Select Date Range',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Earnings',
                                _currencyFormat.format(
                                    _dashboardData?['totalEarnings'] ?? 0),
                                Icons.monetization_on,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Total Expenses',
                                _currencyFormat.format(
                                    _dashboardData?['totalExpenses'] ?? 0),
                                Icons.account_balance_wallet,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total KM',
                                '${_dashboardData?['totalKm'] ?? 0} km',
                                Icons.speed,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Burning KM',
                                '${_dashboardData?['burningKm'] ?? 0} km',
                                Icons.local_fire_department,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPendingApprovals(),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quick Actions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ActionButton(
                                      icon: Icons.add_circle,
                                      label: 'Add Advance',
                                      onTap: () {
                                        // Navigate to add advance screen
                                      },
                                    ),
                                    ActionButton(
                                      icon: Icons.assessment,
                                      label: 'Reports',
                                      onTap: () {
                                        // Navigate to reports screen
                                      },
                                    ),
                                    ActionButton(
                                      icon: Icons.people,
                                      label: 'Manage Drivers',
                                      onTap: () {
                                        // Navigate to driver management screen
                                      },
                                    ),
                                  ],
                                ),
                              ],
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

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x1A2196F3), // Colors.blue with 10% opacity,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
