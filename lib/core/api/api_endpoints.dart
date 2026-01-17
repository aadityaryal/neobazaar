import 'package:neobazaar/core/constants/app_constants.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL and versioned base URL
  static String get baseUrl => AppConstants.apiBaseUrl;
  static String get baseUrlV1 => AppConstants.apiBaseUrlV1;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';
  static const String authSessions = '/auth/sessions';
  static const String authSessionsRevoke = '/auth/sessions/revoke';
  static const String authSessionsRevokeAll = '/auth/sessions/revoke-all';
  static const String authVerificationChallenge =
      '/auth/verification/challenge';
  static const String authVerificationSubmit = '/auth/verification/submit';

  // ============ Product Endpoints ============
  static const String products = '/products';
    static const String productImageUpload = '/products/upload';
  static String productById(String productId) => '/products/$productId';
  static String productPublicById(String productId) =>
      '/products/$productId/public';

  // ============ Transaction Endpoints ============
  static const String transactions = '/transactions';
  static String transactionConfirm(String txnId) =>
      '/transactions/$txnId/confirm';
  static String transactionDispute(String txnId) =>
      '/transactions/$txnId/dispute';
  static String transactionDisputeEvidence(String txnId) =>
      '/transactions/$txnId/dispute/evidence';

  // ============ Bid Endpoints ============
  static const String bids = '/bids';

  // ============ Chat Endpoints ============
  static const String chatsReplay = '/chats/replay';
  static const String chats = '/chats';
  static String chatMessages(String chatId) => '/chats/$chatId/messages';
  static String chatReadReceipt(String chatId, String messageId) =>
      '/chats/$chatId/messages/$messageId/read';

  // ============ User Endpoints ============
  static String userById(String userId) => '/users/$userId';
  static String userKycSubmit(String userId) => '/users/$userId/kyc/submit';
  static String userKycReview(String userId) => '/users/$userId/kyc/review';
  static const String userWalletTopupAlias = '/users/wallet/topup';

  // ============ Quest Endpoints ============
  static const String quests = '/quests';
  static String questComplete(String questId) => '/quests/$questId/complete';

  // ============ Leaderboard Endpoints ============
  static const String leaderboard = '/leaderboard';

  // ============ Admin Endpoints ============
  static const String adminHeatmap = '/admin/heatmap';
    static const String adminUsers = '/admin/users';
    static String adminUserById(String userId) => '/admin/users/$userId';
  static const String adminExport = '/admin/export';
  static const String adminExportJobs = '/admin/export/jobs';
  static String adminExportJobById(String exportJobId) =>
      '/admin/export/jobs/$exportJobId';
  static const String adminFlags = '/admin/flags';
    static const String adminDisputes = '/admin/disputes';
  static String adminFlagById(String flagId) => '/admin/flags/$flagId';
  static String adminDisputeDecide(String disputeId) =>
      '/admin/disputes/$disputeId/decide';
  static String adminModerationUndo(String actionId) =>
      '/admin/moderation/$actionId/undo';
  static const String adminAuditLogs = '/admin/audit/logs';
  static const String adminAuditRetentionRun = '/admin/audit/retention/run';

  // ============ Wallet Endpoints ============
  static const String walletTopup = '/wallet/topup';

  // ============ Offer Endpoints ============
  static const String offers = '/offers';
  static String offerCounter(String offerId) => '/offers/$offerId/counter';
  static String offerAccept(String offerId) => '/offers/$offerId/accept';
  static String offerReject(String offerId) => '/offers/$offerId/reject';

  // ============ Order Endpoints ============
  static const String orders = '/orders';
  static String orderTimeline(String orderId) => '/orders/$orderId/timeline';

  // ============ Review Endpoints ============
  static const String reviews = '/reviews';
  static String reviewsByProduct(String productId) =>
      '/reviews/products/$productId';
  static String reviewFlag(String reviewId) => '/reviews/$reviewId/flag';

  // ============ Campaign Endpoints ============
  static const String campaigns = '/campaigns';
  static String campaignStatus(String campaignId) =>
      '/campaigns/$campaignId/status';

  // ============ Seller Endpoints ============
  static const String sellerListingsAnalytics = '/seller/analytics/listings';
  static const String sellerBulkImport = '/seller/bulk-import';
  static const String sellerPayoutLedger = '/seller/payouts/ledger';

  // ============ Notification Endpoints ============
  static const String notifications = '/notifications';
  static String notificationRead(String notificationId) =>
      '/notifications/$notificationId/read';

  // ============ Referral Endpoints ============
  static const String referrals = '/referrals';
  static String referralQualify(String referralId) =>
      '/referrals/$referralId/qualify';

  // ============ Risk Endpoints ============
  static String riskUserScore(String userId) => '/risk/score/users/$userId';

  // ============ Extension / AI Endpoints ============
  static const String detect = '/detect';
  static const String price = '/price';
  static const String fraud = '/fraud';
  static const String recommend = '/recommend';
  static const String nlpSuggest = '/nlp/suggest';
  static const String syncResolve = '/sync/resolve';

  // aliases
  static const String aiDetect = '/ai/detect';
  static const String aiPrice = '/ai/price';
  static const String aiRecommend = '/ai/recommend';
}
