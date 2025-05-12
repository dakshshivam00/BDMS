import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendOTP(
    String phoneNumber,
    Function(String) codeSent,
    Function(User?) completed,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCredential = await _auth.signInWithCredential(credential);
        completed(userCredential.user);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      return false;
    }
  }
}
