# Auth Interceptor Debug Guide

## Muammoni Tekshrish

### 1. Token Storage'ni Tekshiring

```dart
// Login qilgandan keyin
final prefs = getIt<AppPreferences>();
print('Access Token: ${prefs.readAccessToken()}');
print('Refresh Token: ${prefs.readRefreshToken()}');
```

Agar tokenlar `null` yoki bo'sh bo'lsa, login jarayonida token saqlanmayapti.

### 2. Interceptor Qo'shilganligini Tekshiring

```dart
final dio = getIt<Dio>();
print('Interceptors count: ${dio.interceptors.length}');
for (var interceptor in dio.interceptors) {
  print('Interceptor: ${interceptor.runtimeType}');
}
```

`AuthInterceptor` ro'yxatda bo'lishi kerak.

### 3. Request Headers'ni Tekshiring

Talker logs'da quyidagi xabarlarni qidiring:

```
🔐 AuthInterceptor onRequest:
  Path: /your/endpoint
  Method: GET
  Is Auth Endpoint: false
  Has Token: true
  ✅ Added Bearer token to request: /your/endpoint
```

Agar `Has Token: false` bo'lsa - token storage'da yo'q.
Agar `Is Auth Endpoint: true` bo'lsa - endpoint auth endpoint deb o'ylayapti.

### 4. TalkerDioLogger Output'ni Tekshiring

TalkerDioLogger requestni log qilayotganda headers ko'rsatiladi:

```
Headers:
  Authorization: Bearer eyJhbGci...
```

Agar bu yerda Authorization header bo'lmasa - interceptor ishlamayapti.

## Tez Yechim

Agar interceptor ishlamayotgan bo'lsa:

### Variant 1: Dio instance'ni restart qiling

```dart
// service_locator.dart'da
await getIt.reset();
await setupServiceLocator();
```

### Variant 2: Manual header qo'shing (vaqtinchalik)

```dart
final dio = getIt<Dio>();
final token = getIt<AppPreferences>().readAccessToken();

final response = await dio.get(
  '/endpoint',
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
    },
  ),
);
```

### Variant 3: Interceptor'ni alohida yarating

```dart
class MyRepository {
  final Dio _dio;
  final AppPreferences _prefs;

  Future<Response> request(String path) async {
    final token = _prefs.readAccessToken();
    return _dio.get(
      path,
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
  }
}
```

## Common Issues

### Issue 1: `_isAuthEndpoint` barcha endpointlarni auth deb o'ylayapti

Solution: Debug logs'da `Is Auth Endpoint` qiymatini tekshiring. Path to'g'ri format'da bo'lishi kerak.

```dart
// To'g'ri: /api/orders/
// Noto'g'ri: /auth/login/ (bu auth endpoint)
```

### Issue 2: Dio instance yangi yaratilmoqda

Solution: Dio singleton bo'lganligini tekshiring:

```dart
// service_locator.dart
getIt.registerLazySingleton<Dio>(() => ...);  // ✅ To'g'ri
getIt.registerFactory<Dio>(() => ...);  // ❌ Noto'g'ri
```

### Issue 3: Token format noto'g'ri

Solution: Token "Bearer " qo'shimchasi bilan boshlanmasligi kerak storage'da:

```dart
// ✅ To'g'ri
await prefs.setAccessToken('eyJhbGci...');

// ❌ Noto'g'ri  
await prefs.setAccessToken('Bearer eyJhbGci...');
```

Interceptor o'zi "Bearer " qo'shadi.

### Issue 4: Login response'da token yo'q

Solution: Backend response'ni tekshiring. `access` va `refresh` fieldlari bo'lishi kerak.

## Test Code

Test uchun oddiy snippet:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:suv_kerak_courier/core/di/service_locator.dart';
import 'package:suv_kerak_courier/core/storage/app_preferences.dart';
import 'package:dio/dio.dart';

void main() async {
  await setupServiceLocator();
  
  final prefs = getIt<AppPreferences>();
  final dio = getIt<Dio>();
  
  // Set a test token
  await prefs.setAccessToken('test_token_12345');
  
  // Make a test request
  try {
    await dio.get('/test');
  } catch (e) {
    print('Error (expected): $e');
  }
  
  // Check logs for "Added Bearer token"
}
```
