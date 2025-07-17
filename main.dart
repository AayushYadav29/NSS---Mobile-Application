import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:fl_chart/fl_chart.dart';

// Place these at the very top of the file, before any imports or class definitions
void _showEditCampReportForm(
  BuildContext context,
  String docId,
  Map<String, dynamic> data,
  String volunteerId,
) {
  final reportController = TextEditingController(text: data['report'] ?? '');
  TimeOfDay fromTime = _parseTimeOfDay(data['fromTime']) ?? TimeOfDay.now();
  TimeOfDay toTime = _parseTimeOfDay(data['toTime']) ?? TimeOfDay.now();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Report',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: fromTime,
                      );
                      if (picked != null) {
                        setState(() => fromTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(fromTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: toTime,
                      );
                      if (picked != null) {
                        setState(() => toTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(toTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What did you do?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                onPressed: () async {
                  final reportText = reportController.text.trim();
                  if (reportText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your report.'),
                      ),
                    );
                    return;
                  }
                  await FirebaseFirestore.instance
                      .collection('camp_reports')
                      .doc(docId)
                      .update({
                        'fromTime': fromTime.format(context),
                        'toTime': toTime.format(context),
                        'report': reportText,
                      });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report updated!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

TimeOfDay? _parseTimeOfDay(dynamic timeString) {
  if (timeString == null || timeString is! String) return null;
  final time = TimeOfDayExtension.tryParse(timeString);
  return time;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NSS Login/Register',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: LoginRegisterPage(),
    );
  }
}

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final classController = TextEditingController();
  final mobileController = TextEditingController();

  Future<void> registerVolunteer(
    String name,
    String rollNo,
    String studentClass,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('volunteers').add({
        'name': name,
        'rollNo': rollNo,
        'class': studentClass,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration submitted, pending approval.')),
      );
      nameController.clear();
      rollController.clear();
      classController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/nss_logo.png', height: 100),
                  SizedBox(height: 16),
                  ToggleButtons(
                    isSelected: [isLogin, !isLogin],
                    onPressed: (int index) {
                      setState(() {
                        isLogin = index == 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: Colors.blue,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Login'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Register'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  if (isLogin) ...[
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          String enteredUsername = usernameController.text
                              .trim();
                          String enteredPassword = passwordController.text
                              .trim();

                          if (enteredUsername.isEmpty ||
                              enteredPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter username and password',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            // Query Firestore for the entered credentials
                            QuerySnapshot snapshot = await FirebaseFirestore
                                .instance
                                .collection('volunteers')
                                .where('username', isEqualTo: enteredUsername)
                                .where('password', isEqualTo: enteredPassword)
                                .get();

                            if (snapshot.docs.isNotEmpty) {
                              String volunteerId = snapshot
                                  .docs
                                  .first
                                  .id; // ✅ get volunteerId correctly

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VolunteerDashboardPage(
                                    volunteerId: volunteerId,
                                  ), // ✅ pass volunteerId
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Invalid credentials'),
                                  action: SnackBarAction(
                                    label: 'Retry',
                                    onPressed: () {
                                      usernameController.clear();
                                      passwordController.clear();
                                    },
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },

                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name of Volunteer',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: rollController,
                      decoration: InputDecoration(
                        labelText: 'Roll No',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.confirmation_number,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: mobileController,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone, color: Colors.blue),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: classController,
                      decoration: InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.class_rounded,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          String name = nameController.text.trim();
                          String rollNo = rollController.text.trim();
                          String studentClass = classController.text.trim();
                          String mobile = mobileController.text.trim();

                          if (name.isNotEmpty &&
                              rollNo.isNotEmpty &&
                              studentClass.isNotEmpty &&
                              mobile.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('volunteers')
                                .add({
                                  'name': name,
                                  'rollNo': rollNo,
                                  'class': studentClass,
                                  'mobile': mobile,
                                  'status': 'pending', // default
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Registration submitted. Awaiting approval.',
                                ),
                              ),
                            );

                            nameController.clear();
                            rollController.clear();
                            classController.clear();
                            mobileController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please fill all fields including mobile number.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text('Register'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VolunteerDashboardPage extends StatefulWidget {
  final String volunteerId;

  const VolunteerDashboardPage({super.key, required this.volunteerId});

  @override
  State<VolunteerDashboardPage> createState() => _VolunteerDashboardPageState();
}

class _VolunteerDashboardPageState extends State<VolunteerDashboardPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int totalHours = 0;
  Map<String, int> monthlyParticipation = {
    'Jun': 0,
    'Jul': 0,
    'Aug': 0,
    'Sep': 0,
    'Oct': 0,
    'Nov': 0,
    'Dec': 0,
    'Jan': 0,
    'Feb': 0,
    'Mar': 0,
  };
  String? volunteerName; // Add this line

  @override
  void initState() {
    super.initState();
    calculateTotalHours();
    calculateMonthlyParticipation();
    fetchVolunteerName(); // Add this line
  }

  Future<void> fetchVolunteerName() async {
    try {
      final doc = await firestore
          .collection('volunteers')
          .doc(widget.volunteerId)
          .get();
      if (doc.exists) {
        setState(() {
          volunteerName = doc.data()?['name'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching volunteer name: $e');
    }
  }

  Future<void> calculateTotalHours() async {
    try {
      final participation = await firestore
          .collection('participation')
          .where('volunteerId', isEqualTo: widget.volunteerId)
          .where('status', isEqualTo: 'participated')
          .get();

      int hours = 0;

      for (var doc in participation.docs) {
        final activityId = doc['activityId'];
        if (activityId != null && activityId is String) {
          final activitySnapshot = await firestore
              .collection('activities')
              .doc(activityId)
              .get();

          if (activitySnapshot.exists) {
            final activityData = activitySnapshot.data();
            if (activityData != null && activityData['hours'] != null) {
              final activityHours = activityData['hours'];
              if (activityHours is int) {
                hours += activityHours;
              } else if (activityHours is String) {
                hours += int.tryParse(activityHours) ?? 0;
              }
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          totalHours = hours;
        });
      }
    } catch (e) {
      debugPrint('Error calculating total hours: $e');
    }
  }

  Future<void> calculateMonthlyParticipation() async {
    try {
      final participation = await firestore
          .collection('participation')
          .where('volunteerId', isEqualTo: widget.volunteerId)
          .where('status', isEqualTo: 'participated')
          .get();

      Map<String, int> counts = {
        'Jan': 0,
        'Feb': 0,
        'Mar': 0,
        'Apr': 0,
        'May': 0,
        'Jun': 0,
        'Jul': 0,
        'Aug': 0,
        'Sep': 0,
        'Oct': 0,
        'Nov': 0,
        'Dec': 0,
      };

      for (var doc in participation.docs) {
        if (doc['joinedAt'] != null && doc['joinedAt'] is Timestamp) {
          Timestamp ts = doc['joinedAt'];
          DateTime date = ts.toDate();
          String month = _getMonthName(date.month);

          if (counts.containsKey(month)) {
            counts[month] = counts[month]! + 1;
          }
        }
      }

      if (mounted) {
        setState(() {
          monthlyParticipation = counts;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating monthly participation: $e'),
          ),
        );
      }
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Ensures back arrow is white
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/nss_logo.png',
              height: 28, // Adjust as needed to match text size
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'NSS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24, // Match with logo height for alignment
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationsPage(volunteerId: widget.volunteerId),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (volunteerName != null && volunteerName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Welcome, $volunteerName!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHoursCompleted(),
            const SizedBox(height: 16),
            _buildNoticesSection(), // <-- Add this line
            const SizedBox(height: 16),
            _buildUpcomingActivity(),
            const SizedBox(height: 16),
            _buildParticipationGraph(),
            const SizedBox(height: 16),
            _buildQuickLinks(context, widget.volunteerId),
            const SizedBox(height: 16),
            _buildMeetingsSection(),
            const SizedBox(height: 16),
            _buildNSSCampSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursCompleted() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Hours Completed',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Column(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: totalHours / 100, // assuming 100 is goal
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      backgroundColor: Colors.blue[100],
                    ),
                    Center(
                      child: Text(
                        '$totalHours\nhours',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('activities')
                .orderBy('date', descending: true) // latest first
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final activities = snapshot.data!.docs;
              if (activities.isEmpty) {
                return const Center(child: Text('No activities available.'));
              }

              List<DocumentSnapshot> upcomingActivities = [];
              List<DocumentSnapshot> completedActivities = [];

              DateTime now = DateTime.now();

              for (var doc in activities) {
                Timestamp dateTs = doc['date'];
                DateTime activityDate = dateTs.toDate();

                if (activityDate.isAfter(now)) {
                  upcomingActivities.add(doc);
                } else {
                  completedActivities.add(doc);
                }
              }

              List<DocumentSnapshot> allActivities = [
                ...upcomingActivities,
                ...completedActivities.reversed,
              ];

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allActivities.length,
                itemBuilder: (context, index) {
                  final doc = allActivities[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final title = data['title'] ?? 'No Title';
                  final location = data['location'] ?? 'No Location';
                  final timing = data['timing'] ?? 'No Timing';
                  final description = data['description'] ?? '';
                  final hours = data['hours']?.toString() ?? '0';
                  final date = (data['date'] as Timestamp).toDate();
                  final formattedDate =
                      '${date.day}/${date.month}/${date.year}';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityDetailsPage(
                            volunteerId: widget.volunteerId,
                            activityId: doc.id,
                            data: data,
                          ),
                        ),
                      ).then((result) {
                        if (result == true) {
                          calculateTotalHours();
                          calculateMonthlyParticipation();
                        }
                      });
                    },
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.3),
                        ),
                      ),
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
                          const SizedBox(height: 6),
                          Text(
                            '📍 $location',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '⏰ $timing',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '📅 $formattedDate',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description.length > 50
                                ? '${description.substring(0, 50)}...'
                                : description,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          Text(
                            '$hours Hours',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParticipationGraph() {
    List<BarChartGroupData> barGroups = [];
    List<String> months = [
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
      'Jan',
      'Feb',
      'Mar',
    ];

    for (int i = 0; i < months.length; i++) {
      double plottedValue = (monthlyParticipation[months[i]]! / 2)
          .toDouble(); // scale for plotting
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: plottedValue,
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'My Activities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          height: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: months.length * 55,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      10, // allows up to 20 activities (since 1 unit = 2 activities)
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) =>
                        FlLine(color: Colors.grey.shade300, strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int displayValue = (value * 2)
                              .toInt(); // ensures 0, 2, 4, 6...
                          return Text(
                            '$displayValue',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                months[index],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          } else {
                            return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context, String volunteerId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Links',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // View Reports
        InkWell(
          onTap: () {
            // TODO: Navigate to reports page when ready
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reports feature coming soon!')),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 8),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.list, color: Colors.blue),
                SizedBox(width: 16),
                Text('View Reports', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),

        // Track Hours
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TrackHoursPage(volunteerId: volunteerId),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, blurRadius: 8),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 16),
                Text('Track Hours', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meetings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('meetings')
              .where('createdAt', isNotEqualTo: null)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final meetings = snapshot.data!.docs;
            if (meetings.isEmpty) {
              return const Text('No meetings available.');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final doc = meetings[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
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
                    onTap: () {
                      _showMeetingResponseDialog(context, doc.id);
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showMeetingResponseDialog(
    BuildContext context,
    String meetingId,
  ) async {
    final userId = widget.volunteerId;
    final responsesRef = FirebaseFirestore.instance
        .collection('meetings')
        .doc(meetingId)
        .collection('responses');
    final userResponseSnap = await responsesRef.doc(userId).get();
    String? selected;
    if (userResponseSnap.exists) {
      selected = userResponseSnap.data()?['response'] as String?;
    }

    // Fetch all responses for this meeting
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
          title: const Text('Meeting Response'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected == null)
                ElevatedButton(
                  onPressed: () async {
                    await responsesRef.doc(userId).set({
                      'response': 'Jai Hind Ok Leader',
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Response recorded!')),
                    );
                  },
                  child: const Text('Jai Hind Ok Leader'),
                ),
              if (selected != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'You responded: Jai Hind Ok Leader',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (volunteerDetails.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Text(
                      'Responses:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 180,
                      width: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
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
                  ],
                ),
            ],
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

  Widget _buildNSSCampSection() {
    final String volunteerId = widget.volunteerId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NSS Camp',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // --- NSS Camp Days Cards as Grid ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = 'Day ${index + 1}';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampDayReportsPage(
                        day: day,
                        volunteerId: volunteerId,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
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
        const SizedBox(height: 10),
        // Remove in-place report list and add button
        // ... keep the rest of the section unchanged ...
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('nss_camps')
              .where('createdAt', isNotEqualTo: null)
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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
      ],
    );
  }

  Widget _buildNoticesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notices',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notices')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final notices = snapshot.data!.docs;
            if (notices.isEmpty) {
              return const Text('No notices available.');
            }
            return SizedBox(
              height: 120, // Adjust height as needed
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final data = notices[index].data() as Map<String, dynamic>;
                  final date = data['date'] ?? '';
                  final desc = data['description'] ?? '';
                  return Container(
                    width: 280, // Adjust width as needed
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
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
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class ActivityDetailsPage extends StatefulWidget {
  final String volunteerId;
  final String activityId;
  final Map<String, dynamic> data;

  const ActivityDetailsPage({
    super.key,
    required this.volunteerId,
    required this.activityId,
    required this.data,
  });

  @override
  State<ActivityDetailsPage> createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  bool _hasResponded = false; // Track if user has responded

  @override
  void initState() {
    super.initState();
    checkParticipationStatus(); // Check Firestore on load
  }

  Future<void> checkParticipationStatus() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('participation')
        .where('volunteerId', isEqualTo: widget.volunteerId)
        .where('activityId', isEqualTo: widget.activityId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _hasResponded = true; // Already responded, hide buttons
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title'] ?? 'Activity Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        // Ensures scrollability
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location: ${data['location'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Timing: ${data['timing'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Description: ${data['description'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            if (!_hasResponded)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Check if volunteer is removed from this activity
                      final removedSnap = await FirebaseFirestore.instance
                          .collection('participation')
                          .where('volunteerId', isEqualTo: widget.volunteerId)
                          .where('activityId', isEqualTo: widget.activityId)
                          .where('status', isEqualTo: 'removed')
                          .get();
                      if (removedSnap.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You have been removed from this activity by the admin and cannot join again.'),
                          ),
                        );
                        return;
                      }
                      await FirebaseFirestore.instance
                          .collection('participation')
                          .add({
                            'volunteerId': widget.volunteerId,
                            'activityId': widget.activityId,
                            'status': 'participated',
                            'joinedAt': FieldValue.serverTimestamp(),
                          });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have joined this activity.'),
                        ),
                      );
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text('Participate'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('participation')
                          .add({
                            'volunteerId': widget.volunteerId,
                            'activityId': widget.activityId,
                            'status': 'not_interested',
                            'joinedAt': FieldValue.serverTimestamp(),
                          });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Marked as Not Interested.'),
                        ),
                      );

                      setState(() {
                        _hasResponded = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                    child: const Text('Not Interested'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class TrackHoursPage extends StatefulWidget {
  final String volunteerId;
  const TrackHoursPage({super.key, required this.volunteerId});

  @override
  State<TrackHoursPage> createState() => _TrackHoursPageState();
}

class _TrackHoursPageState extends State<TrackHoursPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, String> participationStatus = {}; // activityId -> status

  @override
  void initState() {
    super.initState();
    fetchParticipationStatus();
  }

  Future<void> fetchParticipationStatus() async {
    final participationSnapshot = await firestore
        .collection('participation')
        .where('volunteerId', isEqualTo: widget.volunteerId)
        .get();

    Map<String, String> statusMap = {};
    for (var doc in participationSnapshot.docs) {
      final data = doc.data();
      final activityId = data['activityId'] ?? '';
      final status = data['status'] ?? '';
      if (activityId.isNotEmpty) {
        statusMap[activityId] = status;
      }
    }

    if (mounted) {
      setState(() {
        participationStatus = statusMap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracked Hours'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('activities')
            .orderBy('date', descending: true)
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
              final activityId = doc.id;

              final hasParticipated =
                  participationStatus[activityId] == 'participated';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.event,
                    color: hasParticipated ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Location: $location\nTiming: $timing'),
                  trailing: hasParticipated
                      ? Text(
                          '+${hours}h',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          'NA',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
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

// 1. NotificationsPage widget
class NotificationsPage extends StatelessWidget {
  final String volunteerId;
  const NotificationsPage({super.key, required this.volunteerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final vid = data['volunteerId'];
            return vid == null || vid == volunteerId;
          }).toList();
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final body = data['body'] ?? '';
              final type = data['type'] ?? '';
              final createdAt = data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : null;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    type == 'notice'
                        ? Icons.notifications
                        : type == 'meeting'
                        ? Icons.meeting_room
                        : Icons.event,
                    color: Colors.blue,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(body),
                  trailing: createdAt != null
                      ? Text(
                          '${createdAt.day}/${createdAt.month}/${createdAt.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension TimeOfDayExtension on TimeOfDay {
  static TimeOfDay? tryParse(String input) {
    try {
      final format = RegExp(
        r'^(\d{1,2}):(\d{2}) ?([AP]M)?',
        caseSensitive: false,
      );
      final match = format.firstMatch(input);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        final ampm = match.group(3)?.toUpperCase();
        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }
}

void _showCampReportForm(BuildContext context, String day, String volunteerId) {
  final reportController = TextEditingController();
  TimeOfDay fromTime = TimeOfDay.now();
  TimeOfDay toTime = TimeOfDay(
    hour: (TimeOfDay.now().hour + 2) % 24,
    minute: TimeOfDay.now().minute,
  );
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report for $day',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: fromTime,
                      );
                      if (picked != null) {
                        setState(() => fromTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(fromTime.format(context)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: toTime,
                      );
                      if (picked != null) {
                        setState(() => toTime = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(toTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What did you do?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Submit Report'),
                onPressed: () async {
                  final reportText = reportController.text.trim();
                  if (reportText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your report.'),
                      ),
                    );
                    return;
                  }
                  if (volunteerId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID not found. Please re-login.'),
                      ),
                    );
                    return;
                  }
                  await FirebaseFirestore.instance
                      .collection('camp_reports')
                      .add({
                        'volunteerId': volunteerId,
                        'day': day,
                        'fromTime': fromTime.format(context),
                        'toTime': toTime.format(context),
                        'report': reportText,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}

// New page for volunteer's reports for a day
class CampDayReportsPage extends StatelessWidget {
  final String day;
  final String volunteerId;
  const CampDayReportsPage({
    super.key,
    required this.day,
    required this.volunteerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reports - $day'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Report'),
                onPressed: () {
                  _showCampReportForm(context, day, volunteerId);
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('camp_reports')
                  .where('volunteerId', isEqualTo: volunteerId)
                  .where('day', isEqualTo: day)
                  .where('createdAt', isNotEqualTo: null)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No data found.'));
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No reports submitted for this day.'),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, idx) {
                    final data = docs[idx].data() as Map<String, dynamic>;
                    final docId = docs[idx].id;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Colors.blue,
                        ),
                        title: Text(
                          'Time: ${data['fromTime']} - ${data['toTime']}',
                        ),
                        subtitle: Text(data['report'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              tooltip: 'Edit',
                              onPressed: () {
                                _showEditCampReportForm(
                                  context,
                                  docId,
                                  data,
                                  volunteerId,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Report'),
                                    content: const Text(
                                      'Are you sure you want to delete this report?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('camp_reports')
                                      .doc(docId)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Report deleted.'),
                                    ),
                                  );
                                }
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
          ),
        ],
      ),
    );
  }
}