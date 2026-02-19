import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();

  int _remainingChars = 500;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();

    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback'),
          backgroundColor: Color(0xFFD84A4A), // Readable red
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await _feedbackService.submitFeedback(
        feedbackText: feedback,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Show success and pop back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Color(0xFF4CAF78), // Readable green
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit feedback. Please try again.'),
              backgroundColor: Color(0xFFD84A4A), // Readable red
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFD84A4A), // Readable red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1625),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'We\'d love to hear your thoughts!',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              // Feedback input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2139),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF382a54)),
                ),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: 8,
                  maxLength: 500,
                  onChanged: (text) {
                    setState(() {
                      _remainingChars = 500 - text.length;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'Share your feedback, suggestions, or report issues...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_remainingChars characters remaining',
                style: TextStyle(
                  color: _remainingChars < 50
                      ? const Color(0xFFFF6B6B)
                      : Colors.white38,
                  fontSize: 12,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),
              // Email input (optional)
              const Text(
                'Email (optional)',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2139),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF382a54)),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'your@email.com',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We\'ll only use this to follow up on your feedback',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 32),
              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF6C3FFF).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
