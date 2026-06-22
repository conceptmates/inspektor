import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../controllers/inspection_setup_controller.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../models/vehicle_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

const _transmissions = ['Manual', 'Automatic', 'CVT', 'AMT', 'DCT'];

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  VehicleBrand? _brand;
  VehicleModel? _model;
  String? _transmission;
  final _year = TextEditingController();
  final _variant = TextEditingController();
  final _colour = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _year.dispose();
    _variant.dispose();
    _colour.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_brand == null || _model == null) {
      setState(() => _validationError = 'Select a make and model.');
      return;
    }
    setState(() => _validationError = null);

    final ok = await ref.read(inspectionSetupControllerProvider.notifier).start(
          brandId: _brand!.id,
          modelId: _model!.id,
          year: _year.text.trim().isEmpty ? null : _year.text.trim(),
          variant: _variant.text.trim().isEmpty ? null : _variant.text.trim(),
          colour: _colour.text.trim().isEmpty ? null : _colour.text.trim(),
          transmission: _transmission,
          vehicleDetails: {
            'brand': _brand!.name,
            'model': _model!.name,
            'vehicle_brand_id': _brand!.id,
            'vehicle_model_id': _model!.id,
            'year': _year.text.trim(),
            'variant': _variant.text.trim(),
            'colour': _colour.text.trim(),
            'transmission': _transmission,
          },
        );
    if (ok && mounted) context.goNamed(RouteNames.inspection);
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(vehicleCatalogProvider);
    final setup = ref.watch(inspectionSetupControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details')),
      body: switch (catalogAsync) {
        AsyncData(:final value) => _form(value, setup),
        AsyncError(:final error) => ErrorDisplayWidget(
            message: '$error',
            onRetry: () => ref.invalidate(vehicleCatalogProvider),
          ),
        _ => const LoadingWidget(message: 'Loading vehicles...'),
      },
    );
  }

  Widget _form(VehicleCatalog catalog, SetupState setup) {
    final colors = Theme.of(context).colorScheme;
    final models =
        catalog.models.where((m) => m.brandId == _brand?.id).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Dropdown<VehicleBrand>(
            label: 'Make',
            value: _brand,
            items: catalog.brands,
            itemLabel: (b) => b.name,
            onChanged: (b) => setState(() {
              _brand = b;
              _model = null; // reset dependent
            }),
          ),
          SizedBox(height: 14.w),
          _Dropdown<VehicleModel>(
            label: 'Model',
            value: _model,
            items: models,
            itemLabel: (m) => m.name,
            enabled: _brand != null,
            onChanged: (m) => setState(() => _model = m),
          ),
          SizedBox(height: 14.w),
          CustomTextField(
              controller: _year,
              hintText: 'Year',
              keyboardType: TextInputType.number),
          SizedBox(height: 14.w),
          CustomTextField(controller: _variant, hintText: 'Variant'),
          SizedBox(height: 14.w),
          CustomTextField(controller: _colour, hintText: 'Colour'),
          SizedBox(height: 14.w),
          _Dropdown<String>(
            label: 'Transmission',
            value: _transmission,
            items: _transmissions,
            itemLabel: (t) => t,
            onChanged: (t) => setState(() => _transmission = t),
          ),
          if (_validationError != null || setup.error != null) ...[
            SizedBox(height: 16.w),
            Text(
              _validationError ?? setup.error!,
              style: TextStyle(color: colors.error, fontSize: 13.sp),
            ),
          ],
          SizedBox(height: 28.w),
          CustomButton(
            text: 'Continue',
            isLoading: setup.isLoading,
            onPressed: _continue,
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel(e))))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
