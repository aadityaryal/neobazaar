import 'package:neobazaar/core/error/failures.dart';

class FailureViewData {
  final String title;
  final String message;

  const FailureViewData({required this.title, required this.message});

  factory FailureViewData.fromFailure(Failure failure) {
    if (failure is ApiFailure) {
      if (failure.statusCode == 401) {
        return const FailureViewData(
          title: 'Session expired',
          message: 'Please log in again.',
        );
      }
      if (failure.statusCode == 403) {
        return const FailureViewData(
          title: 'Access denied',
          message: 'You do not have permission for this action.',
        );
      }
      return FailureViewData(title: 'Request failed', message: failure.message);
    }

    return FailureViewData(
      title: 'Something went wrong',
      message: failure.message,
    );
  }
}
