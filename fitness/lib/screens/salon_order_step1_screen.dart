
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphitube_app/constants/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

class SalonOrderStep1Screen extends StatefulWidget {
  @override
  _SalonOrderStep1ScreenState createState() => _SalonOrderStep1ScreenState();
}

class _SalonOrderStep1ScreenState extends State<SalonOrderStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: AppLinks.phone);
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      context.go('/salon/step2');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.1),
          centerTitle: true,
          title: SizedBox(
            height: 20,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
               if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined, color: Colors.grey, size: 20),
                label: const Text(
                  'العودة للصفحة الرئيسية',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProgressHeader(),
              const SizedBox(height: 16),
              _buildStepChips(),
              const SizedBox(height: 20),
              _buildContactFormCard(context),
              const SizedBox(height: 20),
              _buildWhatsappInfoBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('13%', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            Text('الخطوة 1 من 8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.13,
            backgroundColor: Colors.black12,
            color: Colors.orange,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStepChips() {
    final steps = [
      'معلومات العميل', 'نوع الصالون', 'نوع الخشب', 'عناصر الخشب',
      'الزخرفة', 'الألوان', 'الأبعاد', 'التأكيد'
    ];
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: steps.map((step) {
        final bool isActive = step == 'معلومات العميل';
        return Chip(
          label: Text(step, style: TextStyle(color: isActive ? Colors.blue : Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
          backgroundColor: isActive ? Colors.blue.withOpacity(0.1) : Colors.grey.shade200,
          shape: StadiumBorder(side: BorderSide(color: isActive ? Colors.blue : Colors.transparent)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        );
      }).toList(),
    );
  }

  Widget _buildContactFormCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('معلومات التواصل', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
              const SizedBox(height: 8),
              Text('املأ بياناتك الشخصية للتواصل معك', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 24),
              _buildTextField(label: 'الاسم الكامل', hint: 'أدخل اسمك الكامل', isRequired: true, controller: _nameController),
              _buildTextField(label: 'رقم الهاتف', hint: AppLinks.phone, keyboardType: TextInputType.phone, controller: _phoneController, isRequired: true),
              _buildTextField(label: 'المدينة', hint: 'الدارالبيضاء, الرباط, مراكش...', keyboardType: TextInputType.text, isRequired: true, controller: _cityController),
              _buildTextField(label: 'العنوان', hint: 'أدخل عنوانك', isRequired: true, controller: _addressController),
              const SizedBox(height: 24),
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black, fontFamily: 'Tajawal'),
              children: [
                if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'هذا الحقل مطلوب';
                }
                return null;
              },
              textAlign: TextAlign.right,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.orange, width: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _validateAndProceed,
            label: const Text('التالي', style: TextStyle(fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.arrow_back, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go('/');
            }
          },
          icon: const Text('رجوع', style: TextStyle(fontWeight: FontWeight.bold)),
          label: const Icon(Icons.arrow_forward, size: 20),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            foregroundColor: Colors.blue,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

   Widget _buildWhatsappInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إذا لم تفهم شيئاً، تواصل معنا عبر واتساب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'تواصل معنا مباشرة عبر الواتساب',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse(AppLinks.whatsapp);
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      // Could not launch the url
                    }
                  },
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text(AppLinks.phone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
