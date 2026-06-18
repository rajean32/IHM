import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/services/ticket_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';
import '../../core/utils/place_utils.dart';
import '../../generated/app_localizations.dart';
import '../../widgets/admin/admin_toast.dart';

class MixedSeatingTicketPage extends StatefulWidget {
  final String ticketCode;
  const MixedSeatingTicketPage({super.key, required this.ticketCode});

  @override
  State<MixedSeatingTicketPage> createState() => _MixedSeatingTicketPageState();
}

class _MixedSeatingTicketPageState extends State<MixedSeatingTicketPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final svc = TicketService();
      final detail = await svc.getTicket(widget.ticketCode);
      final qr = await svc.getTicketQRCode(widget.ticketCode);
      final val = await svc.validateTicket(widget.ticketCode);
      if (!mounted) return;
      final hasSeat = detail['typePlace'] != 'DEBOUT' && (detail['rang'] != null || qr['rang'] != null);
      setState(() {
        _data = {
          'codeTicket': detail['codeTicket'],
          'evenementTitre': detail['evenementTitre'] ?? qr['evenementTitre'],
          'numeroPlace': detail['numeroPlace'] ?? qr['placeNumero'],
          'rang': detail['rang'] ?? qr['rang'],
          'typePlace': detail['typePlace'] ?? qr['typePlace'],
          'zoneNom': detail['zoneNom'] ?? qr['zoneNom'],
          'prix': detail['prix'] ?? qr['prix'],
          'qrCodeBase64': qr['qrCodeBase64'],
          'valid': val['valid'],
          'clientNom': val['clientNom'],
          'dateEvenement': detail['dateEvenement'],
          'heureEvenement': detail['heureEvenement'],
          'lieuNom': detail['lieuNom'],
          'salleNom': detail['salleNom'],
          'hasSeat': hasSeat,
        };
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = apiErrorString(e); _loading = false; });
    }
  }

  Color _typeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'VIP': return const Color(0xFF9C27B0);
      case 'PREMIUM': return const Color(0xFFFF6F00);
      case 'ORCHESTRE': return const Color(0xFF7B1FA2);
      case 'BALCON': return const Color(0xFF00897B);
      case 'LOGE': return const Color(0xFF5C6BC0);
      default: return AppColors.placeStandard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ModalRoute.of(context)?.canPop == true
            ? IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 22), onPressed: () => Navigator.of(context).pop())
            : null,
        title: Text(AppLocalizations.of(context)!.clientTicketTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16), Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _load, child: Text(AppLocalizations.of(context)!.commonRetry)),
                ]))
              : _buildTicket(),
    );
  }

  Widget _buildTicket() {
    final isValid = _data!['valid'] as bool? ?? false;
    final hasSeat = _data!['hasSeat'] as bool;
    final type = _data!['typePlace'] as String?;
    final rang = _data!['rang'] as String?;
    final place = displayPlace(_data!['numeroPlace'] as String?);
    final zone = _data!['zoneNom'] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isValid ? AppColors.secondary : AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isValid ? Icons.check_circle : Icons.cancel, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  isValid ? AppLocalizations.of(context)!.clientTicketValid : AppLocalizations.of(context)!.clientTicketInvalid,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(hasSeat ? Icons.event_seat : Icons.accessibility_new, size: 18, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(hasSeat ? 'Place assise' : 'Zone debout',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 14)),
              ]),
            ),
            const SizedBox(height: 20),
            hasSeat ? _buildSeatedInfo(type, rang, place) : _buildStandingInfo(zone),
            const SizedBox(height: 20),
            if (_data!['qrCodeBase64'] != null) _buildQR(_data!['qrCodeBase64'] as String),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _downloadPDF,
              icon: const Icon(Icons.download, size: 18),
              label: Text(AppLocalizations.of(context)!.clientTicketDownloadPDF),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _row(AppLocalizations.of(context)!.clientTicketEvent, _data!['evenementTitre'] ?? 'N/A'),
            if (_data!['dateEvenement'] != null) _row('Date', _formatDate(_data!['dateEvenement'] as String, _data!['heureEvenement'] as String?)),
            if (_data!['lieuNom'] != null) _row('Lieu', _data!['lieuNom']),
            if (_data!['salleNom'] != null) _row(AppLocalizations.of(context)!.clientTicketRoom, _data!['salleNom']),
            if (rang != null) _row(AppLocalizations.of(context)!.clientTicketRow, rang),
            if (place != null) _row(AppLocalizations.of(context)!.clientTicketSeat, place),
            if (zone != null) _row(AppLocalizations.of(context)!.clientTicketZone, zone),
            if (type != null) _row(AppLocalizations.of(context)!.clientTicketType, type),
            if (_data!['prix'] != null) _row(AppLocalizations.of(context)!.clientTicketPrice, 'Ar ${_data!['prix']}'),
            if (_data!['clientNom'] != null) _row(AppLocalizations.of(context)!.clientTicketHolder, _data!['clientNom']),
            const Divider(),
            Text(_data!['codeTicket'] ?? '',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace')),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSeatedInfo(String? type, String? rang, String? place) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(children: [
            Text(AppLocalizations.of(context)!.clientTicketRow, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(rang ?? '—', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ]),
        ),
        Container(width: 1, height: 50, color: AppColors.divider),
        Expanded(
          child: Column(children: [
            Text(AppLocalizations.of(context)!.clientTicketSeat, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(place ?? '—', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStandingInfo(String? zone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        const Icon(Icons.accessibility_new, size: 48, color: AppColors.accent),
        const SizedBox(height: 12),
        Text(AppLocalizations.of(context)!.clientTicketZone, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(zone ?? 'Entrée libre', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.accent)),
      ]),
    );
  }

  String _formatDate(String date, String? time) {
    try {
      final d = date.contains('T') ? DateTime.parse(date) : DateTime.parse('${date}T00:00:00');
      return '${d.day}/${d.month}/${d.year}${time != null && time.length >= 5 ? ' - ${time.substring(0, 5)}' : ''}';
    } catch (_) { return date; }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildQR(String base64) {
    try {
      return Image.memory(base64Decode(base64), width: 200, height: 200);
    } catch (_) {
      return Container(width: 200, height: 200, color: AppColors.surface, child: const Icon(Icons.qr_code, size: 64));
    }
  }

  Future<void> _downloadPDF() async {
    try {
      final response = await dio.get('${Endpoints.tickets}/${widget.ticketCode}/pdf',
          options: Options(responseType: ResponseType.bytes));
      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final data = response.data;
      if (data is! List<int>) throw Exception('Format invalide');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/billet_${widget.ticketCode}.pdf');
      await file.writeAsBytes(data);
      if (!mounted) return;
      AdminToast.show(context, message: '${AppLocalizations.of(context)!.clientTicketPdfSaved} ${file.path}', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException ? (e.response?.statusCode?.toString() ?? e.message ?? 'Erreur') : e.toString();
      AdminToast.show(context, message: '${AppLocalizations.of(context)!.clientTicketDownloadFailed} $msg', isSuccess: false);
    }
  }
}
