import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neobazaar/app/routes/app_routes.dart';
import 'package:neobazaar/core/providers/app_session_provider.dart';
import 'package:neobazaar/core/state/async_status.dart';
import 'package:neobazaar/core/utils/snackbar_utils.dart';
import 'package:neobazaar/features/chat/data/datasources/remote/chat_remote_datasource.dart';
import 'package:neobazaar/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:neobazaar/features/item/domain/entities/product_entity.dart';
import 'package:neobazaar/features/item/presentation/view_model/local_product_notifier.dart';
import 'package:neobazaar/features/item/presentation/view_model/product_detail_notifier.dart';
import 'package:neobazaar/features/trade/presentation/pages/offers_inbox_page.dart';
import 'package:neobazaar/features/trade/presentation/view_model/bid_notifier.dart';
import 'package:neobazaar/features/trade/presentation/view_model/offer_notifier.dart';
import 'package:neobazaar/features/trade/presentation/view_model/review_notifier.dart';
import 'package:neobazaar/features/trade/presentation/view_model/transaction_notifier.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  bool _flagDialogShown = false;
  bool _isStartingChat = false;
  String? _trackedHistoryProductId;
  int _galleryIndex = 0;
  final TextEditingController _tokenAmountController = TextEditingController();
  final TextEditingController _bidAmountController = TextEditingController();
  final TextEditingController _offerAmountController = TextEditingController();
  final TextEditingController _reviewRatingController = TextEditingController();
  final TextEditingController _reviewCommentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productDetailNotifierProvider.notifier).fetch(widget.productId);
      ref
          .read(reviewNotifierProvider.notifier)
          .fetchByProduct(widget.productId);
    });
  }

  @override
  void dispose() {
    _tokenAmountController.dispose();
    _bidAmountController.dispose();
    _offerAmountController.dispose();
    _reviewRatingController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  Future<void> _startChatWithOwner(
    ProductEntity product,
    String? currentUserId,
  ) async {
    final buyerId = currentUserId?.trim();
    final sellerId = product.sellerId?.trim();

    if (buyerId == null || buyerId.isEmpty) {
      SnackbarUtils.showWarning(
        context,
        'Please sign in before starting a chat with the owner.',
      );
      return;
    }

    if (sellerId == null || sellerId.isEmpty) {
      SnackbarUtils.showWarning(
        context,
        'Owner information is unavailable for this listing.',
      );
      return;
    }

    if (buyerId == sellerId) {
      SnackbarUtils.showInfo(
        context,
        'This is your own listing. Use the chats inbox to continue existing conversations.',
      );
      return;
    }

    if (_isStartingChat) {
      return;
    }

    setState(() {
      _isStartingChat = true;
    });

    try {
      final datasource = ref.read(chatRemoteDatasourceProvider);
      final chat = await datasource.createChat(<String, dynamic>{
        'buyerId': buyerId,
        'sellerId': sellerId,
        'productId': product.id,
      });

      final chatId = chat['chatId']?.toString() ?? chat['id']?.toString() ?? '';
      if (chatId.isEmpty) {
        throw Exception('Chat id was not returned by the server.');
      }

      if (!mounted) {
        return;
      }

      AppRoutes.push(
        context,
        ChatDetailPage(chatId: chatId, title: product.title),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      SnackbarUtils.showWarning(
        context,
        'Unable to start chat with owner: $error',
      );
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isStartingChat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailNotifierProvider);
    final localState = ref.watch(localProductNotifierProvider);
    final transactionState = ref.watch(transactionNotifierProvider);
    final bidState = ref.watch(bidNotifierProvider);
    final offerState = ref.watch(offerNotifierProvider);
    final reviewState = ref.watch(reviewNotifierProvider);
    final sessionState = ref.watch(appSessionProvider);
    final scopedTransaction =
      transactionState.transaction?.productId == widget.productId
      ? transactionState.transaction
      : null;
    final scopedEscrowVisualState = scopedTransaction == null
      ? 'pending'
      : transactionState.escrowVisualState;
    final scopedCompletionAnimation =
      scopedTransaction != null && transactionState.showCompletionAnimation;

    final product = state.product;
    if (state.status == AsyncStatus.success &&
        product != null &&
        product.flagged &&
        !_flagDialogShown) {
      _flagDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Flagged Product'),
            content: const Text(
              'This listing has been flagged and may require additional verification.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }

    if (state.status == AsyncStatus.success &&
        product != null &&
        product.id != _trackedHistoryProductId) {
      _trackedHistoryProductId = product.id;
      ref
          .read(localProductNotifierProvider.notifier)
          .addRecentlyViewed(product);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            tooltip: 'Toggle bookmark for this product',
            icon: Icon(
              product != null &&
                      localState.bookmarkedProductIds.contains(product.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: product == null
                ? null
                : () {
                    ref
                        .read(localProductNotifierProvider.notifier)
                        .toggleBookmark(product.id);
                  },
          ),
          IconButton(
            tooltip: 'Copy product share text',
            icon: const Icon(Icons.share_outlined),
            onPressed: product == null
                ? null
                : () async {
                    final shareText =
                        'Check this listing on NeoBazaar: ${product.title} (id: ${product.id})';
                    await Clipboard.setData(ClipboardData(text: shareText));
                    if (!mounted) {
                      return;
                    }
                    SnackbarUtils.showInfo(
                      this.context,
                      'Share text copied to clipboard',
                    );
                  },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.status == AsyncStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AsyncStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Failed to load product details'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(productDetailNotifierProvider.notifier).retry();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          final confidence = (product.aiConfidence ?? 0)
              .toDouble()
              .clamp(0, 1)
              .toDouble();
          final galleryImages = product.imageUrls.isNotEmpty
              ? product.imageUrls
              : const <String>['', '', ''];
          final isCompared = localState.compareShortlist.any(
            (item) => item.id == product.id,
          );
          final productMode = (product.mode ?? '').toLowerCase();
          final isAuction = productMode == 'auction';
          final isBuyNow = productMode == 'buy_now';
          final modeLabel = isAuction
              ? 'Auction'
              : isBuyNow
              ? 'Buy Now'
              : productMode == 'donate'
              ? 'Donate'
              : 'Other';
            final currentUserId = sessionState.user?.authId?.trim();
            final sellerId = product.sellerId?.trim();
            final canMessageOwner =
              currentUserId != null &&
              currentUserId.isNotEmpty &&
              sellerId != null &&
              sellerId.isNotEmpty &&
              currentUserId != sellerId;
            final messageOwnerHint = currentUserId == null || currentUserId.isEmpty
              ? 'Sign in to chat with listing owner.'
              : sellerId == null || sellerId.isEmpty
              ? 'Owner information is missing for this listing.'
              : currentUserId == sellerId
              ? 'This is your own listing.'
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    itemCount: galleryImages.length,
                    onPageChanged: (value) {
                      setState(() {
                        _galleryIndex = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = galleryImages[index];
                      final normalized = imageUrl.trim();
                      if (imageUrl.isEmpty) {
                        return const ColoredBox(
                          color: Colors.black12,
                          child: Center(child: Icon(Icons.image_outlined)),
                        );
                      }
                      final isSvg = normalized.toLowerCase().endsWith('.svg');
                      final isRemote =
                          normalized.startsWith('http://') ||
                          normalized.startsWith('https://');
                      final isLocalFilePath =
                          normalized.startsWith('/') ||
                          normalized.startsWith('file://');

                      return isRemote
                          ? (isSvg
                                ? SvgPicture.network(
                                    normalized,
                                    fit: BoxFit.cover,
                                    placeholderBuilder: (_) => const ColoredBox(
                                      color: Colors.black12,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    normalized,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const ColoredBox(
                                          color: Colors.black12,
                                          child: Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                        ),
                                  ))
                          : (isLocalFilePath && !isSvg
                                ? Image.file(
                                    File(
                                      normalized.startsWith('file://')
                                          ? Uri.parse(normalized).toFilePath()
                                          : normalized,
                                    ),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const ColoredBox(
                                          color: Colors.black12,
                                          child: Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                            ),
                                          ),
                                        ),
                                  )
                                : (isSvg
                                      ? SvgPicture.asset(
                                          normalized,
                                          fit: BoxFit.cover,
                                          placeholderBuilder: (_) =>
                                              const ColoredBox(
                                                color: Colors.black12,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                        )
                                      : Image.asset(
                                          normalized,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const ColoredBox(
                                                color: Colors.black12,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                ),
                                              ),
                                        )));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  galleryImages.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _galleryIndex
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black26,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Rs. ${product.price}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Owner',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: canMessageOwner && !_isStartingChat
                              ? () => _startChatWithOwner(product, currentUserId)
                              : null,
                          icon: _isStartingChat
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.chat_bubble_outline),
                          label: Text(
                            _isStartingChat
                                ? 'Starting chat...'
                                : 'Message Owner',
                          ),
                        ),
                      ),
                      if (messageOwnerHint != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          messageOwnerHint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!isAuction)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBuyNow
                              ? 'Buy Now Transaction'
                              : 'Escrow Transaction',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        if (!isBuyNow)
                          TextField(
                            controller: _tokenAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Token amount',
                              hintText: 'Enter amount',
                              semanticCounterText: 'Escrow token amount input',
                            ),
                          )
                        else
                          Text('Fixed listing price: Rs. ${product.price}'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed:
                              transactionState.createStatus ==
                                  AsyncStatus.loading
                              ? null
                              : () {
                                  final amount = isBuyNow
                                      ? product.price
                                      : num.tryParse(
                                          _tokenAmountController.text,
                                        );
                                  if (amount == null || amount <= 0) {
                                    SnackbarUtils.showWarning(
                                      context,
                                      'Please enter a valid token amount',
                                    );
                                    return;
                                  }

                                  ref
                                      .read(
                                        transactionNotifierProvider.notifier,
                                      )
                                      .create(
                                        productId: product.id,
                                        amount: amount,
                                      );
                                },
                          child: Text(
                            transactionState.createStatus == AsyncStatus.loading
                                ? 'Creating transaction...'
                                : 'Create Escrow Transaction',
                          ),
                        ),
                        if (transactionState.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            transactionState.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Escrow state: $scopedEscrowVisualState',
                        ),
                        if (scopedTransaction != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed:
                                      transactionState.confirmStatus ==
                                              AsyncStatus.loading ||
                                          scopedTransaction.buyerConfirmed
                                      ? null
                                      : () {
                                          ref
                                              .read(
                                                transactionNotifierProvider
                                                    .notifier,
                                              )
                                              .confirm(actor: 'buyer');
                                        },
                                  child: Text(
                                    scopedTransaction.buyerConfirmed
                                        ? 'Buyer Confirmed'
                                        : 'Buyer Confirm',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (scopedTransaction.sellerId != null)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        transactionState.confirmStatus ==
                                                AsyncStatus.loading ||
                                            scopedTransaction.sellerConfirmed
                                        ? null
                                        : () {
                                            ref
                                                .read(
                                                  transactionNotifierProvider
                                                      .notifier,
                                                )
                                                .confirm(actor: 'seller');
                                          },
                                    child: Text(
                                      scopedTransaction.sellerConfirmed
                                          ? 'Seller Confirmed'
                                          : 'Seller Confirm',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 450),
                          margin: const EdgeInsets.only(top: 10),
                          height: scopedCompletionAnimation
                              ? 52
                              : 0,
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                            child: scopedCompletionAnimation
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Transaction Completed (Dual Confirm)',
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              if (!isAuction) const SizedBox(height: 12),
              if (isAuction)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auction Bid',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Live highest bid: ${bidState.highestBid}'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bidAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Your bid amount',
                            semanticCounterText: 'Auction bid amount input',
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed:
                              bidState.placeBidStatus == AsyncStatus.loading
                              ? null
                              : () {
                                  final amount = num.tryParse(
                                    _bidAmountController.text,
                                  );
                                  if (amount == null ||
                                      amount <= bidState.highestBid) {
                                    SnackbarUtils.showWarning(
                                      context,
                                      'Bid must be greater than highest bid',
                                    );
                                    return;
                                  }
                                  ref
                                      .read(bidNotifierProvider.notifier)
                                      .placeBid(
                                        productId: product.id,
                                        amount: amount,
                                      );
                                },
                          child: Text(
                            bidState.placeBidStatus == AsyncStatus.loading
                                ? 'Placing bid...'
                                : 'Place Bid',
                          ),
                        ),
                        if (bidState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              bidState.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              if (isAuction) const SizedBox(height: 12),
              if (!isAuction)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offers',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _offerAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Offer amount',
                            semanticCounterText: 'Offer amount input',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    offerState.createStatus ==
                                        AsyncStatus.loading
                                    ? null
                                    : () {
                                        final amount = num.tryParse(
                                          _offerAmountController.text,
                                        );
                                        if (amount == null || amount <= 0) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please enter a valid offer amount',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        ref
                                            .read(
                                              offerNotifierProvider.notifier,
                                            )
                                            .create(
                                              productId: product.id,
                                              amount: amount,
                                            );
                                      },
                                child: Text(
                                  offerState.createStatus == AsyncStatus.loading
                                      ? 'Creating offer...'
                                      : 'Create Offer',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {
                                AppRoutes.push(
                                  context,
                                  const OffersInboxPage(),
                                );
                              },
                              style: OutlinedButton.styleFrom(),
                              child: const Text('Open Inbox'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (!isAuction) const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit Review',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reviewRatingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rating (1-5)',
                          semanticCounterText: 'Review rating input',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reviewCommentController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Comment',
                          semanticCounterText: 'Review comment input',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final activeTxn = transactionState.transaction;
                          if (activeTxn == null ||
                              activeTxn.status != 'completed') {
                            SnackbarUtils.showInfo(
                              context,
                              'Complete a transaction first before submitting a review.',
                            );
                            return;
                          }

                          final currentUserId = sessionState.user?.authId
                              ?.trim();
                          final buyerId = activeTxn.buyerId?.trim();
                          final sellerId = activeTxn.sellerId?.trim();
                          final revieweeId =
                              currentUserId != null &&
                                  buyerId != null &&
                                  currentUserId == buyerId
                              ? sellerId
                              : buyerId;
                          if (revieweeId == null || revieweeId.isEmpty) {
                            SnackbarUtils.showWarning(
                              context,
                              'Unable to identify review target for this transaction.',
                            );
                            return;
                          }

                          final rating =
                              int.tryParse(
                                _reviewRatingController.text.trim(),
                              ) ??
                              0;
                          if (rating < 1 || rating > 5) {
                            SnackbarUtils.showWarning(
                              context,
                              'Rating should be between 1 and 5',
                            );
                            return;
                          }
                          ref
                              .read(reviewNotifierProvider.notifier)
                              .create(
                                transactionId: activeTxn.id,
                                productId: product.id,
                                revieweeId: revieweeId,
                                rating: rating,
                                comment: _reviewCommentController.text.trim(),
                              );
                        },
                        child: const Text('Submit Review'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Product Reviews',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (reviewState.status == AsyncStatus.loading)
                const CircularProgressIndicator()
              else if (reviewState.reviews.isEmpty)
                const Text('No reviews yet.')
              else
                ...reviewState.reviews.map(
                  (review) => Card(
                    child: ListTile(
                      title: Text('Rating: ${review.rating}/5'),
                      subtitle: Text(review.comment),
                      trailing: TextButton(
                        onPressed: review.flagged
                            ? null
                            : () {
                                ref
                                    .read(reviewNotifierProvider.notifier)
                                    .flag(review.id);
                              },
                        child: Text(review.flagged ? 'Flagged' : 'Flag'),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  ref
                      .read(localProductNotifierProvider.notifier)
                      .toggleCompare(product);
                },
                iconAlignment: IconAlignment.start,
                icon: Icon(isCompared ? Icons.balance : Icons.balance_outlined),
                label: Text(
                  isCompared ? 'Remove from Compare' : 'Add to Compare',
                ),
              ),
              const SizedBox(height: 8),
              if (product.aiVerified)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'AI Verified',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              if (product.aiVerified) const SizedBox(height: 8),
              if (product.category != null)
                Text('Category: ${product.category}'),
              if (product.location != null)
                Text('Location: ${product.location}'),
              Text('Mode: $modeLabel'),
              const SizedBox(height: 12),
              if (product.aiSuggestedPrice != null)
                Text('AI Suggested Price: Rs. ${product.aiSuggestedPrice}'),
              if (product.aiCondition != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('AI Condition: ${product.aiCondition}'),
                ),
              if (product.aiConfidence != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: confidence),
                    ],
                  ),
                ),
              if (product.aiSuggestedPrice != null ||
                  product.aiCondition != null ||
                  product.aiConfidence != null)
                const SizedBox(height: 12),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
