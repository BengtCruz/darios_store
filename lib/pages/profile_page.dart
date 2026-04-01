import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'admin/admin_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.nero, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person_outline, size: 48, color: AppTheme.nero),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Benvenuto',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Accedi per gestire i tuoi ordini',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('ACCEDI'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('CREA ACCOUNT'),
            ),
          ),

          const Divider(height: 48),

          // Menu items
          _buildMenuItem(context, Icons.shopping_bag_outlined, 'I Miei Ordini'),
          _buildMenuItem(context, Icons.favorite_outline, 'Lista Desideri'),
          _buildMenuItem(context, Icons.location_on_outlined, 'Indirizzi'),
          _buildMenuItem(context, Icons.payment_outlined, 'Metodi di Pagamento'),
          _buildMenuItem(context, Icons.notifications_outlined, 'Notifiche'),
          _buildMenuItem(context, Icons.help_outline, 'Assistenza'),
          _buildMenuItem(context, Icons.info_outline, 'Chi Siamo'),

          const Divider(height: 32),

          // Admin panel link
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminShell()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.nero),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 20, color: AppTheme.nero),
                  SizedBox(width: 8),
                  Text(
                    'PANNELLO AMMINISTRAZIONE',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 32),

          // App info
          Text(
            "DARIO'S STORE v1.0.0",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 20),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.nero),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.grigio),
          ],
        ),
      ),
    );
  }
}
