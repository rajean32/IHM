import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/services/app_config.dart';
import '../../models/evenement_model.dart';
import '../../core/services/evenement_service.dart';
import '../../core/assets/app_colors.dart';
import '../../core/routes/client_routes.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/error_state.dart';
import '../../generated/app_localizations.dart';

class ReservationLibrePage extends StatefulWidget {
  final int eventId;
  const ReservationLibrePage({super.key, required this.eventId});

  @override
  State<ReservationLibrePage> createState() => _ReservationLibrePageState();
}

class _ReservationLibrePageState extends State<ReservationLibrePage> {
  EventDetail? _event;
  List<StandingZone> _zones = [];
  bool _isLoading = true;
  String? _error;
  final Map<int, int> _selectedQuantities = {};

  int get _totalQty =>
      _selectedQuantities.values.fold(0, (sum, q) => sum + q);

  double get _calculatedTotal {
    double total = 0;
    for (final zone in _zones) {
      final qty = _selectedQuantities[zone.idZone] ?? 0;
      total += zone.prix * qty;
    }
    return total;
  }

  bool get _hasSelection => _totalQty > 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final eventService = EvenementService();
      final eventData = await eventService.getEventDetail(widget.eventId);
      final event = EventDetail.fromJson(eventData);
      final zonesData = await eventService.getStandingZones(widget.eventId);
      final zones = zonesData
          .map((e) => StandingZone.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _event = event;
        _zones = zones;
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

  void _updateQuantity(int zoneId, int delta) {
    setState(() {
      final current = _selectedQuantities[zoneId] ?? 0;
      final next = current + delta;
      if (next < 0) return;
      const maxPerUser = 4;
      if (next > maxPerUser) return;
      final zone = _zones.firstWhere((z) => z.idZone == zoneId);
      if (zone.capacite != null && zone.placesDisponibles != null && next > zone.placesDisponibles!) {
        return;
      }
      if (next == 0) {
        _selectedQuantities.remove(zoneId);
      } else {
        _selectedQuantities[zoneId] = next;
      }
    });
  }

  void _confirmReservation() {
    if (!_hasSelection) return;
    final ticketItems = <Map<String, dynamic>>[];
    for (final entry in _selectedQuantities.entries) {
      final zone = _zones.firstWhere((z) => z.idZone == entry.key);
      for (int i = 0; i < entry.value; i++) {
        ticketItems.add({
          'prix': zone.prix,
          'numeroPlace': zone.nom,
          'idZone': zone.idZone,
          'typePlace': 'DEBOUT',
        });
      }
    }
    Navigator.pushNamed(context, ClientRoutes.payment, arguments: {
      'eventId': widget.eventId,
      'eventTitle': _event?.titre ?? '',
      'tickets': ticketItems,
      'amount': _calculatedTotal,
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('d MMMM yyyy', appLanguage)
          .format(date)
          .toUpperCase();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : _event == null
                  ? Center(
                      child:
                          Text(AppLocalizations.of(context)!.clientReservationEventNotFound))
                  : Column(
                      children: [
                        _buildEventBanner(),
                        Expanded(child: _buildZoneList()),
                      ],
                    ),
      bottomNavigationBar: _event != null ? _buildFooter() : null,
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: ModalRoute.of(context)?.canPop == true
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: _event != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _event!.titre,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _event!.lieuNom ?? '',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : const Text(''),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.85),
              border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08))),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: AppLocalizations.of(context)!.clientReservationShare,
          onPressed: () {
            final e = _event;
            if (e == null) return;
            final text =
                '${e.titre}\n📍 ${e.lieuNom ?? ''}\n${_calculatedTotal > 0 ? "${AppConstants.currency}${_calculatedTotal.toStringAsFixed(0)}" : ""}';
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.clientShareCopied)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventBanner() {
    final e = _event!;
    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight + 8),
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(e.dateEvenement),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    if (e.heureEvenement != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.schedule,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        e.heureEvenement!,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people,
                          size: 14,
                          color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Placement Libre',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneList() {
    if (_zones.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline,
                  size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.clientReservationNoStandingZones,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _zones.length,
      itemBuilder: (context, index) => _buildZoneCard(_zones[index]),
    );
  }

  Widget _buildZoneCard(StandingZone zone) {
    final qty = _selectedQuantities[zone.idZone] ?? 0;
    final cap = zone.capacite;
    final dispo = zone.placesDisponibles ?? 0;
    final ratio = cap != null && cap > 0
        ? ((cap - dispo) / cap).clamp(0.0, 1.0)
        : 0.0;
    final jaugeColor = ratio < 0.5
        ? AppColors.secondary
        : (ratio < 0.8 ? Colors.orange : AppColors.error);
    final isNearFull = ratio >= 0.8;
    final maxReached = qty >= 4 ||
        (dispo > 0 && qty >= dispo);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNearFull
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.ticketBorder,
          width: isNearFull ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: jaugeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.accessibility_new,
                          color: jaugeColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  zone.nom,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isNearFull) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.error
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'BIENTÔT ÉPUISÉ !',
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.error,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${AppConstants.currency}${zone.prix.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: jaugeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCounter(zone, qty, maxReached),
                  ],
                ),
                if (cap != null && cap > 0) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor:
                          AppColors.divider.withValues(alpha: 0.3),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(jaugeColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Places restantes : $dispo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dispo < 50 ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(ratio * 100).round()}% rempli',
                        style: TextStyle(
                          fontSize: 11,
                          color: jaugeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(StandingZone zone, int qty, bool maxReached) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ticketBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: qty > 0 ? () => _updateQuantity(zone.idZone!, -1) : null,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(19),
              bottomLeft: Radius.circular(19),
            ),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.remove,
                size: 18,
                color: qty > 0 ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.ticketBorder),
              ),
            ),
            child: Text(
              '$qty',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: maxReached ? null : () => _updateQuantity(zone.idZone!, 1),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(19),
              bottomRight: Radius.circular(19),
            ),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: Icon(
                Icons.add,
                size: 18,
                color: maxReached ? AppColors.textMuted : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Total :',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppConstants.currency}${_calculatedTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFD54F),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _hasSelection ? _confirmReservation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirmer la réservation ($_totalQty billets)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _hasSelection
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 0.3,
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
