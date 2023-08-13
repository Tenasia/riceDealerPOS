// state_manager.dart

enum StateType { requestStocks, requestReprice, requestPullOut, acceptRequests, tradeStocks }

class StateManager {
  static StateType _currentState = StateType.requestStocks;

  static StateType get currentState => _currentState;

  static void setCurrentState(StateType newState) {
    _currentState = newState;
  }
}
