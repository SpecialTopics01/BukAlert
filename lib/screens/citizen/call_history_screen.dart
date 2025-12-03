import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/call_history_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/call_provider.dart';
import '../../services/firebase_service.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CallHistory> _callHistory = [];
  bool _isLoading = true;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCallHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCallHistory() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) return;

      // Load both incoming and outgoing calls
      final outgoingCalls = await _firebaseService.firestore
          .collection('call_history')
          .where('callerId', isEqualTo: currentUser.uid)
          .orderBy('startedAt', descending: true)
          .get();

      final incomingCalls = await _firebaseService.firestore
          .collection('call_history')
          .where('receiverId', isEqualTo: currentUser.uid)
          .orderBy('startedAt', descending: true)
          .get();

      final allCalls = [...outgoingCalls.docs, ...incomingCalls.docs];

      // Remove duplicates based on callId
      final seenCallIds = <String>{};
      final uniqueCalls = allCalls.where((doc) {
        final callId = doc.get('callId') as String;
        if (seenCallIds.contains(callId)) {
          return false;
        }
        seenCallIds.add(callId);
        return true;
      }).toList();

      // Sort by timestamp
      uniqueCalls.sort((a, b) {
        final aTime = (a.get('startedAt') as Timestamp).toDate();
        final bTime = (b.get('startedAt') as Timestamp).toDate();
        return bTime.compareTo(aTime);
      });

      setState(() {
        _callHistory = uniqueCalls
            .map((doc) => CallHistory.fromFirestore(doc))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load call history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Calls'),
            Tab(text: 'Completed'),
            Tab(text: 'Missed'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCallList(null), // All calls
                _buildCallList(CallStatus.completed),
                _buildCallList(CallStatus.missed),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        onPressed: () {
          // Quick call to nearest unit
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quick call feature coming soon...')),
          );
        },
        child: const Icon(Icons.call),
      ),
    );
  }

  Widget _buildCallList(CallStatus? filterStatus) {
    final filteredCalls = filterStatus == null
        ? _callHistory
        : _callHistory.where((call) => call.status == filterStatus).toList();

    if (filteredCalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filterStatus == CallStatus.missed ? Icons.call_missed : Icons.call,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              filterStatus == null
                  ? 'No call history yet'
                  : filterStatus == CallStatus.missed
                      ? 'No missed calls'
                      : 'No completed calls',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your call history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCalls.length,
      itemBuilder: (context, index) {
        final call = filteredCalls[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: call.callType == CallType.video
                  ? Colors.blue[100]
                  : Colors.green[100],
              child: Icon(
                call.callType == CallType.video
                    ? Icons.videocam
                    : Icons.call,
                color: call.callType == CallType.video
                    ? Colors.blue[700]
                    : Colors.green[700],
              ),
            ),
            title: Text(
              call.unitName ?? call.receiverName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateTime(call.startedAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (call.unitName != null)
                  Text(
                    call.unitName!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  call.isMissed ? Icons.call_missed : Icons.call_made,
                  color: call.statusColor,
                  size: 16,
                ),
                const SizedBox(height: 2),
                Text(
                  call.statusText,
                  style: TextStyle(
                    color: call.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () => _showCallDetails(call),
          ),
        );
      },
    );
  }

  void _showCallDetails(CallHistory call) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          call.unitName ?? call.receiverName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Call Type', call.callType.name.toUpperCase()),
            _buildDetailRow('Status', call.status.name.toUpperCase()),
            _buildDetailRow('Date & Time', _formatFullDateTime(call.startedAt)),
            if (call.duration != null)
              _buildDetailRow('Duration', call.durationText),
            if (call.unitName != null)
              _buildDetailRow('Unit', call.unitName!),
            if (call.reportId != null)
              _buildDetailRow('Linked Report', 'Report #${call.reportId!.substring(0, 8)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (call.isCompleted)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Call back the same unit
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${call.unitName ?? call.receiverName}...')),
                );
              },
              icon: const Icon(Icons.call),
              label: const Text('Call Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
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

  String _formatFullDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
