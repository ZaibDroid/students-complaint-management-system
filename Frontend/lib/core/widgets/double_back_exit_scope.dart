import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows an exit confirmation dialog asking the user if they want to exit the app.
Future<bool?> showExitAppDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0x1AFF0000),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.exit_to_app_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Exit App",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to exit the app?",
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "No",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              SystemNavigator.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Yes",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// A reusable component that intercepts the system back press.
/// - If [onBackAttempt] returns true (e.g. switching back to the home tab), exit logic is bypassed.
/// - If the user presses back once at the root, a toast/snackbar prompts "Press back again to exit".
/// - If the user presses back again within [resetDuration] ("double back"), it displays the exit confirmation dialog.
class DoubleBackExitScope extends StatefulWidget {
  final Widget child;

  /// Optional handler called on back press before double-back logic.
  /// Return `true` if the back press was handled (e.g. navigated to home tab).
  final Future<bool> Function()? onBackAttempt;

  /// The time window within which a second back press is considered a double back (default: 2 seconds).
  final Duration resetDuration;

  /// Message displayed in the SnackBar on the first back press.
  final String snackBarMessage;

  const DoubleBackExitScope({
    super.key,
    required this.child,
    this.onBackAttempt,
    this.resetDuration = const Duration(seconds: 2),
    this.snackBarMessage = 'Press back again to exit',
  });

  @override
  State<DoubleBackExitScope> createState() => _DoubleBackExitScopeState();
}

class _DoubleBackExitScopeState extends State<DoubleBackExitScope> {
  DateTime? _lastBackPressTime;
  bool _isDialogOpen = false;

  Future<void> _handleBackPress() async {
    // If exit dialog is already open, do not trigger again
    if (_isDialogOpen) return;

    // Check if navigator itself can pop a sub-route
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    // Check if parent layout handles back (e.g. switching to Home tab)
    if (widget.onBackAttempt != null) {
      final handled = await widget.onBackAttempt!();
      if (handled) return;
    }

    // Double-back check
    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > widget.resetDuration) {
      _lastBackPressTime = now;
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(widget.snackBarMessage),
              ],
            ),
            duration: widget.resetDuration,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      _lastBackPressTime = null;
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _isDialogOpen = true;
        try {
          await showExitAppDialog(context);
        } finally {
          _isDialogOpen = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: widget.child,
    );
  }
}
