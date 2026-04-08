import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/brand_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/common/loading_widget.dart';

class AdminBrandsScreen extends StatefulWidget {
  const AdminBrandsScreen({super.key});

  @override
  State<AdminBrandsScreen> createState() => _AdminBrandsScreenState();
}

class _AdminBrandsScreenState extends State<AdminBrandsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandProvider>().loadBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageBrands),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBrandForm(context),
          ),
        ],
      ),
      body: Consumer<BrandProvider>(
        builder: (_, provider, __) {
          if (provider.loading) return const LoadingWidget();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.brands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final b = provider.brands[i];
              return Card(
                child: ListTile(
                  title: Text(b.localizedName(locale)),
                  subtitle: Text(
                    '${b.productCount} ${AppStrings.productsCount}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary),
                        onPressed: () => _showBrandForm(context, brand: b),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () =>
                            _confirmDelete(context, b.id, b.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBrandForm(BuildContext context, {dynamic brand}) {
    final nameController = TextEditingController(text: brand?.name ?? '');
    final nameBnController =
        TextEditingController(text: brand?.nameBn ?? '');
    final websiteController =
        TextEditingController(text: brand?.websiteUrl ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              brand == null ? AppStrings.addBrand : AppStrings.editBrand,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: AppStrings.brandNameEn),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameBnController,
              decoration:
                  const InputDecoration(labelText: AppStrings.brandNameBn),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: websiteController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: AppStrings.websiteUrl),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                  brand == null ? AppStrings.addBrand : AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteBrand),
        content: Text('${AppStrings.deleteConfirm} "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<BrandProvider>().deleteBrand(id);
    }
  }
}
