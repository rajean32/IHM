import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/evenement_model.dart';
import '../../core/services/evenement_service.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/event_image_widget.dart';
import '../../core/services/app_config.dart';
import '../../generated/app_localizations.dart';
import '../../widgets/admin/admin_toast.dart';

class HomeDetailPage extends StatefulWidget {
  final int eventId;
  const HomeDetailPage({super.key, required this.eventId});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  EventDetail? _event;
  bool _isLoading = true;
  String? _error;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('event_favorites') ?? [];
    if (mounted) setState(() => _isFavorited = favorites.contains(widget.eventId.toString()));
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('event_favorites') ?? [];
    final idStr = widget.eventId.toString();
    if (_isFavorited) {
      favorites.remove(idStr);
    } else {
      favorites.add(idStr);
    }
    await prefs.setStringList('event_favorites', favorites);
    if (mounted) setState(() => _isFavorited = !_isFavorited);
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    if (loc == null) return;
    AdminToast.show(context, message: _isFavorited ? loc.clientFavoriteAdded : loc.clientFavoriteRemoved, isSuccess: true);
  }

  void _shareEvent() {
    final event = _event;
    if (event == null) return;
    final text = '${event.titre}\n'
        '${DateFormat('d MMMM yyyy', appLanguage).format(event.dateEvenement ?? DateTime.now())}'
        '${event.heureEvenement != null ? ' à ${event.heureEvenement!.substring(0, 5)}' : ''}\n'
        '📍 ${event.lieuNom ?? ''}\n'
        '${AppConstants.currency}${event.prixMin?.toStringAsFixed(0) ?? ''} - ${AppConstants.currency}${event.prixMax?.toStringAsFixed(0) ?? ''}';
    Clipboard.setData(ClipboardData(text: text));
    AdminToast.show(context, message: AppLocalizations.of(context)!.clientShareCopied, isSuccess: true);
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    try {
      final _eventService = EvenementService();
      final eventData = await _eventService.getEventDetail(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = EventDetail.fromJson(eventData);
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('d MMMM yyyy', appLanguage).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(AppLocalizations.of(context)!.clientHomeDetailTitle),
        actions: [
          IconButton(
            icon: Icon(_isFavorited ? Icons.bookmark : Icons.bookmark_border),
            tooltip: AppLocalizations.of(context)!.clientProfileFavorites,
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: AppLocalizations.of(context)!.clientHomeDetailShare,
            onPressed: _shareEvent,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadDetail, child: Text(AppLocalizations.of(context)!.clientHomeDetailRetry)),
                    ],
                  ),
                )
              : _event == null
                  ? Center(child: Text(AppLocalizations.of(context)!.clientHomeDetailEventNotFound))
                  : _buildContent(),
      bottomNavigationBar: _event != null ? _buildFooter() : null,
    );
  }

  Widget _buildContent() {
    final event = _event!;
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroBanner(event),
          _buildLogisticsRow(event),
          _buildLocationCard(event),
          _buildAboutSection(event),
          if (event.standingZones != null && event.standingZones!.isNotEmpty) _buildStandingZones(event),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(EventDetail event) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: event.image != null
              ? eventImageWidget(event.image, height: 260, width: double.infinity, fit: BoxFit.cover)
              : Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryDark,
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.event, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                ),
        ),
        // Gradient overlay for text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),
        // Badge + title
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(6),
                ),
                  child: Text(
                    (event.typeAgencement != null ? event.typeAgencement!.replaceAll('_', ' ') : AppLocalizations.of(context)!.clientHomeDetailEvent).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.titre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticsRow(EventDetail event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.clientHomeDetailDate,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(event.dateEvenement),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.schedule, size: 20, color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.clientHomeDetailTime,
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.heureEvenement ?? '—',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(EventDetail event) {
    final lieu = event.lieuNom ?? AppLocalizations.of(context)!.clientHomeDetailVenueNotSpecified;
    final adresse = event.lieuAdresse ?? '';
    final ville = event.lieuVille ?? '';
    final fullAddress = [adresse, ville].where((s) => s.isNotEmpty).join(', ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ticketBorder),
        ),
        child: InkWell(
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lieu,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    if (fullAddress.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          fullAddress,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(EventDetail event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.clientHomeDetailAbout,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            event.description ?? AppLocalizations.of(context)!.clientHomeDetailNoDescription,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
          if (event.caracteristiqueValeurs != null && event.caracteristiqueValeurs!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...event.caracteristiqueValeurs!.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: '${c.nomCaracteristique ?? AppLocalizations.of(context)!.clientHomeDetailCharacteristic} : ',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          TextSpan(text: c.valeur),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStandingZones(EventDetail event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.clientHomeDetailAvailableZones,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ...event.standingZones!.map((zone) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ticketBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.accessibility_new, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone.nom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        zone.capacite != null
                            ? '${zone.placesDisponibles ?? 0}/${zone.capacite} ${AppLocalizations.of(context)!.clientHomeDetailPlacesAvailable}'
                            : AppLocalizations.of(context)!.clientHomeDetailUnlimitedSeats,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${AppConstants.currency}${zone.prix.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final event = _event!;
    final hasPrice = event.prixMin != null || event.prixMax != null;
    final priceText = hasPrice
        ? (event.prixMin == event.prixMax
            ? '${AppConstants.currency}${event.prixMin!.toStringAsFixed(0)}'
            : '${AppConstants.currency}${event.prixMin!.toStringAsFixed(0)} - ${AppConstants.currency}${event.prixMax!.toStringAsFixed(0)}')
        : AppLocalizations.of(context)!.clientHomeDetailPriceUnavailable;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.clientHomeDetailFrom, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(
                  priceText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: event.idEvenement != null
                      ? () => Navigator.pushNamed(
                          context,
                          ClientRoutes.reservation,
                          arguments: {'eventId': event.idEvenement},
                        )
                      : null,
                  icon: const Icon(Icons.confirmation_number, size: 20),
                  label: Text(AppLocalizations.of(context)!.clientHomeDetailBook, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
