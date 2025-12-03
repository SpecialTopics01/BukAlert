import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/emergency_report_model.dart';
import '../../widgets/responsive_widgets.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardTab(),
    ReportsTab(),
    UsersTab(),
    SettingsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return ResponsiveScaffold(
      appBar: ResponsiveAppBar(
        title: 'BukAlert Admin',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Open notifications
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Dashboard Tab
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Load active reports and location sessions
    emergencyProvider.loadActiveReports();
    locationProvider.getActiveSessions();
  }

  String _calculateAverageResponseTime(List<EmergencyReport> reports) {
    if (reports.isEmpty) return '0 min';

    // Calculate average response time for resolved reports
    final resolvedReports = reports.where((r) => r.status == EmergencyStatus.resolved);
    if (resolvedReports.isEmpty) return 'N/A';

    // For now, return a placeholder
    return '12 min';
  }

  int _getTodaysReports(List<EmergencyReport> allReports) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return allReports.where((report) =>
      report.createdAt.isAfter(startOfDay)
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ResponsiveText(
            'Dashboard',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Stats Cards
          ResponsiveGrid(
            children: [
              _buildStatCard(
                'Active Reports',
                '12', // Placeholder
                Icons.report,
                Colors.red,
              ),
              _buildStatCard(
                'Active Tracking',
                '8', // Placeholder
                Icons.gps_fixed,
                Colors.green,
              ),
              _buildStatCard(
                'Avg Response',
                '15 min', // Placeholder
                Icons.timer,
                Colors.orange,
              ),
              _buildStatCard(
                'Total Today',
                '24', // Placeholder
                Icons.today,
                Colors.blue,
              ),
            ],
            mobileCrossAxisCount: screenWidth < 400 ? 1 : 2,
            tabletCrossAxisCount: 2,
            desktopCrossAxisCount: 4,
          ),

          const SizedBox(height: 32),

          // Recent Reports
          ResponsiveText(
            'Recent Reports',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Placeholder for recent reports
          ResponsiveContainer(
            maxHeight: 200,
            child: const Center(
              child: ResponsiveText(
                'Recent reports will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Quick Actions
          ResponsiveText(
            'Quick Actions',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ResponsiveGrid(
            children: [
              _buildActionButton(
                context,
                'Generate Report',
                Icons.description,
                () {
                  // TODO: Generate PDF/Excel report
                },
              ),
              _buildActionButton(
                context,
                'Manage Units',
                Icons.group,
                () {
                  // TODO: Navigate to unit management
                },
              ),
            ],
            mobileCrossAxisCount: screenWidth < 600 ? 1 : 2,
            tabletCrossAxisCount: 2,
            desktopCrossAxisCount: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// Reports Tab (Placeholder)
class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Reports Management - Coming Soon'),
    );
  }
}

// Users Tab (Placeholder)
class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('User Management - Coming Soon'),
    );
  }
}

// Settings Tab
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Admin Profile
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFD32F2F),
                    child: Text(
                      authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.currentUser?.name ?? 'Admin',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          authProvider.currentUser?.email ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Settings Options
          _buildSettingOption(
            context,
            'System Configuration',
            Icons.settings_system_daydream,
            () {
              // TODO: System settings
            },
          ),

          _buildSettingOption(
            context,
            'Notification Settings',
            Icons.notifications,
            () {
              // TODO: Notification settings
            },
          ),

          _buildSettingOption(
            context,
            'Emergency Protocols',
            Icons.warning,
            () {
              // TODO: Emergency protocols
            },
          ),

          _buildSettingOption(
            context,
            'Data Backup',
            Icons.backup,
            () {
              // TODO: Data backup
            },
          ),

          const SizedBox(height: 32),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authProvider.signOut();
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD32F2F)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
