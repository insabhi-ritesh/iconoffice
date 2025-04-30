// import 'package:flutter/material.dart';

// class PaginationController {
//   final ScrollController scrollController;
//   final Function onScrollEnd;

//   PaginationController({
//     required this.scrollController,
//     required this.onScrollEnd,
//   }) {
//     scrollController.addListener(_scrollListener);
//   }

//   void _scrollListener() {
//     if (scrollController.position.pixels ==
//             scrollController.position.maxScrollExtent &&
//         !scrollController.position.outOfRange) {
//       onScrollEnd();
//     }
//   }

//   void dispose() {
//     scrollController.dispose();
//   }
// }




import 'package:flutter/material.dart';

/// A controller to handle infinite scroll pagination.
/// 
/// Usage:
///   - Pass a [ScrollController] and a callback to [onScrollEnd].
///   - The callback is triggered when the user scrolls to the bottom.
///   - Optionally, let this controller manage the [ScrollController]'s disposal.
class PaginationController {
  final ScrollController scrollController;
  final VoidCallback onScrollEnd;
  final bool autoDispose;

  PaginationController({
    required this.scrollController,
    required this.onScrollEnd,
    this.autoDispose = false,
  }) {
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Use >= for robustness due to floating point precision.
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      onScrollEnd();
    }
  }

  void dispose() {
    scrollController.removeListener(_scrollListener);
    if (autoDispose) {
      scrollController.dispose();
    }
  }
}
