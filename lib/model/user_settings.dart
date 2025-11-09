class UserSettings {
  static String _savedCourtName = 'Badminton Court 1';
  static String _savedCourtRate = '50.00';
  static String _savedShuttleCockPrice = '15.00';
  static bool _savedDivideCourtEqually = true;
  static bool _savedDivideShuttleEqually = true;

  // Getters
  static String get defaultCourtName => _savedCourtName;
  static double get defaultCourtRate => double.tryParse(_savedCourtRate) ?? 50.0;
  static double get defaultShuttleCockPrice => double.tryParse(_savedShuttleCockPrice) ?? 15.0;
  static bool get defaultDivideCourtEqually => _savedDivideCourtEqually;
  static bool get defaultDivideShuttleEqually => _savedDivideShuttleEqually;


  // Setters  
  static void updateCourtName(String value) => _savedCourtName = value;
  static void updateCourtRate(String value) => _savedCourtRate = value;
  static void updateShuttleCockPrice(String value) => _savedShuttleCockPrice = value;
  static void updateDivideCourtEqually(bool value) => _savedDivideCourtEqually = value;
  static void updateDivideShuttleEqually(bool value) => _savedDivideShuttleEqually = value;
}