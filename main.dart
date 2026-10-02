import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); // ربط وتشغيل السحابة عند بدء التطبيق
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const YallaTeacherApp());
}

class YallaTeacherApp extends StatefulWidget {
  const YallaTeacherApp({super.key});

  @override
  State<YallaTeacherApp> createState() => _YallaTeacherAppState();
}

class _YallaTeacherAppState extends State<YallaTeacherApp> {
  bool isDarkMode = false;

  // بيانات الآدمن الحقيقية التي يحددها بنفسه (تبدأ فارغة ليقوم بتسجيلها أول مرة)
  String adminEmail = '';
  String adminPassword = '';

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void updateAdminCredentials(String newEmail, String newPass) {
    setState(() {
      adminEmail = newEmail;
      adminPassword = newPass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'يلاتيتشر - YallaTeacher',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          primary: const Color(0xFF0D9488),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
      ),
      home: MainNavigationScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: toggleTheme,
        currentAdminEmail: adminEmail,
        currentAdminPassword: adminPassword,
        onCredentialsChanged: updateAdminCredentials,
      ),
    );
  }
}

// نموذج تعليق وتقييم الطالب
class ReviewData {
  final String studentName;
  final double rating;
  final String comment;
  final String date;

  ReviewData({
    required this.studentName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// نموذج بيانات الأستاذ
class TeacherData {
  final String id;
  final String name;
  final String subject;
  final String experience;
  String rating;
  final String phone;
  final String bio;
  final String address;
  final List<ReviewData> reviews;
  bool isFavorite;

  TeacherData({
    required this.id,
    required this.name,
    required this.subject,
    required this.experience,
    required this.rating,
    required this.phone,
    required this.bio,
    required this.address,
    required this.reviews,
    this.isFavorite = false,
  });
}

// ==========================================
// الشاشة الرئيسية مع شريط التنقل
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String currentAdminEmail;
  final String currentAdminPassword;
  final Function(String, String) onCredentialsChanged;

  const MainNavigationScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.currentAdminEmail,
    required this.currentAdminPassword,
    required this.onCredentialsChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  String selectedCity = 'دمشق';
  List<TeacherData> globalTeachers = [];
  bool isAdminLoggedIn = false;

  @override
  void initState() {
    super.initState();
    globalTeachers = [
      TeacherData(
        id: '1',
        name: 'أ. أحمد المحمود',
        subject: 'الرياضيات',
        experience: 'خبرة 10 سنوات',
        rating: '4.9 ★',
        phone: '0912345678',
        bio: 'أستاذ مادة الرياضيات للمرحلة الثانوية والبكالوريا، متخصص في تبسيط المفاهيم الصعبة وإعداد الطلاب للامتحانات النهائية بنجاح.',
        address: 'الميدان - دمشق',
        isFavorite: true,
        reviews: [
          ReviewData(
            studentName: 'سامر قادري',
            rating: 5.0,
            comment:
                'أستاذ ممتاز جداً شرحه واضح وساعدني كثيراً في فهم التحليل.',
            date: 'منذ يومين',
          ),
        ],
      ),
      TeacherData(
        id: '2',
        name: 'أ. سارة الحمصي',
        subject: 'الفيزياء والكيمياء',
        experience: 'خبرة 8 سنوات',
        rating: '4.8 ★',
        phone: '0987654321',
        bio: 'مدرّسة مادة العلوم الفيزيائية والكيميائية، خبرة واسعة في مناهج المدارس الخاصة والحكومية.',
        address: 'الشعلان - دمشق',
        reviews: [],
      ),
    ];
  }

  void _toggleFavorite(TeacherData teacher) {
    setState(() {
      teacher.isFavorite = !teacher.isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          teacher.isFavorite
              ? 'تمت إضافة ${teacher.name} إلى المفضلة ❤'
              : 'تمت إزالة ${teacher.name} من المفضلة',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addTeacher(TeacherData teacher) {
    setState(() {
      globalTeachers.insert(0, teacher);
    });
  }

  void _updateTeacher(TeacherData updatedTeacher) {
    setState(() {
      int index = globalTeachers.indexWhere((t) => t.id == updatedTeacher.id);
      if (index != -1) {
        globalTeachers[index] = updatedTeacher;
      }
    });
  }

  void _deleteTeacher(String id) {
    setState(() {
      globalTeachers.removeWhere((t) => t.id == id);
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'يلاتيتشر 🎓';
      case 1:
        return 'الأساتذة المفضلون ❤️';
      case 2:
        return isAdminLoggedIn ? 'لوحة تحكم الآدمن ⚙️' : 'دخول الآدمن 🔐';
      default:
        return 'يلاتيتشر 🎓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreenContent(
        selectedCity: selectedCity,
        onCityChanged: (newCity) {
          setState(() {
            selectedCity = newCity;
          });
        },
        teachers: globalTeachers,
        onToggleFavorite: _toggleFavorite,
      ),
      FavoritesScreen(
        teachers: globalTeachers.where((t) => t.isFavorite).toList(),
        cityName: selectedCity,
        onToggleFavorite: _toggleFavorite,
      ),
      isAdminLoggedIn
          ? AdminDashboardScreen(
              cityName: selectedCity,
              teachers: globalTeachers,
              onTeacherAdded: _addTeacher,
              onTeacherUpdated: _updateTeacher,
              onTeacherDeleted: _deleteTeacher,
              currentEmail: widget.currentAdminEmail,
              currentPassword: widget.currentAdminPassword,
              onCredentialsChanged: widget.onCredentialsChanged,
              onLogout: () {
                setState(() {
                  isAdminLoggedIn = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل خروج الآدمن بنجاح')),
                );
              },
            )
          : AdminLoginScreen(
              currentEmail: widget.currentAdminEmail,
              currentPassword: widget.currentAdminPassword,
              onLoginSuccess: (email, pass) {
                widget.onCredentialsChanged(email, pass);
                setState(() {
                  isAdminLoggedIn = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'أهلاً بك يا مدير النظام ($email)! تم تسجيل الدخول بنجاح 🔑',
                    ),
                    backgroundColor: const Color(0xFF0D9488),
                  ),
                );
              },
            ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF0D9488),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'تغيير المظهر',
              icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: widget.isDarkMode ? Colors.amber : Colors.white,
              ),
              onPressed: () {
                widget.onThemeChanged(!widget.isDarkMode);
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF0D9488)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.school,
                        size: 40,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'منصة يلاتيتشر 🎓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFF0D9488)),
                title: const Text('الرئيسية'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('الأساتذة المفضلون'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 1);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings,
                  color: Color(0xFF0D9488),
                ),
                title: Text(
                  isAdminLoggedIn ? 'لوحة تحكم الآدمن' : 'تسجيل دخول الآدمن',
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 2);
                },
              ),
              const Divider(),
              SwitchListTile(
                secondary: Icon(
                  widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF0D9488),
                ),
                title: const Text('الوضع الليلي (Dark Mode)'),
                value: widget.isDarkMode,
                onChanged: (val) {
                  widget.onThemeChanged(val);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('عن المنصة'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'يلاتيتشر (YallaTeacher)',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.school,
                      size: 40,
                      color: Color(0xFF0D9488),
                    ),
                    children: const [
                      Text(
                        'منصة تعليمية تربط بين الطلاب والأساتذة في مختلف المحافظات السورية لتحسين جودة التعليم الخصوصي.',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF0D9488),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'لوحة الإدارة',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// شاشة تسجيل دخول الآدمن بالإيميل وكلمة مرور شخصية (رقم الموبايل)
// ==========================================
class AdminLoginScreen extends StatefulWidget {
  final String currentEmail;
  final String currentPassword;
  final Function(String, String) onLoginSuccess;

  const AdminLoginScreen({
    super.key,
    required this.currentEmail,
    required this.currentPassword,
    required this.onLoginSuccess,
  });

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.currentEmail;
    _passController.text = widget.currentPassword;
  }

  void _verifyLogin() {
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال بريد إلكتروني صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء إدخال كلمة المرور (رقم الموبايل أو الرمز السري)',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.currentPassword.isEmpty) {
      widget.onLoginSuccess(email, pass);
    } else {
      if (email.toLowerCase() == widget.currentEmail.toLowerCase() &&
          pass == widget.currentPassword) {
        widget.onLoginSuccess(email, pass);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'البريد الإلكتروني أو كلمة المرور (رقم الموبايل) غير صحيحة!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF0D9488),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تسجيل دخول الآدمن الآمن 🔐',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'أدخل إيميلك الشخصي وكلمة المرور الخاصة بك (يمكنك جعلها رقم هاتفك الحقيقي).',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'إيميل جوجل الخاص بك (Gmail)',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF0D9488)),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: _obscureText,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور (رقم الموبايل أو الرمز السري)',
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF0D9488),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _verifyLogin(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _verifyLogin,
                      child: const Text(
                        'دخول لوحة التحكم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// لوحة تحكم الآدمن الكاملة مع إعدادات الحساب
// ==========================================
class AdminDashboardScreen extends StatelessWidget {
  final String cityName;
  final List<TeacherData> teachers;
  final Function(TeacherData) onTeacherAdded;
  final Function(TeacherData) onTeacherUpdated;
  final Function(String) onTeacherDeleted;
  final String currentEmail;
  final String currentPassword;
  final Function(String, String) onCredentialsChanged;
  final VoidCallback onLogout;

  const AdminDashboardScreen({
    super.key,
    required this.cityName,
    required this.teachers,
    required this.onTeacherAdded,
    required this.onTeacherUpdated,
    required this.onTeacherDeleted,
    required this.currentEmail,
    required this.currentPassword,
    required this.onCredentialsChanged,
    required this.onLogout,
  });

  void _showChangeCredentialsDialog(BuildContext context) {
    final emailController = TextEditingController(text: currentEmail);
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تعديل إعدادات الحساب ورقم الموبايل 🔐',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'الإيميل الشخصي',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: oldPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة (أو رقم الموبايل)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (oldPassController.text.trim() == currentPassword) {
                final newEmail = emailController.text.trim();
                final newPass = newPassController.text.trim().isEmpty
                    ? currentPassword
                    : newPassController.text.trim();

                if (newEmail.isNotEmpty && newPass.isNotEmpty) {
                  onCredentialsChanged(newEmail, newPass);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم تحديث بيانات الحساب وكلمة المرور بنجاح! 🔒',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء تعبئة الحقول المطلوبة'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور الحالية غير صحيحة'),
                  ),
                );
              }
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'لوحة التحكم الكاملة للآدمن ⚙️',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مسجل بـ: $currentEmail',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.manage_accounts,
                      color: Color(0xFF0D9488),
                    ),
                    tooltip: 'تغيير إيميل أو كلمة المرور',
                    onPressed: () => _showChangeCredentialsDialog(context),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('خروج'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrEditTeacherScreen(
                      cityName: cityName,
                      onSave: (newTeacher) {
                        onTeacherAdded(newTeacher);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تمت إضافة الأستاذ بنجاح للقائمة العامة! ✅',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text(
                'إضافة أستاذ جديد للقائمة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'قائمة الأساتذة المسجلين (${teachers.length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: teachers.isEmpty
                ? const Center(child: Text('لا يوجد أساتذة مضافين حالياً'))
                : ListView.builder(
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF0D9488),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            teacher.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'مادة ${teacher.subject} • ${teacher.experience}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'تعديل البيانات',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddOrEditTeacherScreen(
                                            cityName: cityName,
                                            existingTeacher: teacher,
                                            onSave: (updatedTeacher) {
                                              onTeacherUpdated(updatedTeacher);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'تم تعديل بيانات الأستاذ بنجاح! ✏️',
                                                      ),
                                                    ),
                                                  );
                                            },
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'حذف الأستاذ',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('تأكيد الحذف'),
                                      content: Text(
                                        'هل أنت متأكد من حذف ${teacher.name} نهائياً من المنصة؟',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('إلغاء'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            onTeacherDeleted(teacher.id);
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'تم حذف الأستاذ بنجاح',
                                                    ),
                                                  ),
                                                );
                                          },
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// شاشة إضافة أو تعديل أستاذ (للآدمن فقط)
// ==========================================
class AddOrEditTeacherScreen extends StatefulWidget {
  final String cityName;
  final TeacherData? existingTeacher;
  final Function(TeacherData) onSave;

  const AddOrEditTeacherScreen({
    super.key,
    required this.cityName,
    this.existingTeacher,
    required this.onSave,
  });

  @override
  State<AddOrEditTeacherScreen> createState() => _AddOrEditTeacherScreenState();
}

class _AddOrEditTeacherScreenState extends State<AddOrEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _experienceController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;

  String _selectedSubject = 'الرياضيات';

  final List<String> _subjects = [
    'الرياضيات',
    'الفيزياء والكيمياء',
    'اللغة العربية',
    'اللغة الإنكليزية',
    'الفلسفة',
    'الجغرافيا',
    'التاريخ',
    'التربية الدينية',
    'العلوم العامة',
    'الفرنسية',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTeacher?.name ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.existingTeacher?.experience ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.existingTeacher?.phone ?? '',
    );
    _addressController = TextEditingController(
      text: widget.existingTeacher?.address ?? '',
    );
    _bioController = TextEditingController(
      text: widget.existingTeacher?.bio ?? '',
    );

    if (widget.existingTeacher != null &&
        _subjects.contains(widget.existingTeacher!.subject)) {
      _selectedSubject = widget.existingTeacher!.subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTeacher != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل بيانات الأستاذ ✏️' : 'إضافة أستاذ جديد 📝',
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'تعديل بيانات المعلم:'
                      : 'أدخل بيانات المعلم ليتم نشره في المنصة:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF0D9488)),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال الاسم'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'المادة المدرسية',
                    prefixIcon: Icon(Icons.book, color: Color(0xFF0D9488)),
                    border: OutlineInputBorder(),
                  ),
                  items: _subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedSubject = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    labelText: 'سنوات الخبرة (مثال: خبرة 5 سنوات)',
                    prefixIcon: Icon(Icons.timeline, color: Color(0xFF0D9488)),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال الخبرة'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف / واتساب',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF0D9488)),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال رقم الهاتف'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان والمنطقة',
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: Color(0xFF0D9488),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال العنوان'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'نبذة عن الأستاذ والطريقة التدريسية',
                    prefixIcon: Icon(
                      Icons.description,
                      color: Color(0xFF0D9488),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'الرجاء إدخال النبذة'
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final teacher = TeacherData(
                          id:
                              widget.existingTeacher?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameController.text.trim(),
                          subject: _selectedSubject,
                          experience: _experienceController.text.trim(),
                          rating: widget.existingTeacher?.rating ?? 'جديد 🆕',
                          phone: _phoneController.text.trim(),
                          bio: _bioController.text.trim(),
                          address: _addressController.text.trim(),
                          reviews: widget.existingTeacher?.reviews ?? [],
                          isFavorite:
                              widget.existingTeacher?.isFavorite ?? false,
                        );
                        widget.onSave(teacher);
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      isEditing ? 'حفظ التعديلات' : 'إضافة ونشر',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// الشاشات العامة للطلاب (الرئيسية، المفضلة، القائمة)
// ==========================================
class HomeScreenContent extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCityChanged;
  final List<TeacherData> teachers;
  final Function(TeacherData) onToggleFavorite;

  const HomeScreenContent({
    super.key,
    required this.selectedCity,
    required this.onCityChanged,
    required this.teachers,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> cities = [
      'دمشق',
      'ريف دمشق',
      'حلب',
      'حمص',
      'حماة',
      'اللاذقية',
      'طرطوس',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FFFA).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF0F766E)),
                    SizedBox(width: 8),
                    Text(
                      'اختر المحافظة:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: selectedCity,
                  underline: const SizedBox(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF0F766E),
                  ),
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(
                        city,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onCityChanged(newValue);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'المراحل الدراسية:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildCategoryItem(
                  context,
                  title: 'المرحلة الثانوية (البكالوريا)',
                  subtitle: 'علمي • أدبي • مهني',
                  icon: Icons.school,
                  iconColor: Colors.amber,
                ),
                _buildCategoryItem(
                  context,
                  title: 'المرحلة الإعدادية (تاسع)',
                  subtitle: 'الصف السابع • الثامن • التاسع',
                  icon: Icons.menu_book,
                  iconColor: Colors.blue,
                ),
                _buildCategoryItem(
                  context,
                  title: 'التعليم الأساسي (الابتدائي)',
                  subtitle: 'من الصف الأول إلى السادس',
                  icon: Icons.child_care,
                  iconColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          radius: 25,
          child: Icon(icon, color: iconColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeachersListScreen(
                categoryTitle: title,
                cityName: selectedCity,
                teachers: teachers,
                onToggleFavorite: onToggleFavorite,
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<TeacherData> teachers;
  final String cityName;
  final Function(TeacherData) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.teachers,
    required this.cityName,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: teachers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite_border, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا يوجد أساتذة في المفضلة بعد',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اضغط على زر القلب بجانب أي أستاذ لحفظه هنا',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                return TeacherCard(
                  teacher: teacher,
                  cityName: cityName,
                  onToggleFavorite: () => onToggleFavorite(teacher),
                );
              },
            ),
    );
  }
}

class TeachersListScreen extends StatefulWidget {
  final String categoryTitle;
  final String cityName;
  final List<TeacherData> teachers;
  final Function(TeacherData) onToggleFavorite;

  const TeachersListScreen({
    super.key,
    required this.categoryTitle,
    required this.cityName,
    required this.teachers,
    required this.onToggleFavorite,
  });

  @override
  State<TeachersListScreen> createState() => _TeachersListScreenState();
}

class _TeachersListScreenState extends State<TeachersListScreen> {
  List<TeacherData> filteredTeachers = [];
  String searchQuery = '';
  String selectedFilterSubject = 'الكل';

  @override
  void initState() {
    super.initState();
    filteredTeachers = List.from(widget.teachers);
  }

  void _filterTeachers() {
    setState(() {
      filteredTeachers = widget.teachers.where((teacher) {
        final matchesQuery =
            teacher.name.contains(searchQuery) ||
            teacher.subject.contains(searchQuery);
        final matchesSubject =
            selectedFilterSubject == 'الكل' ||
            teacher.subject == selectedFilterSubject;
        return matchesQuery && matchesSubject;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> filterSubjects = [
      'الكل',
      'الرياضيات',
      'الفيزياء والكيمياء',
      'اللغة العربية',
      'اللغة الإنكليزية',
      'الفلسفة',
      'الجغرافيا',
      'التاريخ',
      'التربية الدينية',
      'العلوم العامة',
      'الفرنسية',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) {
                  searchQuery = value;
                  _filterTeachers();
                },
                decoration: InputDecoration(
                  hintText: 'ابحث باسم الأستاذ أو المادة...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF0D9488),
                  ),
                  filled: true,
                  fillColor: Colors.teal.shade50.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = filterSubjects[index];
                    final isSelected = selectedFilterSubject == subject;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          subject,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0F766E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0D9488),
                        backgroundColor: const Color(0xFFE6FFFA)
                            .withOpacity(0.4),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedFilterSubject = subject;
                              _filterTeachers();
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'أساتذة ${widget.categoryTitle} في ${widget.cityName} (${filteredTeachers.length}):',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredTeachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'لا يوجد أساتذة يطابقون خيارات البحث',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = filteredTeachers[index];
                          return TeacherCard(
                            teacher: teacher,
                            cityName: widget.cityName,
                            onToggleFavorite: () {
                              widget.onToggleFavorite(teacher);
                              setState(() {});
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final TeacherData teacher;
  final String cityName;
  final VoidCallback onToggleFavorite;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.cityName,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TeacherProfileScreen(teacher: teacher, cityName: cityName),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFF0D9488),
                child: Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'مادة ${teacher.subject}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      teacher.experience,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      teacher.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: teacher.isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: onToggleFavorite,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          teacher.rating,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(50, 28),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherProfileScreen(
                                teacher: teacher,
                                cityName: cityName,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'الملف',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherProfileScreen extends StatefulWidget {
  final TeacherData teacher;
  final String cityName;

  const TeacherProfileScreen({
    super.key,
    required this.teacher,
    required this.cityName,
  });

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  void _showAddReviewDialog() {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text(
                'إضافة تقييم للأستاذ ⭐️',
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسمك (الطالب/الولي)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'التقييم:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starRating = index + 1;
                          return IconButton(
                            icon: Icon(
                              starRating <= selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                            onPressed: () {
                              setModalState(() {
                                selectedRating = starRating.toDouble();
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: commentController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'رأيك وتجربتك مع الأستاذ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty &&
                        commentController.text.trim().isNotEmpty) {
                      final newReview = ReviewData(
                        studentName: nameController.text.trim(),
                        rating: selectedRating,
                        comment: commentController.text.trim(),
                        date: 'الآن',
                      );

                      setState(() {
                        widget.teacher.reviews.insert(0, newReview);
                        double total = 0;
                        for (var r in widget.teacher.reviews) {
                          total += r.rating;
                        }
                        double avg = total / widget.teacher.reviews.length;
                        widget.teacher.rating = '${avg.toStringAsFixed(1)} ★';
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('شكراً لك! تم إضافة تقييمك بنجاح. 🎉'),
                          backgroundColor: Color(0xFF0D9488),
                        ),
                      );
                    }
                  },
                  child: const Text('إرسال التقييم'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي للأستاذ'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFF0D9488),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.teacher.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مادة ${widget.teacher.subject}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(
                            Icons.star,
                            widget.teacher.rating,
                            Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            Icons.history_edu,
                            widget.teacher.experience,
                            const Color(0xFF0D9488),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            Icons.location_on,
                            widget.cityName,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'عن الأستاذ:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.teacher.bio,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'العنوان والمنطقة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.map, color: Color(0xFF0D9488)),
                title: Text(widget.teacher.address),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'جاري الاتصال بـ ${widget.teacher.phone}...',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text(
                        'اتصال هاتف',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'جاري فتح واتساب مع ${widget.teacher.phone}...',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text(
                        'واتساب',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تقييمات وآراء الطلاب (${widget.teacher.reviews.length}):',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAddReviewDialog,
                    icon: const Icon(
                      Icons.rate_review,
                      color: Color(0xFF0D9488),
                    ),
                    label: const Text(
                      'إضافة تقييم',
                      style: TextStyle(
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.teacher.reviews.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300.withOpacity(0.3),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'لا توجد تقييمات بعد. كن أول من يقيّم هذا الأستاذ!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.teacher.reviews.length,
                  itemBuilder: (context, index) {
                    final review = widget.teacher.reviews[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.account_circle,
                                      color: Color(0xFF0D9488),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      review.studentName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${review.rating}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              review.comment,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                review.date,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
