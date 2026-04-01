import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _api = ApiClient();
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.getDashboard();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossibile connettersi al server.\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Panoramica del negozio',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: AppTheme.nero))
              else if (_error != null)
                _buildError()
              else
                _buildStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.cloud_off, size: 64, color: AppTheme.grigio),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            child: const Text('RIPROVA'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final products = _data!['products'] as Map<String, dynamic>? ?? {};
    final categories = _data!['categories'] as Map<String, dynamic>? ?? {};
    final orders = _data!['orders'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              title: 'Prodotti Totali',
              value: '${products['total'] ?? 0}',
              icon: Icons.inventory_2_outlined,
            ),
            _StatCard(
              title: 'Prodotti Attivi',
              value: '${products['active'] ?? 0}',
              icon: Icons.check_circle_outline,
            ),
            _StatCard(
              title: 'Categorie',
              value: '${categories['total'] ?? 0}',
              icon: Icons.category_outlined,
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text('Ordini per Stato', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              title: 'In Attesa',
              value: '${orders['pending'] ?? 0}',
              icon: Icons.hourglass_empty,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Confermati',
              value: '${orders['confirmed'] ?? 0}',
              icon: Icons.thumb_up_outlined,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Spediti',
              value: '${orders['shipped'] ?? 0}',
              icon: Icons.local_shipping_outlined,
              color: Colors.purple,
            ),
            _StatCard(
              title: 'Consegnati',
              value: '${orders['delivered'] ?? 0}',
              icon: Icons.done_all,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Cancellati',
              value: '${orders['cancelled'] ?? 0}',
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Quick actions
        Text('Azioni Rapide', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('AGGIORNA DATI'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grigioChiaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color ?? AppTheme.nero),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: color ?? AppTheme.nero,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
