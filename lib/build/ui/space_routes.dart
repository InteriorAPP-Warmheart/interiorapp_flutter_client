abstract final class SpaceRoutes {
  static const String prep = '/build/prep';
  static const String prepCreate = '/build/prep/create';
  static const String prepConsult = '/build/prep/consult';
  static const String prepRecord = '/build/prep/record';
  static const String trade = '/build/prep/trade';
  static const String tradeCreate = '/build/prep/trade/create';

  static String prepEdit(int step) => '$prepCreate?step=$step';

  static String detail(String projectId) => '/build/$projectId';
}
