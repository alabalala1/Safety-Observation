import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../observations/presentation/observation_form_widgets.dart';

/// All screens read the same local setting; a new route refreshes it on open.
class ActiveSiteBar extends StatelessWidget {
  const ActiveSiteBar({super.key, this.site});
  final String? site;

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: site == null ? AppServices.reports.loadSetting('activeSite')
        : Future.value(site),
    builder: (context, snapshot) {
      final value = snapshot.data?.trim();
      return Container(
        height: 36,
        color: AppColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          const ObservationIcon('home', 'map_pin', 14),
          const SizedBox(width: 8),
          Expanded(child: Text(
            value == null || value.isEmpty
                ? AppStrings.activeSiteNotSet
                : '${AppStrings.activeSite}: ${value.toUpperCase()}',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: Colors.white),
          )),
          Container(width: 8, height: 8,
            decoration: BoxDecoration(color: AppColors.orange,
              borderRadius: BorderRadius.circular(4))),
        ]),
      );
    },
  );
}
