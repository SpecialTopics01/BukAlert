import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../models/emergency_report_model.dart';
import '../../widgets/responsive_widgets.dart';
import 'emergency_report_screen.dart';
import 'map_screen.dart';
import 'call_history_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    MapTab(),
    ReportsTab(),
    ProfileTab(),
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
        title: 'BukAlert',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Open notifications
            },
          ),
          if (!isDesktop) // Hide on desktop, show in drawer
            IconButton(
              icon: const Icon(Icons.emergency),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EmergencyReportScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: isDesktop ? null : BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: isDesktop ? null : FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EmergencyReportScreen(),
            ),
          );
        },
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}

// Home Tab
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          ResponsiveContainer(
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  'Welcome to BukAlert',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                ResponsiveText(
                  'Your safety is our priority',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

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
              _buildQuickActionCard(
                context,
                'Report Emergency',
                Icons.warning,
                Colors.red,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmergencyReportScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                'Call Rescue Unit',
                Icons.call,
                Colors.green,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                context,
                'View Map',
                Icons.map,
                Colors.blue,
                () {
                  // Switch to map tab
                  DefaultTabController.of(context).animateTo(1);
                },
              ),
              _buildQuickActionCard(
                context,
                'Call History',
                Icons.history,
                Colors.orange,
                () {
                  // Switch to reports tab, then call history
                  DefaultTabController.of(context).animateTo(2);
                },
              ),
            ],
            mobileCrossAxisCount: screenWidth < 400 ? 1 : 2,
            tabletCrossAxisCount: 3,
            desktopCrossAxisCount: 4,
          ),

          const SizedBox(height: 24),

          // Recent Activity
          ResponsiveText(
            'Recent Activity',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Recent activity with emergency provider
          Consumer<EmergencyProvider>(
            builder: (context, emergencyProvider, child) {
              final recentReports = emergencyProvider.userReports.take(3).toList();

              if (recentReports.isEmpty) {
                return ResponsiveContainer(
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        ResponsiveText(
                          'No recent activity',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ResponsiveText(
                          'Your emergency reports will appear here',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: recentReports.map((report) {
                  return ResponsiveContainer(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEmergencyIcon(report.type),
                            color: _getStatusColor(report.status),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ResponsiveText(
                                report.type.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ResponsiveText(
                                _formatDateTime(report.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ResponsiveText(
                            report.status.displayName,
                            style: TextStyle(
                              color: _getStatusColor(report.status),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ResponsiveContainer(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.responsiveFontSize(context, 32),
              color: color,
            ),
            const SizedBox(height: 8),
            ResponsiveText(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.reported:
        return Colors.orange;
      case EmergencyStatus.acknowledged:
        return Colors.blue;
      case EmergencyStatus.responding:
        return Colors.green;
      case EmergencyStatus.resolved:
        return Colors.grey;
      case EmergencyStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getEmergencyIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.medical:
        return Icons.local_hospital;
      case EmergencyType.crime:
        return Icons.security;
      case EmergencyType.accident:
        return Icons.car_crash;
      case EmergencyType.naturalDisaster:
        return Icons.thunderstorm;
      case EmergencyType.other:
        return Icons.warning;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Map Tab
class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapScreen();
  }
}

// Reports Tab
class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load reports when tab is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
      emergencyProvider.loadUserReports();
      emergencyProvider.startListeningToUserReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: const Color(0xFFD32F2F),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All Reports'),
              Tab(text: 'Active'),
              Tab(text: 'Resolved'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ReportsList(status: null), // All reports
              ReportsList(status: EmergencyStatus.reported),
              ReportsList(status: EmergencyStatus.resolved),
            ],
          ),
        ),

        // Add Report Button
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmergencyReportScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Report New Emergency'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Reports List Widget
class ReportsList extends StatelessWidget {
  final EmergencyStatus? status;

  const ReportsList({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, emergencyProvider, child) {
        if (emergencyProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        List<EmergencyReport> reports;
        if (status == null) {
          reports = emergencyProvider.userReports;
        } else {
          reports = emergencyProvider.userReports
              .where((report) => report.status == status)
              .toList();
        }

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == null ? Icons.report : Icons.check_circle,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  status == null
                      ? 'No reports yet'
                      : status == EmergencyStatus.resolved
                          ? 'No resolved reports'
                          : 'No active reports',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status == null
                      ? 'Tap the button below to report an emergency'
                      : 'Reports will appear here when available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          report.type.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            report.type.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getStatusColor(report.status),
                            ),
                          ),
                          child: Text(
                            report.status.displayName,
                            style: TextStyle(
                              color: _getStatusColor(report.status),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      report.description,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDateTime(report.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (report.isAssigned)
                          Text(
                            'Assigned: ${report.assignedUnitName}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),

                    if (report.priority != null && report.priority! > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.priority_high,
                              size: 16,
                              color: report.priority == 4
                                  ? Colors.red[900]
                                  : report.priority == 3
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Priority: ${_getPriorityText(report.priority!)}',
                              style: TextStyle(
                                color: report.priority == 4
                                    ? Colors.red[900]
                                    : report.priority == 3
                                        ? Colors.red
                                        : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.reported:
        return Colors.orange;
      case EmergencyStatus.acknowledged:
        return Colors.blue;
      case EmergencyStatus.responding:
        return Colors.green;
      case EmergencyStatus.resolved:
        return Colors.grey;
      case EmergencyStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Low';
      case 2:
        return 'Medium';
      case 3:
        return 'High';
      case 4:
        return 'Critical';
      default:
        return 'Medium';
    }
  }
}

// Profile Tab
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFD32F2F),
            child: Text(
              authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            authProvider.currentUser?.name ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // User Email
          Text(
            authProvider.currentUser?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 32),

          // Profile Options
          _buildProfileOption(
            context,
            'Edit Profile',
            Icons.edit,
            () {
              // TODO: Navigate to edit profile
            },
          ),

          _buildProfileOption(
            context,
            'Call History',
            Icons.history,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CallHistoryScreen(),
                ),
              );
            },
          ),

          _buildProfileOption(
            context,
            'Bookmarked Units',
            Icons.bookmark,
            () {
              // TODO: Navigate to bookmarked units
            },
          ),

          _buildProfileOption(
            context,
            'Settings',
            Icons.settings,
            () {
              // TODO: Navigate to settings
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

  Widget _buildProfileOption(
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
