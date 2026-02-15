class DashboardTokenState {
  final int tokenBalance;

  const DashboardTokenState({this.tokenBalance = 0});

  DashboardTokenState copyWith({int? tokenBalance}) {
    return DashboardTokenState(tokenBalance: tokenBalance ?? this.tokenBalance);
  }
}
