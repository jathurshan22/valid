import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late String _value;
  @override
  void initState() {
    super.initState();
    _value = AppStore.instance.appearance;
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      ('Light', Icons.light_mode_outlined, 'The current Valid production theme'),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton.filledTonal(
            style: IconButton.styleFrom(backgroundColor: AppColors.surface),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: const Text('Appearance', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            ...options.map((option) {
              final active = _value == option.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _value = option.$1),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: active ? AppColors.mintSoft : AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: active ? AppColors.mint : AppColors.line),
                    ),
                    child: Row(children: [
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: active ? Colors.white : AppColors.background, borderRadius: BorderRadius.circular(14)), child: Icon(option.$2, color: active ? AppColors.primary : AppColors.muted)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(option.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text(option.$3, style: const TextStyle(color: AppColors.muted, fontSize: 10.5, height: 1.3)),
                      ])),
                      Icon(active ? Icons.check_circle_rounded : Icons.circle_outlined, color: active ? AppColors.primary : AppColors.line),
                    ]),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  AppStore.instance.setAppearance(_value);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appearance preference saved.')));
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save appearance', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
