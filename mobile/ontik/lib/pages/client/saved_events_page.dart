import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/evenement_model.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/services/app_config.dart';
import '../../widgets/event_image_widget.dart';
import '../../generated/app_localizations.dart';

class SavedEventsPage extends StatefulWidget {
  const SavedEventsPage({super.key});

  @override
  State<SavedEventsPage> createState() => _SavedEventsPageState();
}

class _SavedEventsPageState extends State<SavedEventsPage> {
  bool _loading = true;
  List<Evenement> _events = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('event_favorites') ?? [];
      if (ids.isEmpty) {
        if (mounted) setState(() { _events = []; _loading = false; });
        return;
      }
      final allResp = await dio.get(Endpoints.events);
      final allData = allResp.data['data'] as List? ?? [];
      final allEvents = allData.map((e) => Evenement.fromJson(e as Map<String, dynamic>)).toList();
      final filtered = allEvents.where((e) => ids.contains(e.idEvenement?.toString())).toList();
      if (mounted) setState(() { _events = filtered; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.clientProfileFavorites),
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.clientSavedEventsEmpty, style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _events.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCard(_events[i]),
                    ),
                  ),
                ),
    );
  }

  Widget _buildCard(Evenement event) {
    return GestureDetector(
      onTap: () {
        if (event.idEvenement != null) {
          Navigator.pushNamed(context, ClientRoutes.homeDetail, arguments: {'id': event.idEvenement});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: event.image != null
                    ? eventImageWidget(event.image!, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Icon(Icons.event, color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.titre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    if (event.lieuNom != null)
                      Text(event.lieuNom!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    if (event.dateEvenement != null)
                      Text(
                        DateFormat('d MMM yyyy', appLanguage).format(event.dateEvenement!),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
