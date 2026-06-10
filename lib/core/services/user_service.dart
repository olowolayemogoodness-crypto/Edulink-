import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get uid => _auth.currentUser?.uid;

  // ── Create profile on first sign-in ──
  static Future<void> ensureProfile({required String uid, required String displayName, required String email}) async {
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'bio': '',
        'school': '',
        'course': '',
        'country': 'Nigeria',
        'xp': 0,
        'xpToday': 0,
        'rank': 0,
        'streak': 0,
        'longestStreak': 0,
        'lastStudyDate': null,
        'tasksToday': 0,
        'tasksGoal': 10,
        'studyHoursToday': 0.0,
        'studyHoursGoal': 4.0,
        'quizAccuracy': 0.0,
        'friends': 0,
        'tasksDone': 0,
        'level': 1,
        'badges': [],
        'studentType': (await SharedPreferences.getInstance()).getString('student_type') ?? 'university',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Get profile stream ──
  static Stream<Map<String, dynamic>?> profileStream() {
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots().map((s) => s.data());
  }

  // ── Get profile once ──
  static Future<Map<String, dynamic>?> getProfile() async {
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── Update display name ──
  static Future<void> updateDisplayName(String name) async {
    if (uid == null) return;
    await _auth.currentUser!.updateDisplayName(name);
    await _auth.currentUser!.reload();
    await _db.collection('users').doc(uid).update({'displayName': name});
  }

  // ── Update profile fields ──
  static Future<void> updateProfile({String? bio, String? school, String? course, String? country}) async {
    if (uid == null) return;
    final data = <String, dynamic>{};
    if (bio != null) data['bio'] = bio;
    if (school != null) data['school'] = school;
    if (course != null) data['course'] = course;
    if (country != null) data['country'] = country;
    if (data.isNotEmpty) await _db.collection('users').doc(uid).update(data);
  }

  // ── Award XP ──
  static Future<void> awardXP(int amount, {String reason = ''}) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'xp': FieldValue.increment(amount),
      'xpToday': FieldValue.increment(amount),
      'tasksToday': FieldValue.increment(1),
      'tasksDone': FieldValue.increment(1),
    });
  }
// ── Reset daily XP if new day ──
  static Future<void> resetDailyIfNeeded() async {
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    final data = doc.data();
    if (data == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset = (data['lastDailyReset'] as Timestamp?)?.toDate();
    final lastResetDay = lastReset != null ? DateTime(lastReset.year, lastReset.month, lastReset.day) : null;

    if (lastResetDay == null || lastResetDay.isBefore(today)) {
      final updates = <String, dynamic>{
        'xpToday': 0,
        'tasksToday': 0,
        'lastDailyReset': FieldValue.serverTimestamp(),
      };
      final lastStudy = (data['lastStudyDate'] as Timestamp?)?.toDate();
      if (lastStudy != null) {
        final lastStudyDay = DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
        final yesterday = today.subtract(const Duration(days: 1));
        if (lastStudyDay.isBefore(yesterday)) {
          updates['streak'] = 0;
        }
      }
      await ref.update(updates);
    }
  }
  // ── Update streak ──
  static Future<void> updateStreak() async {
    if (uid == null) return;
    final ref = _db.collection('users').doc(uid);
    final doc = await ref.get();
    final data = doc.data();
    if (data == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudy = (data['lastStudyDate'] as Timestamp?)?.toDate();
    final lastDay = lastStudy != null ? DateTime(lastStudy.year, lastStudy.month, lastStudy.day) : null;

    if (lastDay == today) return; // already studied today

    final newStreak = lastDay == today.subtract(const Duration(days: 1))
        ? (data['streak'] as int? ?? 0) + 1
        : 1; // reset streak if missed a day

    final longest = newStreak > (data['longestStreak'] as int? ?? 0) ? newStreak : (data['longestStreak'] as int? ?? 0);

    await ref.update({
      'streak': newStreak,
      'longestStreak': longest,
      'lastStudyDate': FieldValue.serverTimestamp(),
    });
  }

  // ── Log study hours ──
  static Future<void> logStudyTime(double hours) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({
      'studyHoursToday': FieldValue.increment(hours),
    });
  }

  // ── Update leaderboard ──
  static Future<void> updateLeaderboard() async {
    if (uid == null) return;
    final profile = await getProfile();
    if (profile == null) return;
    await _db.collection('leaderboard').doc(uid).set({
      'uid': uid,
      'displayName': profile['displayName'],
      'xp': profile['xp'],
      'streak': profile['streak'],
      'country': profile['country'],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}