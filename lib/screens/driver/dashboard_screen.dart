import 'package:flutter/material.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
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
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Trip Details')),
            body: Center(child: Text('Details for trip $tripId')),
          ),
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
        title: const Text('Driver Dashboard'),
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