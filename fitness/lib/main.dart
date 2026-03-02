import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphitube_app/screens/salon_order_step1_screen.dart';
import 'package:graphitube_app/screens/salon_order_step2_screen.dart';
import 'package:graphitube_app/widgets/service_card.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

// --- Models ---
enum GrainDirection { horizontal, vertical, any }

class CutItem {
  TextEditingController nameController, lengthController, widthController, qtyController;
  bool edgeTop, edgeBottom, edgeLeft, edgeRight;
  GrainDirection direction;

  CutItem({
    required String name,
    String l = '', String w = '', String q = '1',
    this.edgeTop = false, this.edgeBottom = false, this.edgeLeft = false, this.edgeRight = false,
    this.direction = GrainDirection.any,
  })  : nameController = TextEditingController(text: name),
        lengthController = TextEditingController(text: l),
        widthController = TextEditingController(text: w),
        qtyController = TextEditingController(text: q);

  String get name => nameController.text;

  Map<String, dynamic> toJson() => {
    'name': nameController.text,
    'l': lengthController.text,
    'w': widthController.text,
    'q': qtyController.text,
    'et': edgeTop, 'eb': edgeBottom, 'el': edgeLeft, 'er': edgeRight,
    'dir': direction.index,
  };

  static CutItem fromJson(Map<String, dynamic> j) => CutItem(
    name: j['name'] ?? '', l: j['l'] ?? '', w: j['w'] ?? '', q: j['q'] ?? '1',
    edgeTop: j['et'] ?? false, edgeBottom: j['eb'] ?? false, edgeLeft: j['el'] ?? false, edgeRight: j['er'] ?? false,
    direction: GrainDirection.values[j['dir'] ?? 2],
  );
}

class PlacedPiece {
  final String label;
  final double x, y, w, h;
  final Color color;
  final bool isRotated;
  PlacedPiece(this.label, this.x, this.y, this.w, this.h, this.color, {this.isRotated = false});
}

class IndividualPiece {
  final String name;
  final double width, height;
  final Color color;
  final GrainDirection direction;
  IndividualPiece(this.name, this.width, this.height, this.color, this.direction);
}

class CalculationResult {
  final List<List<PlacedPiece>> packedSheets;
  final int sheetsNeeded;
  final double totalWastePercent, totalEdgeLength;
  CalculationResult({required this.packedSheets, required this.sheetsNeeded, required this.totalWastePercent, required this.totalEdgeLength});
}

// --- Navigation ---
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/workshop', builder: (context, state) => const SmartWorkshopPage()),
    GoRoute(path: '/workshop/optimizer', builder: (context, state) => const CutListOptimizerPage()),
    GoRoute(path: '/workshop/trims', builder: (context, state) => const TrimsCatalogPage()),
    GoRoute(path: '/designer3d', builder: (context, state) => const Designer3DPage()),
    GoRoute(path: '/order-kitchen', builder: (context, state) => const OrderKitchenPage()),
    GoRoute(path: '/salon/step1', builder: (context, state) => SalonOrderStep1Screen()),
    GoRoute(path: '/salon/step2', builder: (context, state) => const SalonOrderStep2Screen()),
  ],
);

PreferredSizeWidget _buildAppBar(BuildContext context, String title) => AppBar(
  backgroundColor: const Color(0xFF0F172A),
  elevation: 0,
  centerTitle: true,
  iconTheme: const IconThemeData(color: Colors.white),
  title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
  leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
);

void main() => runApp(const ProviderScope(child: GraphitubeApp()));

class GraphitubeApp extends StatelessWidget {
  const GraphitubeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    routerConfig: _router,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar', '')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF8FAFC), fontFamily: 'Tajawal', primaryColor: const Color(0xFF0F172A), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A))),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 1, title: Image.asset('assets/images/logo.png', height: 35, errorBuilder: (c,e,s) => const Text('Graphitube')), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(children: [
              const Text('مرحباً بك في Graphitube', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              ServiceCard(gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]), badgeText: 'PRO', floatingIcon: Icons.handyman, title: 'الورشة الذكية للحرفي', description: 'حساب التقطيع وكتالوج فيسان السدادر والطوابل.', buttonText: 'دخول الورشة ←', buttonColor: const Color(0xFF0F172A), onPressed: () => context.go('/workshop')),
              const SizedBox(height: 20),
              ServiceCard(gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]), badgeText: 'NEW 3D', floatingIcon: Icons.view_in_ar, title: 'مصمم المطبخ 3D', description: 'صمم مطبخك بنفسك وشاهده بتقنية ثلاثية الأبعاد.', buttonText: 'إبدأ التصميم ←', buttonColor: const Color(0xFF1E66FF), onPressed: () => context.go('/designer3d')),
              const SizedBox(height: 20),
              ServiceCard(imagePath: 'assets/images/kitchen.png', floatingIcon: Icons.restaurant_outlined, title: 'طلب المطبخ', description: 'احصل على عرض سعر دقيق لمطبخك الجديد.', buttonText: 'إبدأ الطلب ←', buttonColor: const Color(0xFF16A34A), onPressed: () => context.go('/order-kitchen')),
              const SizedBox(height: 20),
              ServiceCard(imagePath: 'assets/images/salon.png', floatingIcon: Icons.chair_outlined, title: 'صالون خشبي عصري', description: 'تصميم وتنفيذ صالونات مغربية خشبية حسب الطلب.', buttonText: 'إبدأ تصميم الصالون ←', buttonColor: const Color(0xFFF59E0B), onPressed: () => context.go('/salon/step1')),
              const SizedBox(height: 40),
              const Divider(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Text('Graphitube - نجارة خشبية مخصصة\nجميع الحقوق محفوظة © 2024', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5))),
          ]),
        ),
      ),
    );
  }
}

class SmartWorkshopPage extends StatelessWidget { const SmartWorkshopPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: _buildAppBar(context, 'الورشة الذكية للحرفي'), body: ListView(padding: const EdgeInsets.all(20), children: [_buildToolCard(context, 'حساب تقطيع الخشب', 'تحسين التقطيع لتقليل الضياع مع تقرير PDF.', Icons.grid_on, Colors.blue, '/workshop/optimizer'), const SizedBox(height: 20), _buildToolCard(context, 'كتالوج فيسان الصالون', 'موديلات فيسان السدادر والطوابل العصرية.', Icons.style, Colors.orange, '/workshop/trims')])); Widget _buildToolCard(BuildContext context, String title, String sub, IconData icon, Color col, String route) => Container(margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: Material(color: Colors.transparent, child: InkWell(onTap: () => context.go(route), borderRadius: BorderRadius.circular(15), child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [CircleAvatar(backgroundColor: col.withOpacity(0.1), child: Icon(icon, color: col)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 13))])), const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey)]))))); }
class TrimsCatalogPage extends StatelessWidget { const TrimsCatalogPage({super.key}); final List<Map<String, String>> trims = const [{'name': 'فيسان ملكي ذهبي', 'type': 'سدادر', 'price': '120 dh/m'}, {'name': 'فيسان عصري فضي', 'type': 'طوابل', 'price': '90 dh/m'}]; @override Widget build(BuildContext context) => Scaffold(appBar: _buildAppBar(context, 'كتالوج الفيسان'), body: GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 15, mainAxisSpacing: 15), itemCount: trims.length, itemBuilder: (context, index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Container(decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))), child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)))), Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(trims[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(trims[index]['type']!, style: TextStyle(color: Colors.grey[600], fontSize: 11)), const SizedBox(height: 5), Text(trims[index]['price']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))]))])))); }

class CutListOptimizerPage extends StatefulWidget { const CutListOptimizerPage({super.key}); @override State<CutListOptimizerPage> createState() => _CutListOptimizerPageState(); }
class _CutListOptimizerPageState extends State<CutListOptimizerPage> {
  late List<CutItem> items; final sheetLC = TextEditingController(text: '2800'), sheetWC = TextEditingController(text: '2100'), projectNameC = TextEditingController(text: 'مشروع جديد');
  bool isCm = false; GrainDirection sheetGrain = GrainDirection.horizontal; bool _isCalculating = false; int sheetsNeeded = 0; double totalWastePercent = 0, totalEdgeLength = 0; List<List<PlacedPiece>> _packedSheets = [];
  @override void initState() { super.initState(); items = [CutItem(name: 'القطعة 1')]; }
  Future<void> _saveProject() async { final prefs = await SharedPreferences.getInstance(); List<String> projects = prefs.getStringList('saved_projects') ?? []; Map<String, dynamic> data = {'title': projectNameC.text, 'date': DateTime.now().toString(), 'items': items.map((e) => e.toJson()).toList(), 'sL': sheetLC.text, 'sW': sheetWC.text, 'isCm': isCm}; projects.add(jsonEncode(data)); await prefs.setStringList('saved_projects', projects); if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المشروع!'))); }
  void _showSavedProjects() async { final prefs = await SharedPreferences.getInstance(); List<String> list = prefs.getStringList('saved_projects') ?? []; if(!mounted) return; showDialog(context: context, builder: (c) => AlertDialog(title: const Text('المشاريع السابقة'), content: SizedBox(width: double.maxFinite, child: ListView.builder(itemCount: list.length, shrinkWrap: true, itemBuilder: (c,i){ var data = jsonDecode(list[i]); return ListTile(title: Text(data['title']), subtitle: Text(data['date'].toString().split('.')[0]), onTap: (){ setState(() { projectNameC.text = data['title']; sheetLC.text = data['sL']; sheetWC.text = data['sW']; isCm = data['isCm'] ?? false; items = (data['items'] as List).map((e) => CutItem.fromJson(e)).toList(); }); Navigator.pop(c); }); })))); }
  String _sText(CutItem it) { List<String> s = []; if (it.edgeTop) s.add('ف'); if (it.edgeBottom) s.add('ت'); if (it.edgeLeft) s.add('يس'); if (it.edgeRight) s.add('يم'); return s.isEmpty ? '-' : s.join(','); }
  Future<void> _calculate() async { if (_isCalculating) return; FocusManager.instance.primaryFocus?.unfocus(); final double sL = double.tryParse(sheetLC.text) ?? 0, sW = double.tryParse(sheetWC.text) ?? 0; if (sL <= 0 || sW <= 0) return; setState(() => _isCalculating = true); await Future.delayed(const Duration(milliseconds: 400)); final result = _calculatePackingLogic(sL, sW); setState(() { _packedSheets = result.packedSheets; sheetsNeeded = result.sheetsNeeded; totalWastePercent = result.totalWastePercent; totalEdgeLength = result.totalEdgeLength; _isCalculating = false; }); SchedulerBinding.instance.addPostFrameCallback((_) { if (mounted) _showResult(); }); }
  CalculationResult _calculatePackingLogic(double sL, double sW) { List<IndividualPiece> allPieces = []; List<Color> palette = [const Color(0xFFD2B48C), const Color(0xFFDEB887), const Color(0xFFF4A460), const Color(0xFFCD853F), const Color(0xFF8B4513)]; double totalPiecesArea = 0, totalEdgeM = 0; for (var it in items) { double l = double.tryParse(it.lengthController.text) ?? 0, w = double.tryParse(it.widthController.text) ?? 0; int q = int.tryParse(it.qtyController.text) ?? 0; if (l <= 0 || w <= 0 || q <= 0) continue; totalPiecesArea += (l * w * q); if (it.edgeTop) totalEdgeM += (l * q); if (it.edgeBottom) totalEdgeM += (l * q); if (it.edgeLeft) totalEdgeM += (w * q); if (it.edgeRight) totalEdgeM += (w * q); for (int i = 0; i < q; i++) { allPieces.add(IndividualPiece(it.name, l, w, palette[allPieces.length % palette.length], it.direction)); } } allPieces.sort((a, b) => (b.width * b.height).compareTo(a.width * a.height)); List<List<PlacedPiece>> packedSheets = []; List<List<Rect>> freeRectsPerSheet = []; for (var p in allPieces) { bool placed = false; for (int i = 0; i < packedSheets.length; i++) { int bestIdx = -1; bool rotated = false; double minArea = double.infinity; for (int j = 0; j < freeRectsPerSheet[i].length; j++) { Rect r = freeRectsPerSheet[i][j]; if (p.width <= r.width && p.height <= r.height) { if (r.width * r.height < minArea) { minArea = r.width * r.height; bestIdx = j; rotated = false; } } if (p.height <= r.width && p.width <= r.height && p.direction == GrainDirection.any) { if (r.width * r.height < minArea) { minArea = r.width * r.height; bestIdx = j; rotated = true; } } } if (bestIdx != -1) { Rect r = freeRectsPerSheet[i].removeAt(bestIdx); double finalW = rotated ? p.height : p.width, finalH = rotated ? p.width : p.height; packedSheets[i].add(PlacedPiece(p.name, r.left, r.top, finalW, finalH, p.color, isRotated: rotated)); if (r.width - finalW > 0.1) freeRectsPerSheet[i].add(Rect.fromLTWH(r.left + finalW, r.top, r.width - finalW, r.height)); if (r.height - finalH > 0.1) freeRectsPerSheet[i].add(Rect.fromLTWH(r.left, r.top + finalH, finalW, r.height - finalH)); placed = true; break; } } if (!placed) { if (p.width <= sL && p.height <= sW) { packedSheets.add([PlacedPiece(p.name, 0, 0, p.width, p.height, p.color)]); freeRectsPerSheet.add([Rect.fromLTWH(p.width, 0, sL - p.width, sW), Rect.fromLTWH(0, p.height, p.width, sW - p.height)]); placed = true; } } } return CalculationResult(packedSheets: packedSheets, sheetsNeeded: packedSheets.length, totalWastePercent: packedSheets.isEmpty ? 0 : (1 - (totalPiecesArea / (packedSheets.length * sL * sW))) * 100, totalEdgeLength: totalEdgeM / 1000); }
  void _showResult() { double sL = double.tryParse(sheetLC.text) ?? 2800, sW = double.tryParse(sheetWC.text) ?? 2100; String unit = isCm ? 'cm' : 'mm'; showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (context) => Container(height: MediaQuery.of(context).size.height * 0.9, padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [Container(margin: const EdgeInsets.symmetric(vertical: 15), width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))), Expanded(child: ListView(children: [const Center(child: Text('نتائج الحساب والتقطيع', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))), const SizedBox(height: 20), Row(children: [_resultStat('الألواح المطلوبة', '$sheetsNeeded', Icons.layers, Colors.blue), const SizedBox(width: 10), _resultStat('نسبة الضياع', '${totalWastePercent.toStringAsFixed(1)}%', Icons.delete_outline, Colors.red)]), const SizedBox(height: 10), _resultStat('إجمالي شريط الحواف', '${totalEdgeLength.toStringAsFixed(1)} متر', Icons.linear_scale, Colors.orange), const SizedBox(height: 20), ElevatedButton.icon(onPressed: _genPdf, icon: const Icon(Icons.picture_as_pdf), label: const Text('تحميل التقرير النهائي PDF'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50))), const SizedBox(height: 30), ..._packedSheets.asMap().entries.map((entry) => _buildSheetResult(entry.key + 1, entry.value, sL, sW, unit)), const SizedBox(height: 40)]))]))); }
  Widget _resultStat(String l, String v, IconData i, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: c.withOpacity(0.1))), child: Column(children: [Icon(i, color: c, size: 24), const SizedBox(height: 8), Text(l, style: TextStyle(fontSize: 12, color: Colors.grey[600])), Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c))])));
  Widget _buildSheetResult(int n, List<PlacedPiece> p, double sL, double sW, String u) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)), child: Text('اللوح #$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), const Spacer(), Text('${sL.toInt()} x ${sW.toInt()} $u', style: TextStyle(color: Colors.grey[600], fontSize: 13))]), const SizedBox(height: 15), Center(child: Container(height: 400, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[300]!)), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: InteractiveViewer(boundaryMargin: const EdgeInsets.all(100), minScale: 0.1, maxScale: 5.0, child: Center(child: FittedBox(fit: BoxFit.contain, child: _buildVisualMap(p, sL, sW))))))), const SizedBox(height: 30)]);
  Widget _buildVisualMap(List<PlacedPiece> placed, double sL, double sW) { if (sL <= 0) return const SizedBox.shrink(); return Column(children: [Row(mainAxisSize: MainAxisSize.min, children: [Container(width: sL, height: sW, decoration: BoxDecoration(color: const Color(0xFFF3E5AB), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF5D4037), width: 5.0)), child: Stack(clipBehavior: Clip.none, children: placed.map((p) => Positioned(left: p.x, top: p.y, child: Container(width: p.w, height: p.h, decoration: BoxDecoration(color: p.color, border: Border.all(color: Colors.black.withOpacity(0.5), width: 2.0)), child: Center(child: Text(p.label, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.clip))))).toList())), const SizedBox(width: 20), RotatedBox(quarterTurns: 1, child: Text('${sW.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 50)))]), const SizedBox(height: 20), Text('${sL.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 50))]); }
  Future<void> _genPdf() async {
    final af = await PdfGoogleFonts.amiriRegular(), ab = await PdfGoogleFonts.amiriBold();
    final doc = pw.Document(); final res = ArabicReshaper(); String cu = isCm ? 'cm' : 'mm';
    String fix(String? t) { if (t == null || t.isEmpty) return ''; String r = res.reshape(t), v = r.split('').reversed.join(''); v = v.replaceAll('(', '@@').replaceAll(')', '(').replaceAll('@@', ')'); return v.splitMapJoin(RegExp(r'[a-zA-Z0-9\.]+'), onMatch: (m) => m.group(0)!.split('').reversed.join(''), onNonMatch: (n) => n); }
    doc.addPage(pw.MultiPage(theme: pw.ThemeData.withFont(base: af, bold: ab), build: (c) => [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(fix('Graphitube Wood Systems'), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)), pw.Text(fix('الورشة الذكية للحرفي'), style: pw.TextStyle(fontSize: 12, font: af))]),
          pw.Container(height: 40, width: 40, color: PdfColors.blueGrey900, child: pw.Center(child: pw.Text('G', style: const pw.TextStyle(color: PdfColors.white, fontSize: 24)))),
        ]),
        pw.Divider(thickness: 2), pw.SizedBox(height: 20),
        pw.Text(fix('تقرير مشروع: ${projectNameC.text}'), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: ab)),
        pw.SizedBox(height: 20),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
          _pdfStatCard(fix('الألواح'), '$sheetsNeeded', PdfColors.blue900, ab),
          _pdfStatCard(fix('الضياع'), '${totalWastePercent.toStringAsFixed(1)}%', PdfColors.red900, ab),
          _pdfStatCard(fix('شريط الحواف'), '${totalEdgeLength.toStringAsFixed(1)}m', PdfColors.orange900, ab),
        ]),
        pw.SizedBox(height: 30),
        pw.TableHelper.fromTextArray(context: c, data: [
            [fix('شريط حواف'), fix('العدد'), fix('القياس'), fix('القطعة')],
            ...items.map((it) => [fix(_sText(it)), fix(it.qtyController.text), fix('${it.lengthController.text}x${it.widthController.text}'), fix(it.name)])
          ], cellStyle: pw.TextStyle(fontSize: 10, font: af), headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, font: ab, color: PdfColors.white), headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900), cellAlignment: pw.Alignment.centerRight),
    ]));
    for (int i = 0; i < _packedSheets.length; i++) {
      doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4.landscape, build: (pw.Context context) => pw.Column(children: [
          pw.Container(padding: const pw.EdgeInsets.all(10), decoration: const pw.BoxDecoration(color: PdfColors.blueGrey900), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(fix('Graphitube'), style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)), pw.Text(fix('مخطط اللوح رقم ${i + 1}'), style: pw.TextStyle(color: PdfColors.white, font: ab)), pw.Text('${sheetLC.text}x${sheetWC.text} $cu', style: const pw.TextStyle(color: PdfColors.white))])),
          pw.SizedBox(height: 20),
          pw.Expanded(child: pw.Container(width: double.infinity, decoration: pw.BoxDecoration(border: pw.Border.all(width: 2, color: PdfColors.black), color: PdfColors.grey100), child: pw.LayoutBuilder(builder: (context, constraints) {
              double scale = (constraints?.maxWidth ?? 500) / double.parse(sheetLC.text);
              return pw.Stack(children: _packedSheets[i].map((p) => pw.Positioned(left: p.x * scale, top: p.y * scale, child: pw.Container(width: p.w * scale, height: p.h * scale, decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5, color: PdfColors.black), color: PdfColor.fromInt(p.color.value)), child: pw.Stack(alignment: pw.Alignment.center, children: [pw.Text(fix(p.label), style: pw.TextStyle(fontSize: 9, font: ab)), pw.Positioned(top: 2, child: pw.Text('${p.w.toInt()}', style: const pw.TextStyle(fontSize: 7))), pw.Positioned(left: 2, child: pw.Transform.rotate(angle: 1.57, child: pw.Text('${p.h.toInt()}', style: const pw.TextStyle(fontSize: 7))))])))).toList());
          }))),
      ])));
    }
    await Printing.layoutPdf(onLayout: (f) async => doc.save(), name: '${projectNameC.text}.pdf');
  }
  pw.Widget _pdfStatCard(String l, String v, PdfColor c, pw.Font f) => pw.Container(padding: const pw.EdgeInsets.all(10), width: 120, decoration: pw.BoxDecoration(border: pw.Border.all(color: c, width: 1), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))), child: pw.Column(children: [pw.Text(l, style: pw.TextStyle(fontSize: 10, font: f)), pw.Text(v, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: c))]));
  @override Widget build(BuildContext context) { return Scaffold(backgroundColor: const Color(0xFFF1F5F9), appBar: AppBar(title: const Text('حساب التقطيع الذكي'), actions: [IconButton(icon: const Icon(Icons.history), onPressed: _showSavedProjects)]), body: Column(children: [Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))), child: Column(children: [Row(children: [Expanded(child: _buildHeaderInput(projectNameC, 'اسم المشروع', Icons.edit_calendar, isNumeric: false)), const SizedBox(width: 10), _unitToggle()]), const SizedBox(height: 20), Row(children: [Expanded(child: _buildHeaderInput(sheetLC, 'طول اللوح', Icons.straighten, unit: isCm ? 'cm' : 'mm')), const SizedBox(width: 10), Expanded(child: _buildHeaderInput(sheetWC, 'عرض اللوح', Icons.straighten, unit: isCm ? 'cm' : 'mm')), const SizedBox(width: 10), IconButton(icon: const Icon(Icons.save, color: Colors.blue), onPressed: _saveProject)])])), Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), itemCount: items.length, itemBuilder: (c, i) => _buildCutItemCard(i))), _buildBottomActionArea()])); }
  Widget _buildHeaderInput(TextEditingController c, String h, IconData i, {bool isNumeric = true, String? unit}) => Container(height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: TextField(controller: c, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: InputDecoration(prefixIcon: Icon(i, color: Colors.blue[300], size: 18), suffixIcon: unit != null ? Padding(padding: const EdgeInsets.only(top: 15), child: Text(unit, style: const TextStyle(color: Colors.white54, fontSize: 10))) : null, hintText: h, hintStyle: const TextStyle(color: Colors.white54, fontSize: 12), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15)), keyboardType: isNumeric ? TextInputType.number : TextInputType.text));
  Widget _unitToggle() => Container(height: 45, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, children: [_unitOption('mm', !isCm), _unitOption('cm', isCm)]));
  Widget _unitOption(String l, bool s) => GestureDetector(onTap: () { if (!s) { setState(() { isCm = l == 'cm'; _convertValues(isCm); }); } }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: s ? Colors.blue[400] : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Text(l, style: TextStyle(color: s ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))));
  void _convertValues(bool toCm) { double f = toCm ? 0.1 : 10.0; sheetLC.text = ((double.tryParse(sheetLC.text) ?? 0) * f).toStringAsFixed(toCm ? 1 : 0).replaceAll('.0', ''); sheetWC.text = ((double.tryParse(sheetWC.text) ?? 0) * f).toStringAsFixed(toCm ? 1 : 0).replaceAll('.0', ''); for (var it in items) { it.lengthController.text = ((double.tryParse(it.lengthController.text) ?? 0) * f).toStringAsFixed(toCm ? 1 : 0).replaceAll('.0', ''); it.widthController.text = ((double.tryParse(it.widthController.text) ?? 0) * f).toStringAsFixed(toCm ? 1 : 0).replaceAll('.0', ''); } }
  Widget _buildCutItemCard(int i) => Card(margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Column(children: [Padding(padding: const EdgeInsets.all(15), child: Row(children: [CircleAvatar(radius: 18, child: Text('${i + 1}')), const SizedBox(width: 12), Expanded(child: TextField(controller: items[i].nameController, decoration: const InputDecoration(border: InputBorder.none, hintText: 'اسم القطعة'), style: const TextStyle(fontWeight: FontWeight.bold))), _directionSelector(items[i].direction, (v) => setState(() => items[i].direction = v)), IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent), onPressed: () => setState(() => items.removeAt(i)))])), Padding(padding: const EdgeInsets.all(15), child: Row(children: [Expanded(child: _buildItemField(items[i].lengthController, 'الطول', true)), const SizedBox(width: 8), Expanded(child: _buildItemField(items[i].widthController, 'العرض', true)), const SizedBox(width: 8), Expanded(child: _buildItemField(items[i].qtyController, 'العدد', false))])), Container(padding: const EdgeInsets.all(10), color: const Color(0xFFF8FAFC), child: Row(children: [const Text('الحواف:', style: TextStyle(fontSize: 12)), const Spacer(), _buildEdgeToggle(i, 0), _buildEdgeToggle(i, 1), _buildEdgeToggle(i, 2), _buildEdgeToggle(i, 3)]))]));
  Widget _buildItemField(TextEditingController c, String l, bool u) => TextField(controller: c, textAlign: TextAlign.center, decoration: InputDecoration(labelText: l, suffixText: u ? (isCm ? 'cm' : 'mm') : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), keyboardType: TextInputType.number);
  Widget _buildEdgeToggle(int i, int t) { bool val = t == 0 ? items[i].edgeTop : t == 1 ? items[i].edgeBottom : t == 2 ? items[i].edgeLeft : items[i].edgeRight; return IconButton(icon: Icon(t < 2 ? Icons.border_top : Icons.border_left, color: val ? Colors.orange : Colors.grey, size: 18), onPressed: () => setState(() { if (t == 0) items[i].edgeTop = !val; else if (t == 1) items[i].edgeBottom = !val; else if (t == 2) items[i].edgeLeft = !val; else items[i].edgeRight = !val; })); }
  Widget _directionSelector(GrainDirection c, Function(GrainDirection) o) => Row(mainAxisSize: MainAxisSize.min, children: [_dirIcon(Icons.swap_horiz, GrainDirection.horizontal, c, o), _dirIcon(Icons.swap_vert, GrainDirection.vertical, c, o), _dirIcon(Icons.sync, GrainDirection.any, c, o)]);
  Widget _dirIcon(IconData i, GrainDirection v, GrainDirection c, Function(GrainDirection) o) { bool s = c == v; return InkWell(onTap: () => o(v), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: s ? Colors.blue.withOpacity(0.1) : Colors.transparent, shape: BoxShape.circle), child: Icon(i, size: 18, color: s ? Colors.blue : Colors.grey[400]))); }
  Widget _buildBottomActionArea() => Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]), child: Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => items.add(CutItem(name: 'القطعة ${items.length + 1}'))), icon: const Icon(Icons.add_circle_outline), label: const Text('إضافة قطعة'))), const SizedBox(width: 12), Expanded(child: ElevatedButton.icon(onPressed: _isCalculating ? null : _calculate, icon: _isCalculating ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.auto_fix_high), label: const Text('حساب التتقطيع الآن'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))]));
}
class Designer3DPage extends StatelessWidget { const Designer3DPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: _buildAppBar(context, 'مصمم المطبخ 3D'), body: const Center(child: Text('صفحة المصمم 3D قيد التطوير'))); }
class OrderKitchenPage extends StatelessWidget { const OrderKitchenPage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: _buildAppBar(context, 'طلب مطبخ'), body: const Center(child: Text('صفحة طلب المطبخ قيد التطوير'))); }
