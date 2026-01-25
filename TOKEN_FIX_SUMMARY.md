# Token Authentication - To'g'rilangan Muammolar

## Muammo

Login qilganda tokenlar storage'ga saqlanmayotgan edi va keyingi API requestlarda `Authorization` header yo'q edi.

## Sabab

`login_page.dart` da login response'dan `access` va `refresh` tokenlar **saqlanmayotgan** edi. Faqat `courier_id` va `business_id` saqlanardi.

## Yechim

### 1. Login Page'da Token Saqlash (lib/features/auth/presentation/pages/login_page.dart:82-91)

**Oldingi kod:**
```dart
final responseCourierId = intValue(data['kuryer_id']);
final responseBusinessId = intValue(data['business_id']);

await preferences.setCourierId(responseCourierId ?? courierId);
await preferences.setBusinessId(responseBusinessId);
```

**Yangi kod:**
```dart
final responseCourierId = intValue(data['kuryer_id']);
final responseBusinessId = intValue(data['business_id']);
final accessToken = stringValue(data, 'access');
final refreshToken = stringValue(data, 'refresh');

// Save tokens
await preferences.setAccessToken(accessToken);
await preferences.setRefreshToken(refreshToken);

// Save user data
await preferences.setCourierId(responseCourierId ?? courierId);
await preferences.setBusinessId(responseBusinessId);
```

### 2. AuthInterceptor Debugging Improvements

`auth_interceptor.dart` ga batafsil logging qo'shildi:

```dart
_talker.debug('🔐 AuthInterceptor onRequest:');
_talker.debug('  Path: ${options.path}');
_talker.debug('  Has Token: ${accessToken != null && accessToken.isNotEmpty}');
_talker.info('  ✅ Added Bearer token to: ${options.path}');
```

### 3. Circular Dependency Fix

DioClient va AuthInterceptor o'rtasidagi circular dependency hal qilindi:

```dart
// DioClient.create()
final authInterceptor = AuthInterceptor(
  preferences: preferences,
  talker: talker,
);

dio.interceptors.add(authInterceptor);

// Set Dio after adding to avoid circular dependency
authInterceptor.setDio(dio);
```

## Endi Qanday Ishlaydi

### 1. Login Flow

```
User enters credentials
    ↓
POST /couriers/login/
    ↓
Backend returns:
{
  "access": "eyJhbGci...",
  "refresh": "eyJhbGci...",
  "kuryer_id": 148095163,
  "business_id": 747789912
}
    ↓
✅ Tokens saved to SharedPreferences
    ↓
Navigate to home/profile-completion
```

### 2. Subsequent Requests Flow

```
User makes API request (e.g., GET /orders/)
    ↓
AuthInterceptor.onRequest()
    ↓
Read access token from storage
    ↓
Add header: Authorization: Bearer <access_token>
    ↓
Request sent with token
    ↓
✅ Backend validates token and returns data
```

### 3. Token Refresh Flow (401 Error)

```
API request fails with 401
    ↓
AuthInterceptor.onError()
    ↓
Read refresh token from storage
    ↓
POST /auth/token/refresh/ with refresh token
    ↓
Get new access + refresh tokens
    ↓
Save new tokens to storage
    ↓
Retry original request with new token
    ↓
✅ Request succeeds
```

## Test Qilish

### 1. Login qiling va logs tekshiring

Quyidagi log xabarlarni ko'rishingiz kerak:

```
💾 Saving session to storage...
  Access Token: eyJhbGciOiJIUzI1NiIs...
  Refresh Token: eyJhbGciOiJIUzI1NiIs...
  Courier ID: 148095163
  Business ID: 747789912
✅ Session saved successfully
  Verified Access Token: true
  Verified Refresh Token: true
```

### 2. Keyingi request yuborilganda

```
🔐 AuthInterceptor onRequest:
  Path: /couriers/check-courier-parametr/
  Method: POST
  Is Auth Endpoint: false
  Has Token: true
  ✅ Added Bearer token to: /couriers/check-courier-parametr/
  Token preview: eyJhbGciOiJIUzI1NiIs...
```

### 3. TalkerDioLogger da header ko'rsatiladi

```
[http-request] [POST] .../couriers/check-courier-parametr/
Headers: {
  "content-type": "application/json",
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiIs..."
}
```

## Yaratilgan Fayllar

1. ✅ `lib/core/network/auth_interceptor.dart` - Token injection va refresh
2. ✅ `lib/features/auth/data/models/login_response.dart` - Login response model
3. ✅ `lib/features/auth/data/models/login_request.dart` - Login request model
4. ✅ `lib/features/auth/data/repositories/auth_repository.dart` - Auth API calls
5. ✅ `lib/features/auth/presentation/bloc/auth_cubit.dart` - Auth state management
6. ✅ `lib/features/auth/presentation/bloc/auth_state.dart` - Auth state

## Keyingi Qadamlar (Optional)

Agar xohlasangiz, mavjud login kodini AuthRepository va AuthCubit bilan almashtira olasiz:

```dart
// Eski usul (hozirgi)
final dio = context.read<Dio>();
final response = await dio.post('/couriers/login/', ...);
await preferences.setAccessToken(response.data['access']);

// Yangi usul (clean architecture)
final authCubit = context.read<AuthCubit>();
await authCubit.login(phone: phone, password: password);
// Tokens automatically saved!
```

Lekin hozirgi kod ham yaxshi ishlaydi! ✅
