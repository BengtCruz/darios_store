import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(s.supportPageTitle),
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  s.supportPageTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  s.supportPageSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 40),

              // FAQ section
              Text(
                s.supportFaqTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              _FaqItem(
                question: s.supportFaq1Q,
                answer: s.supportFaq1A,
              ),
              _FaqItem(
                question: s.supportFaq2Q,
                answer: s.supportFaq2A,
              ),
              _FaqItem(
                question: s.supportFaq3Q,
                answer: s.supportFaq3A,
              ),

              const Divider(height: 48),

              // Contact section
              Text(
                s.supportContactTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              _ContactRow(icon: Icons.email_outlined, text: s.supportEmail),
              const SizedBox(height: 12),
              _ContactRow(icon: Icons.phone_outlined, text: s.supportPhone),
              const SizedBox(height: 12),
              _ContactRow(icon: Icons.access_time, text: s.supportHours),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.nero,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        const Divider(height: 0),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.nero),
        const SizedBox(width: 12),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
