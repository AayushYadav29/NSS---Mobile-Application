import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminPanel());
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NSS Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId = '';

  void login() {
    if (usernameController.text == 'royaldombivli' &&
        passwordController.text == 'Royal@2025') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  void sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+919997122270',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${e.message}')),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Write Security code linked to +919997122270'),
          ),
        );
        _showOTPDialog();
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Security Code'),
          content: TextField(
            controller: otpController,
            decoration: const InputDecoration(labelText: 'Security Code'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                verifyOTPAndChangePassword();
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  void verifyOTPAndChangePassword() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      await _auth.signInWithCredential(credential);

      Navigator.pop(context);

      _showResetPasswordDialog();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid Security Code: $e')));
    }
  }

  void _showResetPasswordDialog() {
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newPassController.text == confirmPassController.text &&
                    newPassController.text.isNotEmpty) {
                  setState(() {
                    passwordController.text = newPassController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated. Please login again.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxWidth = MediaQuery.of(context).size.width > 400
        ? 400.0
        : MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: boxWidth,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/nss_logo.png', height: 100),
                const SizedBox(height: 12),
                const Text(
                  'Not Me But You',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Login'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: sendOTP,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int volunteerCount = 0;

  @override
  void initState() {
    super.initState();
    fetchVolunteerCount();
  }

  void fetchVolunteerCount() {
    _firestore
        .collection('volunteers')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .listen((snapshot) {
          setState(() {
            volunteerCount = snapshot.size;
          });
        });
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;
    final crossAxisCount = isWide ? 4 : 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 49, 214),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Image.asset(
              'assets/nss_logo.png',
              height: 32,
              width: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'NSS - Not Me But You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== GRID CARDS =====
            Column(
              children: [
                // First row of cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                  children: [
                    _buildDashboardCard("Volunteers", Icons.group, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VolunteersListPage(),
                        ),
                      );
                    }),
                    _buildDashboardCard("Activities", Icons.event, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivitiesPage(),
                        ),
                      );
                    }),
                    _buildDashboardCard(
                      "Manage Volunteers",
                      Icons.verified_user,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageVolunteerPage(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardCard("Reports", Icons.insert_chart, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportPage()),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                // Second row of cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                  children: [
                    _buildDashboardCard("NSS Camp", Icons.forest, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NSSCampPage()),
                      );
                    }),
                    _buildDashboardCard("Track Hours", Icons.timer, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TrackHoursPage()),
                      );
                    }),
                    _buildDashboardCard("Meetings", Icons.meeting_room, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MeetingsPage()),
                      );
                    }),
                    _buildDashboardCard("Notice", Icons.notifications, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageNoticesPage(),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ===== PIE CHART =====
            Center(
              child: Column(
                children: [
                  const Text(
                    "Volunteer Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 220,
                        width: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: volunteerCount.toDouble(),
                                color: Colors.blue,
                                title: '$volunteerCount',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PieChartSectionData(
                                value: (75 - volunteerCount).toDouble(),
                                color: Colors.orange,
                                title: '${75 - volunteerCount}',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Volunteers Joined",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text("$volunteerCount"),
                        ],
                      ),
                      Column(
                        children: const [
                          Text(
                            "Total Batch",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text("75"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== RECENT ACTIVITY =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Activity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('recent_activity')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final activities = snapshot.data!.docs;
                        if (activities.isEmpty) {
                          return const Center(
                            child: Text('No recent activities.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: activities.length,
                          itemBuilder: (context, index) {
                            final activity =
                                activities[index].data()
                                    as Map<String, dynamic>;
                            return ListTile(
                              leading: const Icon(Icons.notifications),
                              title: Text(activity['message'] ?? ''),
                              subtitle: Text(
                                activity['timestamp'] != null
                                    ? (activity['timestamp'] as Timestamp)
                                          .toDate()
                                          .toString()
                                    : '',
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageVolunteerPage extends StatelessWidget {
  const ManageVolunteerPage({super.key});

  void _showSetPasswordDialog(
    BuildContext context,
    DocumentSnapshot doc,
    String username,
    String name,
  ) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Volunteer Password'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = passwordController.text.trim();
              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password cannot be empty')),
                );
                return;
              }
              await FirebaseFirestore.instance
                  .collection('volunteers')
                  .doc(doc.id)
                  .update({
                    'status': 'approved',
                    'username': username,
                    'password': password,
                  });
              await FirebaseFirestore.instance
                  .collection('recent_activity')
                  .add({
                    'message': 'Approved volunteer: $name',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
              await FirebaseFirestore.instance.collection('notifications').add({
                'title': 'Welcome to NSS!',
                'body':
                    'Congratulations! Your account has been approved.\nUsername: $username\nPassword: $password',
                'type': 'notice',
                'volunteerName': name,
                'volunteerId': doc.id, // Only for this volunteer
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Approved: $username / $password')),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Volunteer Approvals'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('volunteers')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final volunteers = snapshot.data!.docs;
              if (volunteers.isEmpty) {
                return const Center(child: Text('No pending volunteers.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: volunteers.length,
                itemBuilder: (context, index) {
                  final doc = volunteers[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? '';
                  final rollNo = data['rollNo'] ?? '';
                  final studentClass = data['class'] ?? '';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Roll No: $rollNo | Class: $studentClass',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              SizedBox(
                                width: isWide ? 120 : double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final username = name
                                        .split(' ')[0]
                                        .toLowerCase();
                                    _showSetPasswordDialog(
                                      context,
                                      doc,
                                      username,
                                      name,
                                    );
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: isWide ? 120 : double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await firestore
                                        .collection('volunteers')
                                        .doc(doc.id)
                                        .update({'status': 'rejected'});
                                    await firestore
                                        .collection('recent_activity')
                                        .add({
                                          'message':
                                              'Rejected volunteer: $name',
                                          'timestamp':
                                              FieldValue.serverTimestamp(),
                                        });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Volunteer rejected'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.close),
                                  label: const Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class VolunteersListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VolunteersListPage({super.key});

  Future<void> _exportToExcel(
    BuildContext context,
    List<Map<String, dynamic>> volunteerDetails,
  ) async {
    final xls = excel.Excel.createExcel();
    final sheet = xls['Volunteers'];
    sheet.appendRow([
      excel.TextCellValue('Name'),
      excel.TextCellValue('Class'),
      excel.TextCellValue('Roll No'),
    ]);
    for (var v in volunteerDetails) {
      sheet.appendRow([
        excel.TextCellValue(v['name'] ?? ''),
        excel.TextCellValue(v['class'] ?? ''),
        excel.TextCellValue(v['rollNo'] ?? ''),
      ]);
    }
    final fileBytes = xls.encode();
    if (fileBytes != null) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/volunteers.xlsx');
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Volunteers List');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchVolunteers() async {
    final snapshot = await _firestore
        .collection('volunteers')
        .where('status', isEqualTo: 'approved')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'] ?? 'N/A',
        'class': data['class'] ?? 'N/A',
        'rollNo': data['rollNo'] ?? 'N/A',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteers List"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Builder(
            builder: (context) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchVolunteers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Export to Excel',
                    onPressed: () async {
                      await _exportToExcel(context, snapshot.data!);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('volunteers')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading volunteers'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final volunteers = snapshot.data!.docs;
          if (volunteers.isEmpty) {
            return const Center(child: Text('No approved volunteers found.'));
          }
          return ListView.builder(
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final doc = volunteers[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'N/A';
              final studentClass = data['class'] ?? 'N/A';
              final rollNo = data['rollNo'] ?? 'N/A';
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${index + 1}. Name: $name",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Class: $studentClass",
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      "Roll No: $rollNo",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;

  void _showAddActivityForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Add New Activity",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Activity Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: timingController,
                decoration: const InputDecoration(labelText: 'Timing'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hours'),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      dateController.text = DateFormat(
                        'dd-MM-yyyy',
                      ).format(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Activity"),
                onPressed: _addActivity,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addActivity() async {
    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        timingController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        hoursController.text.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    await firestore.collection('activities').add({
      'title': titleController.text.trim(),
      'location': locationController.text.trim(),
      'timing': timingController.text.trim(),
      'description': descriptionController.text.trim(),
      'hours': int.tryParse(hoursController.text.trim()) ?? 0,
      'date': Timestamp.fromDate(selectedDate!),
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity added successfully')),
    );

    titleController.clear();
    locationController.clear();
    timingController.clear();
    descriptionController.clear();
    hoursController.clear();
    dateController.clear();
    selectedDate = null;
  }

  void _showEditActivitySheet(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final titleController = TextEditingController(text: data['title'] ?? '');
    final locationController = TextEditingController(
      text: data['location'] ?? '',
    );
    final timingController = TextEditingController(text: data['timing'] ?? '');
    final descriptionController = TextEditingController(
      text: data['description'] ?? '',
    );
    final hoursController = TextEditingController(
      text: data['hours']?.toString() ?? '',
    );
    final Timestamp? dateTimestamp = data['date'] as Timestamp?;
    DateTime? selectedDate = dateTimestamp?.toDate();
    final dateController = TextEditingController(
      text: dateTimestamp != null
          ? DateFormat('dd-MM-yyyy').format(dateTimestamp.toDate())
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Activity",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Activity Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: timingController,
                decoration: const InputDecoration(labelText: 'Timing'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: hoursController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hours'),
              ),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                    dateController.text = DateFormat(
                      'dd-MM-yyyy',
                    ).format(picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      locationController.text.isEmpty ||
                      timingController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      hoursController.text.isEmpty ||
                      selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }
                  await firestore.collection('activities').doc(docId).update({
                    'title': titleController.text.trim(),
                    'location': locationController.text.trim(),
                    'timing': timingController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'hours': int.tryParse(hoursController.text.trim()) ?? 0,
                    'date': Timestamp.fromDate(selectedDate!),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Activity updated successfully'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await firestore.collection('activities').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityForm(context),
        child: const Icon(Icons.add),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('activities')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final activities = snapshot.data!.docs;

              if (activities.isEmpty) {
                return const Center(child: Text('No activities available.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final doc = activities[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final title = data['title'] ?? 'No Title';
                  final location = data['location'] ?? 'No Location';
                  final timing = data['timing'] ?? 'No Timing';
                  final hours = data['hours']?.toString() ?? '0';
                  final Timestamp? dateTimestamp = data['date'] as Timestamp?;
                  final date = dateTimestamp != null
                      ? DateFormat('dd-MM-yyyy').format(dateTimestamp.toDate())
                      : 'No Date';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.event,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Location: $location\n'
                                        'Timing: $timing\n'
                                        'Date: $date\n'
                                        'Hours: $hours',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _confirmAndDelete(context, doc.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.people,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ViewParticipantsPage(
                                                  activityId: doc.id,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {
                                        _showEditActivitySheet(
                                          context,
                                          doc.id,
                                          data,
                                        );
                                      },
                                      tooltip: 'Edit Activity',
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.event,
                                      size: 40,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _confirmAndDelete(context, doc.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.people,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ViewParticipantsPage(
                                                  activityId: doc.id,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () {
                                        _showEditActivitySheet(
                                          context,
                                          doc.id,
                                          data,
                                        );
                                      },
                                      tooltip: 'Edit Activity',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Location: $location\n'
                                  'Timing: $timing\n'
                                  'Date: $date\n'
                                  'Hours: $hours',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ViewParticipantsPage extends StatelessWidget {
  final String activityId;

  const ViewParticipantsPage({super.key, required this.activityId});

  Future<void> _exportParticipantsToExcel(
    BuildContext context,
    List<Map<String, dynamic>> volunteerDetails,
    String activityName,
  ) async {
    final xls = excel.Excel.createExcel();
    final sheet = xls['Sheet1'];
    sheet.appendRow([excel.TextCellValue(activityName)]);
    sheet.appendRow([
      excel.TextCellValue('Name'),
      excel.TextCellValue('Class'),
      excel.TextCellValue('Roll No'),
    ]);
    for (var v in volunteerDetails) {
      sheet.appendRow([
        excel.TextCellValue(v['name'] ?? ''),
        excel.TextCellValue(v['class'] ?? ''),
        excel.TextCellValue(v['rollNo'] ?? ''),
      ]);
    }
    final fileBytes = xls.encode();
    if (fileBytes != null) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${activityName}_participants.xlsx');
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Participants for $activityName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Export button in the app bar for mobile
          Builder(
            builder: (context) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchVolunteerDetails(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Export to Excel',
                    onPressed: () async {
                      // Fetch activity name for file naming
                      final activityDoc = await FirebaseFirestore.instance
                          .collection('activities')
                          .doc(activityId)
                          .get();
                      final activityName =
                          activityDoc.data()?['title'] ?? 'Activity';
                      await _exportParticipantsToExcel(
                        context,
                        snapshot.data!,
                        activityName,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('participation')
            .where('activityId', isEqualTo: activityId)
            .where('status', isEqualTo: 'participated')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final participationDocs = snapshot.data!.docs;
          if (participationDocs.isEmpty) {
            return const Center(child: Text('No participants yet.'));
          }
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(
              participationDocs.map((doc) async {
                final volunteerId = doc['volunteerId'];
                final volunteerSnap = await FirebaseFirestore.instance
                    .collection('volunteers')
                    .doc(volunteerId)
                    .get();
                final vData = volunteerSnap.data() ?? {};
                return {
                  'name': vData['name'] ?? 'No Name',
                  'class': vData['class'] ?? 'No Class',
                  'rollNo': vData['rollNo'] ?? 'No Roll',
                };
              }).toList(),
            ),
            builder: (context, volunteerSnap) {
              if (!volunteerSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final volunteerDetails = volunteerSnap.data!;
              return ListView.builder(
                itemCount: participationDocs.length,
                itemBuilder: (context, index) {
                  final participationDoc = participationDocs[index];
                  final volunteerId = participationDoc['volunteerId'];
                  final vFuture = FirebaseFirestore.instance
                      .collection('volunteers')
                      .doc(volunteerId)
                      .get();
                  return FutureBuilder<DocumentSnapshot>(
                    future: vFuture,
                    builder: (context, vSnap) {
                      if (!vSnap.hasData) {
                        return const ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Loading...'),
                        );
                      }
                      final vData = vSnap.data!.data() as Map<String, dynamic>? ?? {};
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(vData['name'] ?? ''),
                        subtitle: Text(
                          'Class: 	${vData['class'] ?? ''}\nRoll No: 	${vData['rollNo'] ?? ''}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          tooltip: 'Remove from Activity',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Remove Participant'),
                                content: Text('Are you sure you want to remove this volunteer from the activity?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Remove'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              // Delete the participation doc
                              await FirebaseFirestore.instance
                                  .collection('participation')
                                  .doc(participationDoc.id)
                                  .delete();
                              // Add a new doc with status 'removed' to prevent re-join
                              await FirebaseFirestore.instance
                                  .collection('participation')
                                  .add({
                                    'volunteerId': volunteerId,
                                    'activityId': activityId,
                                    'status': 'removed',
                                    'removedAt': FieldValue.serverTimestamp(),
                                  });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Volunteer removed from activity.')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchVolunteerDetails() async {
    final participationSnapshot = await FirebaseFirestore.instance
        .collection('participation')
        .where('activityId', isEqualTo: activityId)
        .where('status', isEqualTo: 'participated')
        .get();
    return Future.wait(
      participationSnapshot.docs.map((doc) async {
        final volunteerId = doc['volunteerId'];
        final volunteerSnap = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(volunteerId)
            .get();
        final vData = volunteerSnap.data() ?? {};
        return {
          'name': vData['name'] ?? 'No Name',
          'class': vData['class'] ?? 'No Class',
          'rollNo': vData['rollNo'] ?? 'No Roll',
        };
      }).toList(),
    );
  }
}

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Text(
              "Report export and view will be implemented here.",
              style: TextStyle(
                fontSize: constraints.maxWidth > 600 ? 22 : 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}

class TrackHoursPage extends StatefulWidget {
  const TrackHoursPage({super.key});

  @override
  State<TrackHoursPage> createState() => _TrackHoursPageState();
}

class _TrackHoursPageState extends State<TrackHoursPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> volunteerHours = {};

  @override
  void initState() {
    super.initState();
    _loadVolunteerHours();
  }

  Future<void> _loadVolunteerHours() async {
    try {
      // Get all approved volunteers
      final volunteersSnapshot = await _firestore
          .collection('volunteers')
          .where('status', isEqualTo: 'approved')
          .get();

      for (var volunteerDoc in volunteersSnapshot.docs) {
        final volunteerId = volunteerDoc.id;

        // Get all participation records for this volunteer
        final participationSnapshot = await _firestore
            .collection('participation')
            .where('volunteerId', isEqualTo: volunteerId)
            .where('status', isEqualTo: 'participated')
            .get();

        int totalHours = 0;

        // Calculate total hours from activities
        for (var participationDoc in participationSnapshot.docs) {
          final participationData = participationDoc.data();
          final activityId = participationData['activityId'];

          if (activityId != null) {
            // Get the activity details
            final activityDoc = await _firestore
                .collection('activities')
                .doc(activityId)
                .get();

            if (activityDoc.exists) {
              final activityData = activityDoc.data();
              if (activityData != null && activityData['hours'] != null) {
                final hours = activityData['hours'];
                if (hours is int) {
                  totalHours += hours;
                } else if (hours is String) {
                  totalHours += int.tryParse(hours) ?? 0;
                }
              }
            }
          }
        }

        setState(() {
          volunteerHours[volunteerId] = totalHours;
        });
      }
    } catch (e) {
      print('Error loading volunteer hours: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Hours'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVolunteerHours,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('volunteers')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final volunteers = snapshot.data!.docs;

          if (volunteers.isEmpty) {
            return const Center(child: Text('No approved volunteers found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final doc = volunteers[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'No Name';
              final studentClass = data['class'] ?? 'No Class';
              final rollNo = data['rollNo'] ?? 'No Roll';
              final volunteerId = doc.id;
              final totalHours = volunteerHours[volunteerId] ?? 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VolunteerParticipationPage(
                          volunteerId: volunteerId,
                          volunteerName: name,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue,
                              radius: 20,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Class: $studentClass',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Roll No: $rollNo',
                                    style: const TextStyle(fontSize: 14),
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
                                color: totalHours > 0
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalHours hrs',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: totalHours > 0
                                ? Colors.green.shade50
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: totalHours > 0
                                  ? Colors.green.shade200
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Total Hours: $totalHours',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: totalHours > 0
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VolunteerParticipationPage extends StatelessWidget {
  final String volunteerId;
  final String volunteerName;

  const VolunteerParticipationPage({
    super.key,
    required this.volunteerId,
    required this.volunteerName,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Participation: $volunteerName'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: firestore
            .collection('activities')
            .orderBy('date', descending: true)
            .get(),
        builder: (context, activitySnapshot) {
          if (!activitySnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final activities = activitySnapshot.data!.docs;

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activityDoc = activities[index];
              final activityData = activityDoc.data() as Map<String, dynamic>;
              final activityId = activityDoc.id;
              final title = activityData['title'] ?? 'No Title';
              final dateTimestamp = activityData['date'] as Timestamp?;
              final date = dateTimestamp != null
                  ? DateFormat('dd-MM-yyyy').format(dateTimestamp.toDate())
                  : 'No Date';

              return FutureBuilder<QuerySnapshot>(
                future: firestore
                    .collection('participation')
                    .where('volunteerId', isEqualTo: volunteerId)
                    .where('activityId', isEqualTo: activityId)
                    .where('status', isEqualTo: 'participated')
                    .get(),
                builder: (context, participationSnapshot) {
                  bool participated =
                      participationSnapshot.hasData &&
                      participationSnapshot.data!.docs.isNotEmpty;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: Icon(
                        participated ? Icons.check_circle : Icons.cancel,
                        color: participated ? Colors.green : Colors.red,
                      ),
                      title: Text(title),
                      subtitle: Text('Date: $date'),
                      trailing: participated
                          ? const Text(
                              'Participated',
                              style: TextStyle(color: Colors.green),
                            )
                          : const Text(
                              'Not Participated',
                              style: TextStyle(color: Colors.red),
                            ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController agendaController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _showAddMeetingForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create Meeting",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      dateController.text =
                          "${pickedDate.day.toString().padLeft(2, '0')}-"
                          "${pickedDate.month.toString().padLeft(2, '0')}-"
                          "${pickedDate.year}";
                    });
                  }
                },
              ),
              TextField(
                controller: timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                      timeController.text = pickedTime.format(context);
                    });
                  }
                },
              ),
              TextField(
                controller: placeController,
                decoration: const InputDecoration(labelText: 'Place'),
              ),
              TextField(
                controller: agendaController,
                decoration: const InputDecoration(labelText: 'Agenda'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (dateController.text.isNotEmpty &&
                      timeController.text.isNotEmpty &&
                      placeController.text.isNotEmpty &&
                      agendaController.text.isNotEmpty) {
                    await firestore.collection('meetings').add({
                      'date': dateController.text.trim(),
                      'time': timeController.text.trim(),
                      'place': placeController.text.trim(),
                      'agenda': agendaController.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meeting created successfully'),
                      ),
                    );
                    dateController.clear();
                    timeController.clear();
                    placeController.clear();
                    agendaController.clear();
                    selectedDate = null;
                    selectedTime = null;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: const Text('Create'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMeetingSheet(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final dateController = TextEditingController(text: data['date'] ?? '');
    final timeController = TextEditingController(text: data['time'] ?? '');
    final placeController = TextEditingController(text: data['place'] ?? '');
    final agendaController = TextEditingController(text: data['agenda'] ?? '');
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Meeting",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dateController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}-"
                        "${pickedDate.month.toString().padLeft(2, '0')}-"
                        "${pickedDate.year}";
                  }
                },
              ),
              TextField(
                controller: timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    selectedTime = pickedTime;
                    timeController.text = pickedTime.format(context);
                  }
                },
              ),
              TextField(
                controller: placeController,
                decoration: const InputDecoration(labelText: 'Place'),
              ),
              TextField(
                controller: agendaController,
                decoration: const InputDecoration(labelText: 'Agenda'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (dateController.text.isNotEmpty &&
                      timeController.text.isNotEmpty &&
                      placeController.text.isNotEmpty &&
                      agendaController.text.isNotEmpty) {
                    await firestore.collection('meetings').doc(docId).update({
                      'date': dateController.text.trim(),
                      'time': timeController.text.trim(),
                      'place': placeController.text.trim(),
                      'agenda': agendaController.text.trim(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meeting updated successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showMeetingResponsesSheet(
    BuildContext context,
    String meetingId,
  ) async {
    final responsesRef = FirebaseFirestore.instance
        .collection('meetings')
        .doc(meetingId)
        .collection('responses');
    final allResponsesSnap = await responsesRef.get();
    final allResponses = allResponsesSnap.docs;

    // Fetch volunteer details for each response
    List<Map<String, dynamic>> volunteerDetails = [];
    for (var resp in allResponses) {
      final volunteerId = resp.id;
      final volunteerSnap = await FirebaseFirestore.instance
          .collection('volunteers')
          .doc(volunteerId)
          .get();
      if (volunteerSnap.exists) {
        final vData = volunteerSnap.data()!;
        volunteerDetails.add({
          'name': vData['name'] ?? '',
          'class': vData['class'] ?? '',
          'rollNo': vData['rollNo'] ?? '',
        });
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Meeting Responses',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (volunteerDetails.isEmpty) const Text('No responses yet.'),
            if (volunteerDetails.isNotEmpty)
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: volunteerDetails.length,
                  itemBuilder: (context, idx) {
                    final v = volunteerDetails[idx];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(v['name'] ?? ''),
                      subtitle: Text(
                        'Class: ${v['class'] ?? ''} | Roll No: ${v['rollNo'] ?? ''}',
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMeetingForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('meetings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final meetings = snapshot.data!.docs;
          if (meetings.isEmpty) {
            return const Center(child: Text('No meetings available.'));
          }
          return ListView.builder(
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final doc = meetings[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.meeting_room, color: Colors.blue),
                  title: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Agenda: ',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: data['agenda'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    'Date: ${data['date'] ?? ''}\nTime: ${data['time'] ?? ''}\nPlace: ${data['place'] ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.people, color: Colors.green),
                        tooltip: 'View Responses',
                        onPressed: () {
                          _showMeetingResponsesSheet(context, doc.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Meeting',
                        onPressed: () {
                          _showEditMeetingSheet(context, doc.id, data);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NSSCampPage extends StatefulWidget {
  const NSSCampPage({super.key});

  @override
  State<NSSCampPage> createState() => _NSSCampPageState();
}

class _NSSCampPageState extends State<NSSCampPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? selectedDay;
  List<Map<String, dynamic>> volunteerReports = [];
  bool loadingReports = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NSS Camp'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NSS Camp Days Cards ---
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8.0,
            ),
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = 'Day ${index + 1}';
                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedDay = day;
                        loadingReports = true;
                      });
                      // Fetch reports for this day
                      final reportsSnap = await firestore
                          .collection('camp_reports')
                          .where('day', isEqualTo: day)
                          .get();
                      final reports = reportsSnap.docs;
                      Map<String, List<Map<String, dynamic>>> groupedReports =
                          {};
                      Map<String, Map<String, dynamic>> volunteerInfo = {};
                      for (var doc in reports) {
                        final data = doc.data();
                        final volunteerId = data['volunteerId'];
                        if (volunteerId == null ||
                            (volunteerId is String && volunteerId.isEmpty)) {
                          continue;
                        }
                        if (!groupedReports.containsKey(volunteerId)) {
                          groupedReports[volunteerId] = [];
                        }
                        groupedReports[volunteerId]!.add({
                          'report': data['report'] ?? '',
                          'fromTime': data['fromTime'] ?? '',
                          'toTime': data['toTime'] ?? '',
                        });
                      }
                      // Fetch volunteer info for each unique volunteerId
                      for (var volunteerId in groupedReports.keys) {
                        final volunteerSnap = await firestore
                            .collection('volunteers')
                            .doc(volunteerId)
                            .get();
                        final vData = volunteerSnap.data() ?? {};
                        volunteerInfo[volunteerId] = {
                          'name': vData['name'] ?? '',
                          'class': vData['class'] ?? '',
                          'rollNo': vData['rollNo'] ?? '',
                        };
                      }
                      List<Map<String, dynamic>> volunteerList = groupedReports
                          .keys
                          .map(
                            (volunteerId) => {
                              'volunteerId': volunteerId,
                              'name': volunteerInfo[volunteerId]?['name'] ?? '',
                              'class':
                                  volunteerInfo[volunteerId]?['class'] ?? '',
                              'rollNo':
                                  volunteerInfo[volunteerId]?['rollNo'] ?? '',
                              'reports': groupedReports[volunteerId] ?? [],
                            },
                          )
                          .toList();
                      setState(() {
                        volunteerReports = volunteerList;
                        loadingReports = false;
                      });
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: selectedDay == day
                            ? Colors.blue[200]
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (selectedDay != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Reports for $selectedDay',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          if (loadingReports) const Center(child: CircularProgressIndicator()),
          if (selectedDay != null && !loadingReports)
            Expanded(
              child: volunteerReports.isEmpty
                  ? const Center(
                      child: Text('No reports submitted for this day.'),
                    )
                  : ListView.builder(
                      itemCount: volunteerReports.length,
                      itemBuilder: (context, index) {
                        final v = volunteerReports[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            title: Text(v['name'] ?? ''),
                            subtitle: Text(
                              'Class: ${v['class']} | Roll No: ${v['rollNo']}',
                            ),
                            onTap: () {
                              _showVolunteerReportsSheet(context, v);
                            },
                          ),
                        );
                      },
                    ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('nss_camps')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final camps = snapshot.data!.docs;
                if (camps.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ListView.builder(
                  itemCount: camps.length,
                  itemBuilder: (context, index) {
                    final data = camps[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.forest, color: Colors.green),
                        title: Text('Agenda: ${data['agenda'] ?? ''}'),
                        subtitle: Text(
                          'Date: ${data['date'] ?? ''}\nTime: ${data['time'] ?? ''}\nPlace: ${data['place'] ?? ''}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showVolunteerReportsSheet(
    BuildContext context,
    Map<String, dynamic> volunteer,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reports by ${volunteer['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            if (volunteer['reports'].isEmpty)
              const Text('No reports submitted.')
            else
              SizedBox(
                height: 300,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: volunteer['reports'].length,
                  separatorBuilder: (context, idx) => const Divider(),
                  itemBuilder: (context, idx) {
                    final rep = volunteer['reports'][idx];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time: ${rep['fromTime']} - ${rep['toTime']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Report:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(rep['report'] ?? ''),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class ManageNoticesPage extends StatefulWidget {
  const ManageNoticesPage({super.key});

  @override
  State<ManageNoticesPage> createState() => _ManageNoticesPageState();
}

class _ManageNoticesPageState extends State<ManageNoticesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _showAddNoticeSheet() {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create Notice",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dateController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}-"
                        "${pickedDate.month.toString().padLeft(2, '0')}-"
                        "${pickedDate.year}";
                  }
                },
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Create"),
                onPressed: () async {
                  if (dateController.text.isNotEmpty &&
                      descController.text.isNotEmpty) {
                    await firestore.collection('notices').add({
                      'date': dateController.text.trim(),
                      'description': descController.text.trim(),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notice created successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNoticeSheet(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final TextEditingController dateController = TextEditingController(
      text: data['date'] ?? '',
    );
    final TextEditingController descController = TextEditingController(
      text: data['description'] ?? '',
    );
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Notice",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dateController.text =
                        "${pickedDate.day.toString().padLeft(2, '0')}-"
                        "${pickedDate.month.toString().padLeft(2, '0')}-"
                        "${pickedDate.year}";
                  }
                },
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                onPressed: () async {
                  if (dateController.text.isNotEmpty &&
                      descController.text.isNotEmpty) {
                    await firestore.collection('notices').doc(doc.id).update({
                      'date': dateController.text.trim(),
                      'description': descController.text.trim(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notice updated successfully'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteNotice(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notice'),
        content: const Text('Are you sure you want to delete this notice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await firestore.collection('notices').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notices'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Notice',
            onPressed: _showAddNoticeSheet,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('notices')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notices = snapshot.data!.docs;
          if (notices.isEmpty) {
            return const Center(child: Text('No notices available.'));
          }
          return ListView.builder(
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final doc = notices[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = data['date'] ?? '';
              final desc = data['description'] ?? '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: Colors.orange,
                  ),
                  title: Text(
                    desc,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Date: $date'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit',
                        onPressed: () => _showEditNoticeSheet(doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeleteNotice(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
