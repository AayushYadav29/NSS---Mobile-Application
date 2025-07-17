import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
// Conditional import for web
import 'export_excel_stub.dart' if (dart.library.html) 'export_excel_web.dart';

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

  void _showAddNoticeDialog(BuildContext context) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Notice'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (dateController.text.isNotEmpty &&
                  descController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('notices').add({
                  'date': dateController.text.trim(),
                  'description': descController.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notice created successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 49, 214),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Image.asset(
              'assets/nss_logo.png',
              height: 36,
              width: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'NSS - Not Me But You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== DASHBOARD CARDS =====
                      Expanded(
                        flex: 3,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 800;
                            final cards = [
                              _buildDashboardCard(
                                "Volunteers",
                                Icons.group,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VolunteersListPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                "Activities",
                                Icons.event,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ActivitiesPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                "Manage Volunteers",
                                Icons.verified_user,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ManageVolunteerPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                "Reports",
                                Icons.insert_chart,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard("NSS Camp", Icons.forest, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NSSCampPage(),
                                  ),
                                );
                              }),
                              _buildDashboardCard(
                                "Track Hours",
                                Icons.timer,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrackHoursPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                "Meetings",
                                Icons.meeting_room,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MeetingsPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                "Notice",
                                Icons.notifications,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ManageNoticesPage(),
                                    ),
                                  );
                                },
                              ),
                            ];
                            return GridView.count(
                              crossAxisCount: isWide ? 4 : 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: cards,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                      // ===== PIE CHART SECTION =====
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Text(
                              "Volunteer Overview",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                                  height: 250,
                                  width: 250,
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
                                          value: (75 - volunteerCount)
                                              .toDouble(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Volunteers Joined",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text("$volunteerCount"),
                                  ],
                                ),
                                Column(
                                  children: const [
                                    Text(
                                      "Total Batch",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text("75"),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // ===== RECENT ACTIVITY PANEL =====
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          child: StreamBuilder(
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
                                  final activity = activities[index].data();
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('volunteers')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final volunteers = snapshot.data!.docs;

          if (volunteers.isEmpty) {
            return const Center(child: Text('No pending volunteers.'));
          }

          return ListView.builder(
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final doc = volunteers[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? '';
              final rollNo = data['rollNo'] ?? '';
              final studentClass = data['class'] ?? '';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text('Roll No: $rollNo | Class: $studentClass'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final username = name.split(' ')[0].toLowerCase();
                          _showSetPasswordDialog(context, doc, username, name);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Reject the volunteer in Firestore
                          await firestore
                              .collection('volunteers')
                              .doc(doc.id)
                              .update({'status': 'rejected'});

                          // Add to recent_activity for logging
                          await firestore.collection('recent_activity').add({
                            'message':
                                'Rejected volunteer: ${data['name'] ?? 'Unknown'}',
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          // Show a confirmation message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Volunteer rejected')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
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

class VolunteersListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VolunteersListPage({super.key});

  void _exportToExcel(List<QueryDocumentSnapshot> volunteers) {
    final xls = excel.Excel.createExcel();
    final sheet = xls['Volunteers'];
    // Add header
    sheet.appendRow([
      excel.TextCellValue('Name'),
      excel.TextCellValue('Class'),
      excel.TextCellValue('Roll No'),
    ]);
    // Add data
    for (var doc in volunteers) {
      final data = doc.data() as Map<String, dynamic>;
      sheet.appendRow([
        excel.TextCellValue(data['name'] ?? ''),
        excel.TextCellValue(data['class'] ?? ''),
        excel.TextCellValue(data['rollNo'] ?? ''),
      ]);
    }
    final fileBytes = xls.encode();
    if (fileBytes != null) {
      final blob = html.Blob([
        fileBytes,
      ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'volunteers.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Volunteers List"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('volunteers')
            .where('status', isEqualTo: 'approved') // ✅ filters only approved
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

          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export to Excel'),
                    onPressed: () => _exportToExcel(volunteers),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
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
                ),
              ),
            ],
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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hoursController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime? selectedDate;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _showAddActivityForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Activity'),
        content: SingleChildScrollView(
          child: Column(
            children: [
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
                maxLines: 3,
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  timingController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  hoursController.text.isNotEmpty &&
                  selectedDate != null) {
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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Add Activity'),
          ),
        ],
      ),
    );
  }

  void _showEditActivityDialog(
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
    final dateController = TextEditingController(
      text: data['date'] is Timestamp
          ? "${(data['date'] as Timestamp).toDate().day.toString().padLeft(2, '0')}-"
                "${(data['date'] as Timestamp).toDate().month.toString().padLeft(2, '0')}-"
                "${(data['date'] as Timestamp).toDate().year}"
          : (data['date'] ?? ''),
    );
    DateTime? selectedDate = data['date'] is Timestamp
        ? (data['date'] as Timestamp).toDate()
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Activity'),
        content: SingleChildScrollView(
          child: Column(
            children: [
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
                maxLines: 3,
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
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  timingController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  hoursController.text.isNotEmpty &&
                  selectedDate != null) {
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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
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
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddActivityForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                  ? "${dateTimestamp.toDate().day.toString().padLeft(2, '0')}-"
                        "${dateTimestamp.toDate().month.toString().padLeft(2, '0')}-"
                        "${dateTimestamp.toDate().year}"
                  : 'No Date';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.event, size: 40, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Location: $location\n'
                              'Timing: $timing\n'
                              'Date: $date\n'
                              'Hours: $hours',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmAndDelete(context, doc.id),
                            tooltip: 'Delete Activity',
                          ),
                          IconButton(
                            icon: const Icon(Icons.people, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ViewParticipantsPage(activityId: doc.id),
                                ),
                              );
                            },
                            tooltip: 'View Participants',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              _showEditActivityDialog(context, doc.id, data);
                            },
                            tooltip: 'Edit Activity',
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
      ),
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
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      body: const Center(
        child: Text("Report export and view will be implemented here."),
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
      final activityFileName = '${activityName}_participants.xlsx';
      if (kIsWeb) {
        saveExcelWeb(fileBytes, activityFileName);
      } else {
        // For desktop, use FileSaver if available
        // await FileSaver.instance.saveFile(
        //   name: activityFileName,
        //   bytes: Uint8List.fromList(fileBytes),
        //   ext: 'xlsx',
        //   mimeType: MimeType.microsoftExcel,
        // );
      }
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
        titleTextStyle: const TextStyle(color: Colors.white),
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

          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export to Excel'),
                    onPressed: () async {
                      // Fetch activity name for file naming
                      final activityDoc = await FirebaseFirestore.instance
                          .collection('activities')
                          .doc(activityId)
                          .get();
                      final activityName =
                          activityDoc.data()?['title'] ?? 'Activity';
                      // For export, gather all volunteer details
                      final volunteerDetails = await Future.wait(
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
                      );
                      await _exportParticipantsToExcel(
                        context,
                        volunteerDetails,
                        activityName,
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
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
                ),
              ),
            ],
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
        titleTextStyle: const TextStyle(color: Colors.white),
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Class: $studentClass'),
                      Text('Roll No: $rollNo'),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: totalHours > 0
                              ? Colors.green.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: totalHours > 0 ? Colors.green : Colors.grey,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: totalHours > 0 ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalHours hrs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
        titleTextStyle: const TextStyle(color: Colors.white),
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
                  ? "${dateTimestamp.toDate().day.toString().padLeft(2, '0')}-"
                        "${dateTimestamp.toDate().month.toString().padLeft(2, '0')}-"
                        "${dateTimestamp.toDate().year}"
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Meeting'),
        content: SingleChildScrollView(
          child: Column(
            children: [
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
                  const SnackBar(content: Text('Meeting created successfully')),
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
        ],
      ),
    );
  }

  void _showEditMeetingDialog(
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meeting'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
                  const SnackBar(content: Text('Meeting updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMeetingResponsesDialog(
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Meeting Responses'),
          content: volunteerDetails.isEmpty
              ? const Text('No responses yet.')
              : SizedBox(
                  width: 350,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
        titleTextStyle: const TextStyle(color: Colors.white),
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
                          _showMeetingResponsesDialog(context, doc.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Meeting',
                        onPressed: () {
                          _showEditMeetingDialog(context, doc.id, data);
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
        titleTextStyle: const TextStyle(color: Colors.white),
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
              height: 110,
              child: GridView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
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
                    child: Card(
                      color: selectedDay == day
                          ? Colors.blue[200]
                          : Colors.blue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Reports by ${v['name']}'),
                                  content: SizedBox(
                                    width: 350,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: v['reports'].length,
                                      separatorBuilder: (context, idx) =>
                                          const Divider(),
                                      itemBuilder: (context, idx) {
                                        final rep = v['reports'][idx];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Time: ${rep['fromTime']} - ${rep['toTime']}',
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Report:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(rep['report'] ?? ''),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
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
}

class ManageNoticesPage extends StatefulWidget {
  const ManageNoticesPage({super.key});

  @override
  State<ManageNoticesPage> createState() => _ManageNoticesPageState();
}

class _ManageNoticesPageState extends State<ManageNoticesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _showEditNoticeDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final TextEditingController dateController = TextEditingController(
      text: data['date'] ?? '',
    );
    final TextEditingController descController = TextEditingController(
      text: data['description'] ?? '',
    );
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Notice'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (dateController.text.isNotEmpty &&
                  descController.text.isNotEmpty) {
                await firestore.collection('notices').doc(doc.id).update({
                  'date': dateController.text.trim(),
                  'description': descController.text.trim(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notice updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddNoticeDialog() {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Notice'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
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
                  const SnackBar(content: Text('Notice created successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
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
        titleTextStyle: const TextStyle(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Notice',
            onPressed: _showAddNoticeDialog,
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
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        onPressed: () => _showEditNoticeDialog(doc),
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
