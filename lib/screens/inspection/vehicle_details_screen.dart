import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../controllers/inspection_setup_controller.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../models/vehicle_model.dart';
import '../../themes/inspection_colors.dart';
import '../widgets/error_widget.dart';

const _transmissions = ['Manual', 'Automatic', 'CVT', 'AMT', 'DCT'];

class VehicleDetailsScreen extends ConsumerStatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  VehicleBrand? _brand;
  VehicleModel? _model;
  String? _transmission = 'Manual';
  final _year = TextEditingController();
  final _variant = TextEditingController();
  final _colour = TextEditingController();

  @override
  void dispose() {
    _year.dispose();
    _variant.dispose();
    _colour.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_brand == null || _model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both make and model'),
          backgroundColor: InspectionColors.flashAmber,
        ),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
    if (!mounted) return;
    if (ok) {
      context.goNamed(RouteNames.inspection);
    } else {
      final error = ref.read(inspectionSetupControllerProvider).error;
      _showErrorDialog(error);
    }
  }

  void _showErrorDialog(String? error) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: InspectionColors.surface,
        title: Text('Error', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
        content: Text(
          error ?? 'Failed to start inspection',
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(vehicleCatalogProvider);
    final setup = ref.watch(inspectionSetupControllerProvider);

    return Scaffold(
      backgroundColor: InspectionColors.scaffold,
      appBar: AppBar(
        backgroundColor: InspectionColors.surface,
        elevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: InspectionColors.accent),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Vehicle Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: switch (catalogAsync) {
          AsyncData(:final value) => _form(value, setup, loading: false),
          AsyncLoading() => _form(
              const (models: <VehicleModel>[], brands: <VehicleBrand>[]),
              setup,
              loading: true,
            ),
          AsyncError(:final error) => ErrorDisplayWidget(
              message: '$error',
              onRetry: () => ref.invalidate(vehicleCatalogProvider),
            ),
        },
      ),
    );
  }

  Widget _form(VehicleCatalog catalog, SetupState setup, {required bool loading}) {
    final models = catalog.models.where((m) => m.brandId == _brand?.id).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final modelHint = _brand == null
        ? 'Select a make first'
        : models.isEmpty
            ? 'No models available'
            : 'Select Model';

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FadeAnimation(delay: 1.0, child: _HeaderCard()),
            SizedBox(height: 32.h),
            _FadeAnimation(
              delay: 1.2,
              child: _FormCard(
                children: [
                  _BrandDropdown(
                    value: _brand,
                    items: catalog.brands,
                    loading: loading,
                    onChanged: loading
                        ? null
                        : (b) => setState(() {
                              _brand = b;
                              _model = null;
                            }),
                  ),
                  _ModelDropdown(
                    value: _model,
                    items: models,
                    hint: modelHint,
                    onChanged: (_brand == null || loading)
                        ? null
                        : (m) => setState(() => _model = m),
                  ),
                  _VehicleTextField(
                    controller: _year,
                    label: 'Year',
                    hint: 'e.g., 2020',
                    prefixIcon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: _validateYear,
                  ),
                  _VehicleTextField(
                    controller: _variant,
                    label: 'Variant',
                    hint: 'e.g., LX, EX, SE (Optional)',
                    prefixIcon: Icons.tune,
                    inputFormatters: [_uppercaseFormatter],
                  ),
                  _VehicleTextField(
                    controller: _colour,
                    label: 'Colour',
                    hint: 'e.g., White, Black, Silver',
                    prefixIcon: Icons.color_lens,
                    inputFormatters: [_uppercaseFormatter],
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter vehicle colour'
                        : null,
                  ),
                  _TransmissionDropdown(
                    value: _transmission,
                    onChanged: (t) => setState(() => _transmission = t),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            _FadeAnimation(
              delay: 1.4,
              child: _StartButton(
                isLoading: setup.isLoading,
                onPressed: setup.isLoading ? null : _continue,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  String? _validateYear(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter vehicle year';
    final year = int.tryParse(text);
    final maxYear = DateTime.now().year + 1;
    if (year == null || year < 1900 || year > maxYear) {
      return 'Please enter a valid year';
    }
    return null;
  }
}

final _uppercaseFormatter = TextInputFormatter.withFunction((oldV, newV) {
  return newV.copyWith(text: newV.text.toUpperCase());
});

/// Simple opacity + translateY entry animation. [delay] x 500ms = start delay.
class _FadeAnimation extends StatefulWidget {
  const _FadeAnimation({required this.delay, required this.child});

  final double delay;
  final Widget child;

  @override
  State<_FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<_FadeAnimation> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      Duration(milliseconds: (widget.delay * 500).round()),
      () {
        if (mounted) setState(() => _visible = true);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, -0.15),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: InspectionColors.headerGradient,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: InspectionColors.headerGradient.first.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car, size: 48.r, color: Colors.white),
          SizedBox(height: 16.h),
          Text(
            'Enter Vehicle Information',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please provide the vehicle details to begin inspection',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: InspectionColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String label,
  required IconData prefixIcon,
  String? hint,
  bool withErrorBorders = true,
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(prefixIcon, color: InspectionColors.accent),
    filled: true,
    fillColor: InspectionColors.fill,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    border: border(Colors.grey.shade700, 1),
    enabledBorder: border(Colors.grey.shade700, 1),
    focusedBorder: border(InspectionColors.accent, 2),
    errorBorder: withErrorBorders ? border(Colors.red, 2) : null,
    focusedErrorBorder: withErrorBorders ? border(Colors.red, 2) : null,
  );
}

class _BrandDropdown extends StatelessWidget {
  const _BrandDropdown({
    required this.value,
    required this.items,
    required this.loading,
    required this.onChanged,
  });

  final VehicleBrand? value;
  final List<VehicleBrand> items;
  final bool loading;
  final ValueChanged<VehicleBrand?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: DropdownButtonFormField<VehicleBrand>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: InspectionColors.fill,
        style: TextStyle(fontSize: 16.sp, color: Colors.white),
        hint: Text(loading ? 'Loading...' : 'Select Make'),
        decoration: _fieldDecoration(label: 'Make', prefixIcon: Icons.business),
        items: items
            .map((b) => DropdownMenuItem<VehicleBrand>(
                  value: b,
                  child: Text(b.name),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select a make' : null,
      ),
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
  });

  final VehicleModel? value;
  final List<VehicleModel> items;
  final String hint;
  final ValueChanged<VehicleModel?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: DropdownButtonFormField<VehicleModel>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: InspectionColors.fill,
        style: TextStyle(fontSize: 16.sp, color: Colors.white),
        hint: Text(hint),
        decoration:
            _fieldDecoration(label: 'Model', prefixIcon: Icons.car_rental),
        items: items
            .map((m) => DropdownMenuItem<VehicleModel>(
                  value: m,
                  child: Text(m.name),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select a model' : null,
      ),
    );
  }
}

class _TransmissionDropdown extends StatelessWidget {
  const _TransmissionDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: InspectionColors.fill,
        style: TextStyle(fontSize: 16.sp, color: Colors.white),
        decoration: _fieldDecoration(
          label: 'Transmission',
          prefixIcon: Icons.settings,
          withErrorBorders: false,
        ),
        items: _transmissions
            .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select transmission type' : null,
      ),
    );
  }
}

class _VehicleTextField extends StatelessWidget {
  const _VehicleTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(fontSize: 16.sp, color: Colors.white),
        decoration: _fieldDecoration(
          label: label,
          hint: hint,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: InspectionColors.startGradient,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: InspectionColors.startGradient.first.withValues(alpha: 0.3),
            blurRadius: 15.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 24.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Start Inspection',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
