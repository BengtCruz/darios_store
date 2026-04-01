import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isWide(context)) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppTheme.nero,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DARIO'S STORE",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.bianco,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Authentic Italian flavors,\ndelivered to your door.',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: AppTheme.grigio,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Links columns
                  Expanded(
                    child: _footerColumn(context, 'NEGOZIO', [
                      'Catalogo',
                      'In Vetrina',
                      'Novità',
                      'Offerte',
                    ]),
                  ),
                  Expanded(
                    child: _footerColumn(context, 'INFORMAZIONI', [
                      'Chi Siamo',
                      'Contatti',
                      'Spedizioni',
                      'Resi',
                    ]),
                  ),
                  Expanded(
                    child: _footerColumn(context, 'ASSISTENZA', [
                      'FAQ',
                      'Termini & Condizioni',
                      'Privacy Policy',
                      'Cookie Policy',
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Divider(color: AppTheme.accent, thickness: 0.5),
              const SizedBox(height: 16),
              Text(
                "© 2026 Dario's Store. Tutti i diritti riservati.",
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: AppTheme.grigio,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerColumn(
      BuildContext context, String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.bianco,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                link,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: AppTheme.grigio,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
