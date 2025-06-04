
import 'dart:ui';

import '../../../../common/app_color.dart';

Color getStatusColor(String? status) {
  if (status == null || status.isEmpty) return AppColorList.MainShadow;
  switch (status.toLowerCase()) {
    case 'new':
      return AppColorList.blue;
    case 'assigned':
      return AppColorList.Star1;
    case 'work_in':
      return AppColorList.Warning;
    case 'cancel':
      return AppColorList.Star3;
    default:
      return AppColorList.MainShadow;
  }
}

String getStatusLabel(String? state) {
  switch (state) {
    case 'new':
      return 'New';
    case 'assigned':
      return 'Assigned';
    case 'work_in':
      return 'Work In Progress';
    case 'need_info':
      return 'Need Info';
    case 'reopened':
      return 'Reopened';
    case 'solution':
      return 'Solution';
    case 'closed':
      return 'Closed';
    case 'cancel':
      return 'Cancelled';
    default:
      return 'No Status Available';
  }
}
