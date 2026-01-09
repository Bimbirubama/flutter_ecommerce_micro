import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/main.dart'; // Pastikan 'ecommerce' sesuai dengan nama project di pubspec.yaml

void main() {
  testWidgets('Tampilan Login Smoke Test', (WidgetTester tester) async {
    // 1. Jalankan aplikasi dengan initialRoute ke halaman login
    await tester.pumpWidget(const MyApp(initialRoute: '/login'));

    // 2. Verifikasi apakah teks "Welcome Back" (dari LoginPage) muncul
    expect(find.text('Welcome Back'), findsOneWidget);

    // 3. Verifikasi apakah tombol LOGIN ada
    expect(find.text('LOGIN'), findsOneWidget);

    // 4. Verifikasi apakah ada input field (email & password)
    expect(find.byType(TextField), findsAtLeastNWidgets(2));

    // 5. Coba cari teks "Register Now" untuk pindah halaman
    expect(find.text("Don't have an account? Register Now"), findsOneWidget);
  });
}