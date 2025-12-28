import 'package:flutter/foundation.dart';

import 'package:family_cloud_app/models/upload_task.dart';

class UploadController extends ChangeNotifier {
  final List<UploadTask> _tasks = <UploadTask>[];

  List<UploadTask> get tasks => List<UploadTask>.unmodifiable(_tasks);

  void setTasks(Iterable<UploadTask> tasks) {
    _tasks
      ..clear()
      ..addAll(tasks);
    notifyListeners();
  }

  void addTask(UploadTask task) {
    _tasks.add(task);
    notifyListeners();
  }
}
