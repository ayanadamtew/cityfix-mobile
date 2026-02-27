import 'package:cityfix_mobile/l10n/app_localizations.dart';

extension AppLocalizationsX on AppLocalizations {
  String translateCategory(String category) {
    switch (category.toLowerCase()) {
      case 'water':
        return catWater;
      case 'waste':
        return catWaste;
      case 'road':
        return catRoad;
      case 'electricity':
        return catElectricity;
      default:
        return category; // Fallback to raw string
    }
  }

  String translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'in_progress':
      case 'in progress':
        return statusInProgress;
      case 'resolved':
        return statusResolved;
      default:
        return status; // Fallback to raw string
    }
  }
}
