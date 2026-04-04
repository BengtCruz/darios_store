import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show apiClient;
import '../models/address.dart';
import '../theme/app_theme.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  List<Address> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await apiClient.getAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = data.map((j) => Address.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.addressDeleteConfirm),
        content: Text(s.addressDeleteMessage(address.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await apiClient.deleteAddress(address.id);
      if (!mounted) return;
      setState(() {
        _addresses.removeWhere((a) => a.id == address.id);
      });
    } catch (_) {}
  }

  Future<void> _setDefault(Address address) async {
    try {
      await apiClient.updateAddress(address.id, {'isDefault': true});
      await _load();
    } catch (_) {}
  }

  void _openForm({Address? address}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _AddressFormPage(address: address),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.brandName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.nero))
          : _addresses.isEmpty
              ? _buildEmptyState(context, s)
              : _buildContent(context, s),
      floatingActionButton: !_loading
          ? FloatingActionButton(
              onPressed: () => _openForm(),
              backgroundColor: AppTheme.nero,
              child: const Icon(Icons.add, color: AppTheme.bianco),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, S s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_outlined, size: 64, color: AppTheme.grigioChiaro),
          const SizedBox(height: 16),
          Text(
            s.addressEmpty,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            s.addressEmptyDesc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => _openForm(),
            child: Text(s.addressAdd),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, S s) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                s.addressTitle.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 3,
                    ),
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _addresses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  return _AddressCard(
                    address: address,
                    onEdit: () => _openForm(address: address),
                    onDelete: () => _deleteAddress(address),
                    onSetDefault: () => _setDefault(address),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            address.label.toLowerCase() == 'work'
                ? Icons.work_outline
                : Icons.home_outlined,
            size: 24,
            color: AppTheme.nero,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.nero,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          s.addressDefault.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.bianco,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  address.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  address.formattedAddress,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
                if (address.phone != null && address.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    address.phone!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _actionButton(context, s.edit, onEdit),
                    const SizedBox(width: 16),
                    _actionButton(context, s.delete, onDelete, color: Colors.red),
                    if (!address.isDefault) ...[
                      const SizedBox(width: 16),
                      _actionButton(context, s.addressSetDefault, onSetDefault),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
                color: color,
                fontSize: 13,
              ),
        ),
      ),
    );
  }
}

class _AddressFormPage extends StatefulWidget {
  final Address? address;
  const _AddressFormPage({this.address});

  @override
  State<_AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<_AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _street2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _phoneCtrl;
  late bool _isDefault;
  bool _saving = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _labelCtrl = TextEditingController(text: a?.label ?? 'Home');
    _nameCtrl = TextEditingController(text: a?.fullName ?? '');
    _streetCtrl = TextEditingController(text: a?.street ?? '');
    _street2Ctrl = TextEditingController(text: a?.street2 ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _postalCtrl = TextEditingController(text: a?.postalCode ?? '');
    _countryCtrl = TextEditingController(text: a?.country ?? 'Sweden');
    _phoneCtrl = TextEditingController(text: a?.phone ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _nameCtrl.dispose();
    _streetCtrl.dispose();
    _street2Ctrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _countryCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'label': _labelCtrl.text.trim(),
      'fullName': _nameCtrl.text.trim(),
      'street': _streetCtrl.text.trim(),
      if (_street2Ctrl.text.trim().isNotEmpty) 'street2': _street2Ctrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'postalCode': _postalCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      'isDefault': _isDefault,
    };

    try {
      if (_isEditing) {
        await apiClient.updateAddress(widget.address!.id, data);
      } else {
        await apiClient.createAddress(data);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? s.addressEditTitle : s.addressNewTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (_isEditing ? s.addressEditTitle : s.addressNewTitle).toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 3,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Label
                  _buildField(
                    controller: _labelCtrl,
                    label: s.addressLabel,
                    hint: 'Home, Work, etc.',
                  ),
                  const SizedBox(height: 16),

                  // Full name
                  _buildField(
                    controller: _nameCtrl,
                    label: s.addressFullName,
                    required: true,
                  ),
                  const SizedBox(height: 16),

                  // Street
                  _buildField(
                    controller: _streetCtrl,
                    label: s.addressStreet,
                    required: true,
                  ),
                  const SizedBox(height: 16),

                  // Street 2
                  _buildField(
                    controller: _street2Ctrl,
                    label: s.addressStreet2,
                  ),
                  const SizedBox(height: 16),

                  // City + Postal in a row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildField(
                          controller: _cityCtrl,
                          label: s.addressCity,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          controller: _postalCtrl,
                          label: s.addressPostalCode,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Country
                  _buildField(
                    controller: _countryCtrl,
                    label: s.addressCountry,
                    required: true,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  _buildField(
                    controller: _phoneCtrl,
                    label: s.addressPhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Default toggle
                  Row(
                    children: [
                      Checkbox(
                        value: _isDefault,
                        onChanged: (v) => setState(() => _isDefault = v ?? false),
                        activeColor: AppTheme.nero,
                      ),
                      Text(
                        s.addressSetAsDefault,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving
                          ? '...'
                          : _isEditing
                              ? s.save
                              : s.addressAdd),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodyMedium,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppTheme.grigioChiaro, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppTheme.nero, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    String? hint,
    TextInputType? keyboardType,
  }) {
    final s = S.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: _inputDecoration(label).copyWith(hintText: hint),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? s.authFieldRequired : null
          : null,
    );
  }
}
