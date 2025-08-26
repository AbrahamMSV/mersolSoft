enum SemaforoStatus { enTiempo, retraso, fueraDeTiempo, desconocido }

extension SemaforoStatusX on SemaforoStatus {
  static SemaforoStatus parse(String? raw) {
    final s = (raw ?? '').trim().toLowerCase();
    switch (s) {
      case 'en tiempo':
      case 'entiempo':
        return SemaforoStatus.enTiempo;
      case 'retraso':
        return SemaforoStatus.retraso;
      case 'fuera de tiempo':
      case 'fueradetiempo':
        return SemaforoStatus.fueraDeTiempo;
      default:
        return SemaforoStatus.desconocido;
    }
  }

  String get label => switch (this) {
    SemaforoStatus.enTiempo      => 'En tiempo',
    SemaforoStatus.retraso       => 'Retraso',
    SemaforoStatus.fueraDeTiempo => 'Fuera de tiempo',
    SemaforoStatus.desconocido   => 'Desconocido',
  };
}
