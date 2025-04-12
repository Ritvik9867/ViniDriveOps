import 'package:flutter/material.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

import 'dart:async';

class _DriverDashboardScreenState extends State<DriverDashboardScreen> with AutomaticKeepAliveClientMixin {
  Timer? _statusUpdateTimer;
  Timer? _locationUpdateTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    // Timer for periodic status updates
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted) {
        _updateDriverStatus();
      }
    });

    // Timer for location updates
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        _updateDriverLocation();
      }
    });
  }

  Future<void> _updateDriverStatus() async {
    // Implementation for status update
  }

  Future<void> _updateDriverLocation() async {
    // Implementation for location update
  }

  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
  bool _isAvailable = true;
  final List<Map<String, dynamic>> _recentTrips = [
    {
      'id': '1',
      'destination': 'Downtown Mall',
      'date': '2024-01-20',
      'amount': '\$25.00'
    },
    {
      'id': '2',
      'destination': 'Airport',
      'date': '2024-01-19',
      'amount': '\$45.00'
    },
  ];

  Future<void> _toggleAvailability() async {
    // Check if widget is mounted before updating state
    if (!mounted) return;

    setState(() {
      _isAvailable = !_isAvailable;
    });

    // Simulating API call
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      // Update status on server would go here
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  Future<void> _navigateToTripDetails(String tripId) async {
    // Simulating navigation and data loading
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      // Navigate to trip details
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TripDetailsScreen(tripId: tripId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load trip details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ViniDriveOps'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('Driver Dashboard',
                style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Profile Section
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text('John Doe'),
                subtitle: const Text('Rating: 4.8'),
                trailing: Switch(
                  value: _isAvailable,
                  onChanged: (value) => _toggleAvailability(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Section
            Text(
              _isAvailable ? 'Available' : 'Unavailable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Earnings Section
            const Text(
              'Earnings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Today\'s Earnings: \$120.00'),
                    const Text('This Week: \$750.00'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent Trips Section
            const Text(
              'Recent Trips',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTrips.length,
              itemBuilder: (context, index) {
                final trip = _recentTrips[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(trip['destination']),
                    subtitle: Text(trip['date']),
                    trailing: Text(trip['amount']),
                    onTap: () => _navigateToTripDetails(trip['id']),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}