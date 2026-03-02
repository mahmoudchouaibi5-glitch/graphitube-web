import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphitube_app/constants/app_links.dart';
import 'package:graphitube_app/providers/salon_order_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SalonOrderStep2Screen extends ConsumerWidget {
  const SalonOrderStep2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(salonOrderProvider);
    final orderNotifier = ref.read(salonOrderProvider.notifier);
    final isSalonTypeSelected = orderState.selectedSalonType != null;

    return Scaffold(
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
            onPressed: () => context.pop(),
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
            _buildSalonTypeCard(context, orderState, orderNotifier),
            const SizedBox(height: 20),
            _buildWhatsappInfoBox(),
          ],
        ),
      ),
       bottomNavigationBar: Padding(
         padding: const EdgeInsets.all(16.0),
         child: _buildNavigationButtons(context, isSalonTypeSelected),
       ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('25%', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            Text('الخطوة 2 من 8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            value: 0.25,
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
      children: steps.asMap().entries.map((entry) {
        final int index = entry.key;
        final String step = entry.value;
        final bool isCompleted = index < 1;
        final bool isActive = index == 1;

        Color labelColor = Colors.black54;
        Color bgColor = Colors.grey.shade200;
        BorderSide borderSide = BorderSide.none;
        Widget? avatar;

        if (isCompleted) {
          labelColor = Colors.green;
          bgColor = Colors.green.withOpacity(0.1);
          borderSide = const BorderSide(color: Colors.green);
          avatar = const Icon(Icons.check, color: Colors.green, size: 16);
        } else if (isActive) {
          labelColor = Colors.blue;
          bgColor = Colors.blue.withOpacity(0.1);
          borderSide = const BorderSide(color: Colors.blue);
        }

        return Chip(
          avatar: avatar,
          label: Text(step, style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.bold)),
          backgroundColor: bgColor,
          shape: StadiumBorder(side: borderSide),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        );
      }).toList(),
    );
  }

  Widget _buildSalonTypeCard(BuildContext context, SalonOrderState orderState, SalonOrderNotifier orderNotifier) {
     final salonTypes = {
      SalonType.lShape: {'label': 'صالون على شكل حرف L', 'icon': Icons.crop_square},
      SalonType.uShape: {'label': 'صالون على شكل حرف U', 'icon': Icons.crop_square},
      SalonType.rectOpen1: {'label': 'صالون مستطيل مفتوح رقم 1', 'icon': Icons.crop_square},
      SalonType.rectOpen2: {'label': 'صالون مستطيل مفتوح رقم 2', 'icon': Icons.crop_square},
      SalonType.custom: {'label': 'تصميم مخصص', 'icon': Icons.upload_file_outlined},
    };

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('نوع الصالون', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
            const SizedBox(height: 8),
            Text('اختر نوع الصالون الذي يناسب مساحتك', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ...salonTypes.entries.map((entry) {
              final type = entry.key;
              final data = entry.value;
              final isSelected = orderState.selectedSalonType == type;
              return _buildSalonTypeOption(
                context: context,
                label: data['label'] as String,
                icon: data['icon'] as IconData,
                isSelected: isSelected,
                onTap: () => orderNotifier.setSalonType(type),
              );
            }).expand((widget) => [widget, const SizedBox(height: 14)]).toList()..removeLast(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalonTypeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.orange : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(icon, size: 48, color: Colors.grey.shade600),
                    const SizedBox(height: 12),
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: -30,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orange,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, bool isEnabled) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isEnabled
                ? () => context.push('/salon/step3')
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('اختر نوع الصالون أولاً'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
            label: const Text('التالي', style: TextStyle(fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.arrow_back, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled ? Colors.orange : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () => context.go('/salon/step1'),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
