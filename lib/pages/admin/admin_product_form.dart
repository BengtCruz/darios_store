import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

class AdminProductForm extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AdminProductForm({super.key, this.product});

  bool get isEditing => product != null;

  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiClient();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _stockCtrl;
  late bool _isFeatured;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?['name'] as String? ?? '');
    _descCtrl = TextEditingController(text: p?['description'] as String? ?? '');
    _priceCtrl = TextEditingController(
      text: p != null ? (p['price'] as num).toStringAsFixed(2) : '',
    );
    _imageUrlCtrl = TextEditingController(text: p?['imageUrl'] as String? ?? '');
    _categoryCtrl = TextEditingController(text: p?['category'] as String? ?? '');
    _ratingCtrl = TextEditingController(
      text: p != null ? (p['rating'] as num? ?? 0).toString() : '0',
    );
    _stockCtrl = TextEditingController(
      text: p != null ? (p['stock'] as num? ?? 0).toString() : '0',
    );
    _isFeatured = p?['isFeatured'] as bool? ?? false;
    _isActive = p?['isActive'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    _categoryCtrl.dispose();
    _ratingCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()),
      'imageUrl': _imageUrlCtrl.text.trim(),
      'category': _categoryCtrl.text.trim(),
      'rating': double.tryParse(_ratingCtrl.text.trim()) ?? 0,
      'isFeatured': _isFeatured,
      'isActive': _isActive,
      'stock': int.tryParse(_stockCtrl.text.trim()) ?? 0,
    };

    try {
      if (widget.isEditing) {
        await _api.updateProduct(widget.product!['id'] as String, data);
      } else {
        await _api.createProduct(data);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorMessage(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = widget.isEditing ? s.formEditProduct : s.formNewProduct;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 24),

                  _buildField(s.formProductName, _nameCtrl, validator: _required),
                  const SizedBox(height: 16),
                  _buildField(s.formProductDescription, _descCtrl,
                      maxLines: 3, validator: _required),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildField(s.formProductPrice, _priceCtrl,
                            keyboardType: TextInputType.number,
                            validator: _validatePrice),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(s.formProductCategory, _categoryCtrl,
                            validator: _required),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildField(s.formProductImageUrl, _imageUrlCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildField(s.formProductRating, _ratingCtrl,
                            keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildField(s.formProductStock, _stockCtrl,
                      keyboardType: TextInputType.number,
                      validator: _validateStock),
                  const SizedBox(height: 20),

                  // Toggles
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.grigioChiaro),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text(s.formProductActive),
                          subtitle: Text(s.formProductActiveDesc),
                          value: _isActive,
                          activeThumbColor: AppTheme.nero,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: Text(s.formProductFeatured),
                          subtitle:
                              Text(s.formProductFeaturedDesc),
                          value: _isFeatured,
                          activeThumbColor: AppTheme.nero,
                          onChanged: (v) => setState(() => _isFeatured = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: Text(s.cancel),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.bianco,
                                ),
                              )
                            : Text(widget.isEditing ? s.save : s.formCreateProduct),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppTheme.nero, width: 2),
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return S.of(context).formFieldRequired;
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return S.of(context).formFieldRequired;
    if (double.tryParse(value.trim()) == null) return S.of(context).formInvalidPrice;
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) return S.of(context).formFieldRequired;
    final n = int.tryParse(value.trim());
    if (n == null || n < 0) return S.of(context).formInvalidStock;
    return null;
  }
}
