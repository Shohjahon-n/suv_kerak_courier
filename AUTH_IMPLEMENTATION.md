# Authentication Implementation

Bu loyihada JWT token-based authentication mexanizmi amalga oshirilgan.

## Arxitektura

### 1. Core Components

#### AuthInterceptor (`lib/core/network/auth_interceptor.dart`)
- Har bir HTTP requestga `Authorization: Bearer <token>` header qo'shadi
- 401 xatoliklarni ushlaydi va token refresh jarayonini boshlaydi
- Token yangilanganidan keyin failed requestlarni qayta yuboradi

#### DioClient (`lib/core/network/dio_client.dart`)
- Dio instance yaratadi va interceptorlarni qo'shadi
- AuthInterceptor logging interceptordan oldin qo'shiladi

#### AppPreferences (`lib/core/storage/app_preferences.dart`)
- Access va refresh tokenlarni saqlaydi
- User ma'lumotlarini (courier_id, business_id) saqlaydi
- Session ma'lumotlarini tozalaydi

### 2. Feature Components

#### LoginResponse Model (`lib/features/auth/data/models/login_response.dart`)
Backend'dan qaytadigan login response modeli:
```dart
{
  "ok": true,
  "detail": "Муваффақиятли кирдингиз.",
  "kuryer_id": 148095163,
  "name": "Эриелл",
  "lang": "uz",
  "business_id": 747789912,
  "last_active_at": "2026-01-25T15:51:56.760203+05:00",
  "sessionid": "tauo0zi6gqq3ycbop06kunyhd2o097wv",
  "access": "eyJhbGci...",
  "refresh": "eyJhbGci...",
  "token_type": "Bearer"
}
```

#### AuthRepository (`lib/features/auth/data/repositories/auth_repository.dart`)
- Login API chaqiriqlarini boshqaradi
- Tokenlarni va user ma'lumotlarini storage'ga saqlaydi
- Logout funksiyasini amalga oshiradi
- Auth holatini tekshirish metodlari

#### AuthCubit (`lib/features/auth/presentation/bloc/auth_cubit.dart`)
State management uchun:
- `login()` - foydalanuvchini tizimga kiritish
- `logout()` - foydalanuvchini tizimdan chiqarish
- `checkAuthStatus()` - auth holatini tekshirish
- `clearError()` - xatoliklarni tozalash

## Qanday Ishlatish

### 1. Login Page'da

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suv_kerak_courier/core/di/service_locator.dart';
import 'package:suv_kerak_courier/features/auth/presentation/bloc/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            // Navigate to home
            context.go('/home');
          } else if (state.status == AuthStatus.error) {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          context.read<AuthCubit>().login(
                                phone: _phoneController.text,
                                password: _passwordController.text,
                              );
                        },
                  child: state.isLoading
                      ? CircularProgressIndicator()
                      : Text('Login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 2. API Call (avtomatik token bilan)

Endi har qanday API call avtomatik ravishda token bilan yuboriladi:

```dart
import 'package:dio/dio.dart';
import 'package:suv_kerak_courier/core/di/service_locator.dart';

class OrderRepository {
  final Dio _dio = getIt<Dio>();

  Future<void> getOrders() async {
    // Token avtomatik qo'shiladi!
    final response = await _dio.get('/orders/');
    
    // Response processing...
  }
}
```

### 3. Logout

```dart
ElevatedButton(
  onPressed: () {
    context.read<AuthCubit>().logout();
    context.go('/login');
  },
  child: Text('Logout'),
)
```

### 4. Check Auth Status (App Start)

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>()..checkAuthStatus(),
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

## Token Refresh Flow

1. API request yuboriladi
2. Agar 401 xatolik qaytsa:
   - AuthInterceptor refresh token bilan `/auth/token/refresh/` endpoint'ga murojaat qiladi
   - Yangi tokenlar olinadi va storage'ga saqlanadi
   - Failed request yangi token bilan qayta yuboriladi
   - Queued requestlar ham yangi token bilan yuboriladi
3. Agar refresh ham failed bo'lsa:
   - Session tozalanadi
   - Foydalanuvchi login page'ga yo'naltiriladi

## Security Best Practices

1. **Tokenlar xavfsiz saqlanadi**: `SharedPreferences` orqali
2. **Auth endpoints tokendan ozod**: Login, register va forgot-password endpointlar token talab qilmaydi
3. **Automatic refresh**: Tokenlar avtomatik yangilanadi
4. **Error handling**: Barcha xatoliklar Talker orqali loglanadi

## Environment Variables

API base URL `lib/core/constants/app_constants.dart` faylida:

```dart
class AppConstants {
  static const String apiBaseUrl = 'https://api.example.com';
}
```

## Testing

AuthRepository va AuthCubit'ni test qilish uchun:

```dart
void main() {
  setUp(() async {
    await setupServiceLocator();
  });

  tearDown(() async {
    await resetServiceLocator();
  });

  test('login successful', () async {
    final authCubit = getIt<AuthCubit>();
    
    await authCubit.login(
      phone: '+998901234567',
      password: 'password123',
    );

    expect(authCubit.state.status, AuthStatus.authenticated);
  });
}
```

## Troubleshooting

### Token saqlanmayapti
- `AppPreferences.setAccessToken()` va `setRefreshToken()` chaqirilganini tekshiring
- Storage permissions'ni tekshiring

### 401 loop
- Refresh endpoint to'g'ri ishlayotganini tekshiring
- Token expiry time'ni tekshiring

### Headers qo'shilmayapti
- AuthInterceptor Dio'ga qo'shilganini tekshiring
- Endpoint auth endpoint emas ekanligini tekshiring (`_isAuthEndpoint` metodi)
