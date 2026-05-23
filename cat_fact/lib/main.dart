import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qbfxeedidjcgjevoygne.supabase.co',
    anonKey: 'sb_publishable_uLOYb3tRHlPhfs7kzQrOww_DhfBXGqt',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

const catFactBaseUrl = 'https://catfact.ninja';
const factCategories = ['可愛', '健康', '行為', '冷知識'];
const catAiFunctionUrl =
    'https://qbfxeedidjcgjevoygne.supabase.co/functions/v1/cat-ai';

const catLottieAsset = 'assets/lottie/cat.json';
const catWalkingLottieAsset = 'assets/lottie/cat_walking.json';
const catTypingLottieAsset = 'assets/lottie/cat_typing.json';
const catEmptyLottieAsset = 'assets/lottie/cat_empty.json';
const heartLottieAsset = 'assets/lottie/heart.json';

Widget buildLottieAsset(
  String asset, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  bool repeat = true,
  Widget? fallback,
}) {
  return Lottie.asset(
    asset,
    width: width,
    height: height,
    fit: fit,
    repeat: repeat,
    errorBuilder: (context, error, stackTrace) {
      return fallback ??
          Icon(
            Icons.pets,
            size: width == null ? 72 : width * 0.48,
            color: Colors.orangeAccent,
          );
    },
  );
}

class CatFact {
  const CatFact({
    required this.id,
    required this.text,
    required this.source,
    this.category = '冷知識',
  });

  final String id;
  final String text;
  final String source;
  final String category;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat Facts Keeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入 Email 和 Password')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.signInWithPassword(email: email, password: password);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('登入失敗：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 28),
              Center(
                child: buildLottieAsset(
                  catLottieAsset,
                  width: 150,
                  height: 150,
                  fallback: const Icon(
                    Icons.pets,
                    size: 72,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cat Facts Keeper',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '登入後收藏你喜歡的貓咪冷知識。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shadowColor: Colors.orange.withAlpha(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: isLoading ? null : login,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('登入'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text('忘記密碼？'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade800,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text('註冊新帳號'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetPasswordEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入 Email')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.resetPasswordForEmail(email);

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('重設密碼信已寄出，請到信箱查看')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('寄送失敗：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('忘記密碼')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Icon(
                Icons.lock_reset_outlined,
                size: 72,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                '重設你的密碼',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '輸入註冊時使用的 Email，系統會寄出重設密碼連結。',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: isLoading ? null : sendResetPasswordEmail,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('寄出重設密碼信'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請完整填寫註冊資料')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('兩次密碼輸入不一致')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.signUp(email: email, password: password);
      await supabase.auth.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('註冊成功，請回登入頁登入')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('註冊失敗：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('註冊新帳號')),
      backgroundColor: Colors.orange.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                '建立你的喵知識帳號',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '之後每個帳號都會有自己的 Cat Facts 收藏清單。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shadowColor: Colors.orange.withAlpha(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_reset_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: isLoading ? null : register,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('建立帳號'),
                        ),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final pages = const [
    DiscoverPage(),
    FavoriteFactsPage(),
    CatAiPage(),
    AddFactPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            buildLottieAsset(
              catWalkingLottieAsset,
              width: 52,
              height: 52,
              fallback: const Icon(Icons.pets, color: Colors.orangeAccent),
            ),
            const SizedBox(width: 8),
            const Text('Cat Facts Keeper'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthGate()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: '探索',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI喵博士',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: '新增冷知識',
          ),
        ],
      ),
    );
  }
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool isLoadingDaily = false;
  bool isLoadingRandom = false;
  bool isLoadingList = false;
  CatFact? dailyFact;
  CatFact? randomFact;
  List<CatFact> factList = [];
  final Map<String, String> translatedFacts = {};
  final Set<String> translatingFactIds = {};
  final Set<String> favoriteApiFactIds = {};
  final Map<String, String> favoriteApiFactCategories = {};
  final Set<String> savingFavoriteFactIds = {};
  final List<String> categories = [...factCategories];

  @override
  void initState() {
    super.initState();
    loadFavoriteApiFactIds();
    loadDailyFact();
    loadRandomList();
  }

  String getDailyFactKey() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return 'daily-$year-$month-$day';
  }

  CatFact parseApiFact(dynamic value) {
    final data = value as Map<String, dynamic>;
    final text =
        data['fact']?.toString() ?? data['text']?.toString() ?? 'No fact text';

    return CatFact(id: text.hashCode.toString(), text: text, source: 'api');
  }

  Future<CatFact> fetchRandomFact() async {
    final uri = Uri.parse('$catFactBaseUrl/fact');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Cat Facts API 回傳狀態碼 ${response.statusCode}');
    }

    return parseApiFact(jsonDecode(response.body));
  }

  Future<List<CatFact>> fetchRandomFacts({int amount = 8}) async {
    final facts = <CatFact>[];
    final usedTexts = <String>{};

    for (var i = 0; i < amount; i++) {
      final fact = await fetchRandomFact();
      if (usedTexts.add(fact.text)) {
        facts.add(fact);
      }
    }

    return facts;
  }

  Future<void> loadFavoriteApiFactIds() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('cat_fact_favorites')
          .select('category, cat_facts(api_fact_id)')
          .eq('user_id', user.id);

      final ids = <String>{};
      final categoryMap = <String, String>{};
      for (final item in data) {
        final fact = item['cat_facts'];
        if (fact is Map<String, dynamic>) {
          final apiFactId = fact['api_fact_id']?.toString();
          final category = item['category']?.toString() ?? '冷知識';
          if (apiFactId != null && apiFactId.isNotEmpty) {
            ids.add(apiFactId);
            categoryMap[apiFactId] = category;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        favoriteApiFactIds
          ..clear()
          ..addAll(ids);
        favoriteApiFactCategories
          ..clear()
          ..addAll(categoryMap);
      });
    } catch (_) {
      // 收藏狀態讀取失敗時不影響主畫面。
    }
  }

  Future<void> loadDailyFact() async {
    setState(() {
      isLoadingDaily = true;
    });

    try {
      final dailyKey = getDailyFactKey();

      final existingFacts = await supabase
          .from('cat_facts')
          .select('api_fact_id, text, source, category')
          .eq('api_fact_id', dailyKey)
          .limit(1);

      if (existingFacts.isNotEmpty) {
        final data = existingFacts.first;
        if (!mounted) return;
        setState(() {
          dailyFact = CatFact(
            id: data['api_fact_id']?.toString() ?? dailyKey,
            text: data['text']?.toString() ?? 'No fact text',
            source: data['source']?.toString() ?? 'daily',
            category: data['category']?.toString() ?? '冷知識',
          );
          isLoadingDaily = false;
        });
        return;
      }

      final fetchedFact = await fetchRandomFact();
      final insertedFact = await supabase
          .from('cat_facts')
          .upsert({
            'api_fact_id': dailyKey,
            'text': fetchedFact.text,
            'source': 'daily',
            'category': '冷知識',
          }, onConflict: 'api_fact_id')
          .select('api_fact_id, text, source, category')
          .single();

      if (!mounted) return;
      setState(() {
        dailyFact = CatFact(
          id: insertedFact['api_fact_id']?.toString() ?? dailyKey,
          text: insertedFact['text']?.toString() ?? fetchedFact.text,
          source: insertedFact['source']?.toString() ?? 'daily',
          category: insertedFact['category']?.toString() ?? '冷知識',
        );
        isLoadingDaily = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingDaily = false;
      });
      showMessage('每日 Cat Fact 讀取失敗：$e');
    }
  }

  Future<void> loadRandomFact() async {
    setState(() {
      isLoadingRandom = true;
    });

    try {
      final fact = await fetchRandomFact();
      if (!mounted) return;
      setState(() {
        randomFact = fact;
        isLoadingRandom = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingRandom = false;
      });
      showMessage('隨機 Cat Fact 讀取失敗：$e');
    }
  }

  Future<void> loadRandomList() async {
    setState(() {
      isLoadingList = true;
    });

    try {
      final facts = await fetchRandomFacts(amount: 8);
      if (!mounted) return;
      setState(() {
        factList = facts;
        isLoadingList = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingList = false;
      });
      showMessage('Fact 列表讀取失敗：$e');
    }
  }

  Future<void> copyFact(CatFact fact) async {
    await Clipboard.setData(ClipboardData(text: fact.text));
    showMessage('已複製，可貼到訊息或社群分享');
  }

  Future<void> translateFact(CatFact fact) async {
    if (translatedFacts.containsKey(fact.id)) {
      return;
    }

    setState(() {
      translatingFactIds.add(fact.id);
    });

    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;

      final response = await http.post(
        Uri.parse(catAiFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': '請只把以下英文貓咪冷知識翻譯成自然的繁體中文，不要加入額外說明：${fact.text}',
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(data['error']?.toString() ?? '翻譯失敗');
      }

      if (!mounted) return;
      setState(() {
        translatedFacts[fact.id] = data['answer']?.toString() ?? '翻譯失敗';
        translatingFactIds.remove(fact.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        translatingFactIds.remove(fact.id);
      });
      showMessage('翻譯失敗：$e');
    }
  }

  Future<void> saveFavorite(CatFact fact, String category) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      showMessage('請先登入');
      return;
    }

    if (savingFavoriteFactIds.contains(fact.id)) return;

    setState(() {
      savingFavoriteFactIds.add(fact.id);
    });

    try {
      final savedFact = await supabase
          .from('cat_facts')
          .upsert({
            'api_fact_id': fact.id,
            'text': fact.text,
            'source': fact.source,
            'category': category,
          }, onConflict: 'api_fact_id')
          .select()
          .single();

      await supabase.from('cat_fact_favorites').upsert({
        'user_id': user.id,
        'fact_id': savedFact['id'],
        'category': category,
      }, onConflict: 'user_id,fact_id');

      if (!mounted) return;
      setState(() {
        favoriteApiFactIds.add(fact.id);
        favoriteApiFactCategories[fact.id] = category;
        savingFavoriteFactIds.remove(fact.id);
      });
      await showFavoriteSuccessAnimation(category);
    } catch (e) {
      if (mounted) {
        setState(() {
          savingFavoriteFactIds.remove(fact.id);
        });
      }
      showMessage('加入收藏失敗：$e');
    }
  }

  Future<void> removeFavoriteByFact(CatFact fact) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      showMessage('請先登入');
      return;
    }

    if (savingFavoriteFactIds.contains(fact.id)) return;

    setState(() {
      savingFavoriteFactIds.add(fact.id);
    });

    try {
      final savedFacts = await supabase
          .from('cat_facts')
          .select('id')
          .eq('api_fact_id', fact.id)
          .limit(1);

      if (savedFacts.isEmpty) {
        if (!mounted) return;
        setState(() {
          favoriteApiFactIds.remove(fact.id);
          favoriteApiFactCategories.remove(fact.id);
          savingFavoriteFactIds.remove(fact.id);
        });
        showMessage('已取消收藏');
        return;
      }

      final factId = savedFacts.first['id'];

      await supabase
          .from('cat_fact_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('fact_id', factId);

      if (!mounted) return;
      setState(() {
        favoriteApiFactIds.remove(fact.id);
        favoriteApiFactCategories.remove(fact.id);
        savingFavoriteFactIds.remove(fact.id);
      });
      showMessage('已取消收藏');
    } catch (e) {
      if (mounted) {
        setState(() {
          savingFavoriteFactIds.remove(fact.id);
        });
      }
      showMessage('取消收藏失敗：$e');
    }
  }

  Future<void> toggleFavorite(CatFact fact) async {
    if (favoriteApiFactIds.contains(fact.id)) {
      await removeFavoriteByFact(fact);
      return;
    }

    await openCategoryPicker(fact);
  }

  Future<String?> showAddCategoryDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增分類'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '分類名稱',
              hintText: '例如：飲食、睡眠、品種',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(context, text);
              },
              child: const Text('新增'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> openCategoryPicker(CatFact fact) async {
    if (savingFavoriteFactIds.contains(fact.id)) return;
    final category = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('選擇收藏分類')),
              for (final category in categories)
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: Text(category),
                  onTap: () => Navigator.pop(context, category),
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('新增分類'),
                onTap: () => Navigator.pop(context, '__add_category__'),
              ),
            ],
          ),
        );
      },
    );

    if (category == null) return;

    if (category == '__add_category__') {
      final newCategory = await showAddCategoryDialog();
      if (newCategory == null || newCategory.isEmpty) return;

      if (!categories.contains(newCategory)) {
        setState(() {
          categories.add(newCategory);
        });
      }

      await saveFavorite(fact, newCategory);
      return;
    }

    await saveFavorite(fact, category);
  }

  Widget buildCatLoading(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLottieAsset(
              catTypingLottieAsset,
              width: 120,
              height: 120,
              fallback: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showFavoriteSuccessAnimation(String category) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 1300), () {
          if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
            Navigator.pop(dialogContext);
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildLottieAsset(
                  heartLottieAsset,
                  width: 150,
                  height: 150,
                  repeat: false,
                  fallback: const Icon(
                    Icons.favorite,
                    size: 86,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '已加入 $category 收藏',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await loadRandomList();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: '每日一則 Cat Fact'),
          if (isLoadingDaily)
            buildCatLoading('每日冷知識讀取中...')
          else if (dailyFact != null)
            CatFactCard(
              fact: dailyFact!,
              subtitle: '今天的貓咪冷知識',
              translatedText: translatedFacts[dailyFact!.id],
              isTranslating: translatingFactIds.contains(dailyFact!.id),
              isFavorite: favoriteApiFactIds.contains(dailyFact!.id),
              favoriteCategory: favoriteApiFactCategories[dailyFact!.id],
              isSavingFavorite: savingFavoriteFactIds.contains(dailyFact!.id),
              onCopy: () => copyFact(dailyFact!),
              onFavorite: () => toggleFavorite(dailyFact!),
              onTranslate: () => translateFact(dailyFact!),
            ),
          const SizedBox(height: 24),
          const SectionTitle(title: '隨機抽一則'),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: isLoadingRandom ? null : loadRandomFact,
              icon: isLoadingRandom
                  ? const Icon(Icons.pets)
                  : const Icon(Icons.casino_outlined),
              label: Text(isLoadingRandom ? '抽取中...' : '抽一則 Cat Fact'),
            ),
          ),
          if (isLoadingRandom) buildCatLoading('隨機冷知識抽取中...'),
          if (randomFact != null) ...[
            const SizedBox(height: 12),
            CatFactCard(
              fact: randomFact!,
              subtitle: '隨機抽到的 fact',
              translatedText: translatedFacts[randomFact!.id],
              isTranslating: translatingFactIds.contains(randomFact!.id),
              isFavorite: favoriteApiFactIds.contains(randomFact!.id),
              favoriteCategory: favoriteApiFactCategories[randomFact!.id],
              isSavingFavorite: savingFavoriteFactIds.contains(randomFact!.id),
              onCopy: () => copyFact(randomFact!),
              onFavorite: () => toggleFavorite(randomFact!),
              onTranslate: () => translateFact(randomFact!),
            ),
          ],
          const SizedBox(height: 24),
          SectionTitle(
            title: '更多冷知識',
            trailing: TextButton.icon(
              onPressed: isLoadingList ? null : loadRandomList,
              icon: isLoadingList
                  ? const Icon(Icons.pets)
                  : const Icon(Icons.refresh),
              label: Text(isLoadingList ? '更新中...' : '換一批'),
            ),
          ),
          if (isLoadingList && factList.isEmpty) buildCatLoading('更多冷知識更新中...'),
          for (final fact in factList)
            CatFactCard(
              fact: fact,
              subtitle: 'Cat Facts API',
              translatedText: translatedFacts[fact.id],
              isTranslating: translatingFactIds.contains(fact.id),
              isFavorite: favoriteApiFactIds.contains(fact.id),
              favoriteCategory: favoriteApiFactCategories[fact.id],
              isSavingFavorite: savingFavoriteFactIds.contains(fact.id),
              onCopy: () => copyFact(fact),
              onFavorite: () => toggleFavorite(fact),
              onTranslate: () => translateFact(fact),
            ),
        ],
      ),
    );
  }
}

class FavoriteFactsPage extends StatefulWidget {
  const FavoriteFactsPage({super.key});

  @override
  State<FavoriteFactsPage> createState() => _FavoriteFactsPageState();
}

class _FavoriteFactsPageState extends State<FavoriteFactsPage> {
  String selectedCategory = '全部';
  List<String> availableCategories = ['全部', ...factCategories];
  final Map<String, String> translatedFavorites = {};
  final Set<String> translatingFavoriteIds = {};

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    var query = supabase
        .from('cat_fact_favorites')
        .select('id, category, created_at, cat_facts(*)')
        .eq('user_id', user.id);

    if (selectedCategory != '全部') {
      query = query.eq('category', selectedCategory);
    }

    final data = await query.order('created_at', ascending: false);
    final favorites = List<Map<String, dynamic>>.from(data);

    final categorySet = <String>{'全部', ...factCategories};
    for (final item in favorites) {
      final category = item['category']?.toString();
      if (category != null && category.isNotEmpty) {
        categorySet.add(category);
      }
    }

    availableCategories = categorySet.toList();
    return favorites;
  }

  Future<void> removeFavorite(String favoriteId) async {
    await supabase.from('cat_fact_favorites').delete().eq('id', favoriteId);
    setState(() {});
  }

  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已複製，可貼到訊息或社群分享')));
  }

  Future<void> editOwnFact(Map<String, dynamic> favorite) async {
    final fact = favorite['cat_facts'] as Map<String, dynamic>;
    final factId = fact['id']?.toString();
    final textController = TextEditingController(
      text: fact['text']?.toString() ?? '',
    );
    var selectedEditCategory = favorite['category']?.toString() ?? '冷知識';
    final editCategories = <String>{
      ...availableCategories,
      selectedEditCategory,
    }.where((item) => item != '全部' && item.isNotEmpty).toList();

    if (factId == null || factId.isEmpty) {
      textController.dispose();
      return;
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('編輯我的冷知識'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Cat Fact 內容',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedEditCategory,
                    decoration: const InputDecoration(
                      labelText: '分類',
                      border: OutlineInputBorder(),
                    ),
                    items: editCategories
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedEditCategory = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    Navigator.pop(context, {
                      'text': text,
                      'category': selectedEditCategory,
                    });
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          },
        );
      },
    );

    textController.dispose();

    if (result == null) return;

    try {
      await supabase
          .from('cat_facts')
          .update({'text': result['text'], 'category': result['category']})
          .eq('id', factId);

      await supabase
          .from('cat_fact_favorites')
          .update({'category': result['category']})
          .eq('id', favorite['id']);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已更新投稿')));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新失敗：$e')));
    }
  }

  Future<void> deleteOwnFact(Map<String, dynamic> favorite) async {
    final fact = favorite['cat_facts'] as Map<String, dynamic>;
    final factId = fact['id']?.toString();
    final text = fact['text']?.toString() ?? '';

    if (factId == null || factId.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('刪除我的冷知識'),
          content: Text('確定要永久刪除這則冷知識嗎？\n\n$text'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('刪除'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await supabase
          .from('cat_fact_favorites')
          .delete()
          .eq('id', favorite['id']);
      await supabase.from('cat_facts').delete().eq('id', factId);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已刪除我的冷知識')));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('刪除失敗：$e')));
    }
  }

  Future<void> translateFavorite(String favoriteId, String text) async {
    if (translatedFavorites.containsKey(favoriteId)) {
      return;
    }

    setState(() {
      translatingFavoriteIds.add(favoriteId);
    });

    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;

      final response = await http.post(
        Uri.parse(catAiFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': '請只把以下英文貓咪冷知識翻譯成自然的繁體中文，不要加入額外說明：$text'}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(data['error']?.toString() ?? '翻譯失敗');
      }

      if (!mounted) return;
      setState(() {
        translatedFavorites[favoriteId] = data['answer']?.toString() ?? '翻譯失敗';
        translatingFavoriteIds.remove(favoriteId);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        translatingFavoriteIds.remove(favoriteId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('翻譯失敗：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = availableCategories;

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: categories.length,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchFavorites(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('讀取收藏失敗：${snapshot.error}'),
                  ),
                );
              }

              final favorites = snapshot.data ?? [];
              if (favorites.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildLottieAsset(
                          catEmptyLottieAsset,
                          width: 180,
                          height: 180,
                          fallback: Icon(
                            Icons.favorite_border,
                            size: 84,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '目前還沒有收藏 Cat Fact',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '到探索頁面把喜歡的貓咪冷知識加入收藏吧。',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    final favoriteId = favorite['id'].toString();
                    final fact = favorite['cat_facts'] as Map<String, dynamic>;
                    final text = fact['text']?.toString() ?? 'No fact text';
                    final category = favorite['category']?.toString() ?? '冷知識';
                    final source = fact['source']?.toString();
                    final createdBy = fact['created_by']?.toString();
                    final currentUserId = supabase.auth.currentUser?.id;
                    final canEditOwnFact =
                        source == 'user' && createdBy == currentUserId;
                    final translatedText = translatedFavorites[favoriteId];
                    final isTranslating = translatingFavoriteIds.contains(
                      favoriteId,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Chip(label: Text(category)),
                                const Spacer(),
                                if (canEditOwnFact)
                                  IconButton(
                                    onPressed: () => editOwnFact(favorite),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                if (canEditOwnFact)
                                  IconButton(
                                    onPressed: () => deleteOwnFact(favorite),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                IconButton(
                                  onPressed: () => copyText(text),
                                  icon: const Icon(Icons.copy_outlined),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      removeFavorite(favorite['id']),
                                  icon: const Icon(Icons.favorite),
                                  color: Colors.redAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              text,
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: isTranslating
                                  ? null
                                  : () => translateFavorite(favoriteId, text),
                              icon: isTranslating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.translate),
                              label: Text(
                                translatedText == null
                                    ? isTranslating
                                          ? '翻譯中...'
                                          : '翻譯成繁體中文'
                                    : '已翻譯',
                              ),
                            ),
                            if (translatedText != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  translatedText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// AI 喵博士頁面
class CatAiPage extends StatefulWidget {
  const CatAiPage({super.key});

  @override
  State<CatAiPage> createState() => _CatAiPageState();
}

class _CatAiPageState extends State<CatAiPage> {
  final questionController = TextEditingController();
  String answer = '';
  bool isLoading = false;

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  Future<void> askCatAi() async {
    final question = questionController.text.trim();

    if (question.isEmpty) {
      showMessage('請先輸入你想問喵博士的問題');
      return;
    }

    setState(() {
      isLoading = true;
      answer = '';
    });

    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;

      final response = await http.post(
        Uri.parse(catAiFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': question}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(data['error']?.toString() ?? 'AI 回覆失敗');
      }

      setState(() {
        answer = data['answer']?.toString() ?? '喵博士暫時沒有回答。';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showMessage('AI 喵博士失敗：$e');
    }
  }

  Future<void> copyAnswer() async {
    if (answer.isEmpty) {
      showMessage('目前沒有可以複製的回答');
      return;
    }

    await Clipboard.setData(ClipboardData(text: answer));
    showMessage('已複製喵博士回答');
  }

  Future<void> saveAnswer() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      showMessage('請先登入');
      return;
    }

    if (answer.isEmpty) {
      showMessage('目前沒有可以收藏的回答');
      return;
    }

    try {
      final savedFact = await supabase
          .from('cat_facts')
          .insert({
            'api_fact_id':
                'ai-${user.id}-${DateTime.now().millisecondsSinceEpoch}',
            'text': answer,
            'source': 'ai',
            'category': '冷知識',
            'created_by': user.id,
          })
          .select()
          .single();

      await supabase.from('cat_fact_favorites').insert({
        'user_id': user.id,
        'fact_id': savedFact['id'],
        'category': '冷知識',
      });

      showMessage('已收藏喵博士回答');
    } catch (e) {
      showMessage('收藏失敗：$e');
    }
  }

  Widget buildCatAiLoading() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildLottieAsset(
              catTypingLottieAsset,
              width: 160,
              height: 160,
              fallback: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            const Text(
              '喵博士正在思考中...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: buildLottieAsset(
            catLottieAsset,
            width: 140,
            height: 140,
            fallback: const Icon(
              Icons.smart_toy,
              size: 72,
              color: Colors.orangeAccent,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'AI 喵博士',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '問喵博士任何貓咪問題',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: questionController,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: '想問什麼？',
            hintText: '例如：貓為什麼喜歡紙箱？',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: isLoading ? null : askCatAi,
            icon: isLoading ? const Icon(Icons.pets) : const Icon(Icons.send),
            label: Text(isLoading ? '喵博士思考中...' : '問喵博士'),
          ),
        ),
        if (isLoading) ...[const SizedBox(height: 24), buildCatAiLoading()],
        if (answer.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets, color: Colors.orangeAccent),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '喵博士回答',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: copyAnswer,
                        icon: const Icon(Icons.copy_outlined),
                      ),
                      IconButton(
                        onPressed: saveAnswer,
                        icon: const Icon(Icons.favorite),
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    answer,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class AddFactPage extends StatefulWidget {
  const AddFactPage({super.key});

  @override
  State<AddFactPage> createState() => _AddFactPageState();
}

class _AddFactPageState extends State<AddFactPage> {
  final factController = TextEditingController();
  String category = '冷知識';
  bool isLoading = false;
  final List<String> categories = [...factCategories];

  @override
  void dispose() {
    factController.dispose();
    super.dispose();
  }

  Future<void> showAddCategoryDialog() async {
    final controller = TextEditingController();

    final newCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新增分類'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '分類名稱',
              hintText: '例如：飲食、睡眠、品種',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(context, text);
              },
              child: const Text('新增'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newCategory == null || newCategory.isEmpty) return;
    if (!mounted) return;

    setState(() {
      if (!categories.contains(newCategory)) {
        categories.add(newCategory);
      }
      category = newCategory;
    });
  }

  Future<void> addFact() async {
    final user = supabase.auth.currentUser;
    final text = factController.text.trim();

    if (user == null) {
      showMessage('請先登入');
      return;
    }

    if (text.isEmpty) {
      showMessage('請輸入你想新增的 Cat Fact');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final savedFact = await supabase
          .from('cat_facts')
          .insert({
            'api_fact_id':
                'user-${user.id}-${DateTime.now().millisecondsSinceEpoch}',
            'text': text,
            'source': 'user',
            'category': category,
            'created_by': user.id,
          })
          .select()
          .single();

      await supabase.from('cat_fact_favorites').insert({
        'user_id': user.id,
        'fact_id': savedFact['id'],
        'category': category,
      });

      if (!mounted) return;
      setState(() {
        isLoading = false;
        factController.clear();
        category = '冷知識';
      });
      showMessage('新增成功，並已加入你的收藏');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showMessage('新增失敗：$e');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade100, Colors.orange.shade50],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.edit_note,
                  size: 40,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '新增自己的 Cat Fact',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('你新增的內容會自動加入自己的收藏。'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          shadowColor: Colors.orange.withAlpha(35),
          color: Colors.orange.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orangeAccent),
                    SizedBox(width: 8),
                    Text(
                      '冷知識內容',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: factController,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText:
                        '例如：Cats spend about 70% of their lives sleeping.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '選擇分類',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in categories)
                      ChoiceChip(
                        label: Text(item),
                        selected: category == item,
                        onSelected: (_) {
                          setState(() {
                            category = item;
                          });
                        },
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('新增分類'),
                      onPressed: showAddCategoryDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: isLoading ? null : addFact,
            icon: isLoading ? const Icon(Icons.pets) : const Icon(Icons.send),
            label: Text(isLoading ? '新增中...' : '新增冷知識'),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          Center(
            child: buildLottieAsset(
              catTypingLottieAsset,
              width: 120,
              height: 120,
              fallback: const CircularProgressIndicator(),
            ),
          ),
        ],
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class CatFactCard extends StatelessWidget {
  const CatFactCard({
    super.key,
    required this.fact,
    required this.subtitle,
    required this.onFavorite,
    required this.onCopy,
    required this.onTranslate,
    this.translatedText,
    this.favoriteCategory,
    this.isTranslating = false,
    this.isFavorite = false,
    this.isSavingFavorite = false,
  });

  final CatFact fact;
  final String subtitle;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;
  final VoidCallback onTranslate;
  final String? translatedText;
  final String? favoriteCategory;
  final bool isTranslating;
  final bool isFavorite;
  final bool isSavingFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.orange.withAlpha(40),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.pets, color: Colors.orange.shade700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_outlined),
                  ),
                  IconButton(
                    onPressed: isSavingFavorite ? null : onFavorite,
                    icon: isSavingFavorite
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                    color: Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SelectableText(
                fact.text,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (isFavorite && favoriteCategory != null)
                    Chip(
                      avatar: const Icon(Icons.label_outline, size: 16),
                      label: Text(favoriteCategory!),
                      backgroundColor: Colors.white,
                    ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: isTranslating ? null : onTranslate,
                    icon: isTranslating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.translate),
                    label: Text(
                      translatedText == null
                          ? isTranslating
                                ? '翻譯中...'
                                : '翻譯'
                          : '已翻譯',
                    ),
                  ),
                ],
              ),
              if (translatedText != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Text(
                    translatedText!,
                    style: const TextStyle(fontSize: 16, height: 1.45),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
