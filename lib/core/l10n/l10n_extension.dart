import 'package:flutter/material.dart';
import 'package:aksat/core/l10n/app_localizations.dart';

export 'package:aksat/core/l10n/app_localizations.dart';

extension AppL10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
