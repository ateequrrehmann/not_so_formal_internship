import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import '../../view_models/userNotifier.dart';

final userProvider =
StateNotifierProvider<UserNotifier, UserData>((ref) => UserNotifier());