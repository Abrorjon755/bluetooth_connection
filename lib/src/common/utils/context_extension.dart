import 'package:flutter/material.dart';

import '../dependency/dependency.dart';
import '../l10n/generated/l10n.dart';
import '../widgets/my_app_scope.dart';

extension ContextExtension on BuildContext {
  S get lang => S.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  AppDependency get dependency =>
      findRootAncestorStateOfType<MyAppScopeState>()!.dependency;
}
