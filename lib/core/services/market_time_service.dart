/// Service utilitaire — Vérifie si le marché BVMT est ouvert
/// Horaires : Lundi-Vendredi, 09:00 - 13:00
class MarketTimeService {
  /// Vérifie si le marché est actuellement ouvert
  static bool isMarketOpen([DateTime? now]) {
    final current = now ?? DateTime.now();

    // Fermé le week-end (samedi = 6, dimanche = 7)
    if (current.weekday >= 6) return false;

    final hour = current.hour;

    // Ouvert entre 9h00 et 12h59 (ferme à 13h00)
    return hour >= 9 && hour < 13;
  }

  /// Calcule le temps restant avant le prochain changement de statut
  /// Retourne la durée avant l'ouverture (si fermé) ou la fermeture (si ouvert)
  static Duration timeUntilNextChange([DateTime? now]) {
    final current = now ?? DateTime.now();

    if (isMarketOpen(current)) {
      // Marché ouvert → calcule le temps jusqu'à 13h00
      final closeTime = DateTime(current.year, current.month, current.day, 13);
      return closeTime.difference(current);
    } else {
      // Marché fermé → calcule le temps jusqu'à la prochaine ouverture (9h00)
      DateTime nextOpen;
      if (current.hour >= 13 || current.weekday >= 6) {
        // Après la fermeture ou week-end → prochain jour ouvrable à 9h
        nextOpen = _nextWeekday(current, 9);
      } else {
        // Avant l'ouverture du même jour
        nextOpen = DateTime(current.year, current.month, current.day, 9);
      }
      return nextOpen.difference(current);
    }
  }

  /// Retourne le texte d'affichage du statut horaire
  static String statusText([DateTime? now]) {
    final current = now ?? DateTime.now();

    if (isMarketOpen(current)) {
      final remaining = timeUntilNextChange(current);
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      if (hours > 0) {
        return 'Ferme dans ${hours}h${minutes.toString().padLeft(2, '0')}';
      }
      return 'Ferme dans ${minutes}min';
    } else {
      if (current.weekday >= 6) {
        return 'Ouvre lundi à 09:00';
      }
      if (current.hour >= 13) {
        return 'Ouvre demain à 09:00';
      }
      final remaining = timeUntilNextChange(current);
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      if (hours > 0) {
        return 'Ouvre dans ${hours}h${minutes.toString().padLeft(2, '0')}';
      }
      return 'Ouvre dans ${minutes}min';
    }
  }

  /// Trouve le prochain jour ouvrable à l'heure donnée
  static DateTime _nextWeekday(DateTime from, int hour) {
    var next = DateTime(from.year, from.month, from.day + 1, hour);
    while (next.weekday >= 6) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }
}
