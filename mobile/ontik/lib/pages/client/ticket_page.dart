import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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

class TicketPage extends StatefulWidget {
  final String ticketCode;
  const TicketPage({super.key, required this.ticketCode});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _qrData;

  String? _nz(dynamic v) =>
      (v != null && v.toString().isNotEmpty) ? v.toString() : null;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    setState(() => _loading = true);
    try {
      final _ticketService = TicketService();
      final ticketDetail = await _ticketService.getTicket(widget.ticketCode);
      final qrResponse = await _ticketService.getTicketQRCode(widget.ticketCode);
      final validation = await _ticketService.validateTicket(widget.ticketCode);

      if (!mounted) return;
      setState(() {
        _qrData = {
          'codeTicket': ticketDetail['codeTicket'],
          'evenementTitre': _nz(ticketDetail['evenementTitre']) ?? _nz(qrResponse['evenementTitre']),
          'placeNumero': _nz(qrResponse['placeNumero']) ?? _nz(ticketDetail['numeroPlace']),
          'rang': _nz(ticketDetail['rang']) ?? _nz(qrResponse['rang']),
          'typePlace': _nz(ticketDetail['typePlace']) ?? _nz(qrResponse['typePlace']),
          'zoneNom': _nz(ticketDetail['zoneNom']),
          'prix': _nz(ticketDetail['prix']) ?? _nz(qrResponse['prix']),
          'qrCodeBase64': _nz(qrResponse['qrCodeBase64']),
          'valid': validation['valid'],
          'clientNom': validation['clientNom'],
        };
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiErrorString(e);
        _loading = false;
      });
    }
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
        title: Text(AppLocalizations.of(context)!.clientTicketTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTicket,
                        child: Text(AppLocalizations.of(context)!.commonRetry),
                      ),
                    ],
                  ),
                )
              : _qrData == null
                  ? Center(child: Text(AppLocalizations.of(context)!.clientTicketNotFound))
                  : _buildTicket(),
    );
  }

  Widget _buildTicket() {
    final isValid = _qrData!['valid'] as bool? ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.ticketBorder.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isValid ? AppColors.secondary : AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isValid ? Icons.check_circle : Icons.cancel, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            isValid ? AppLocalizations.of(context)!.clientTicketValid : AppLocalizations.of(context)!.clientTicketInvalid,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_qrData!['qrCodeBase64'] != null)
                      _buildQRCode(_qrData!['qrCodeBase64'] as String),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _downloadPDF,
                      icon: const Icon(Icons.download, size: 18),
                      label: Text(AppLocalizations.of(context)!.clientTicketDownloadPDF),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    _infoRow(AppLocalizations.of(context)!.clientTicketEvent, _qrData!['evenementTitre'] ?? 'N/A'),
                    _infoRow(AppLocalizations.of(context)!.clientTicketSeat, displayPlace(_qrData!['placeNumero'] as String?) ?? 'N/A'),
                    if (_qrData!['rang'] != null)
                      _infoRow(AppLocalizations.of(context)!.clientTicketRow, _qrData!['rang']),
                    if (_qrData!['typePlace'] != null)
                      _infoRow(AppLocalizations.of(context)!.clientTicketType, _qrData!['typePlace']),
                    if (_qrData!['zoneNom'] != null)
                      _infoRow(AppLocalizations.of(context)!.clientTicketZone, _qrData!['zoneNom']),
                    if (_qrData!['prix'] != null)
                      _infoRow(AppLocalizations.of(context)!.clientTicketPrice, 'Ar ${_qrData!['prix']}'),
                    if (_qrData!['clientNom'] != null)
                      _infoRow(AppLocalizations.of(context)!.clientTicketHolder, _qrData!['clientNom']),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _qrData!['codeTicket'] ?? '',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDF() async {
    try {
      final response = await dio.get(
        '${Endpoints.tickets}/${widget.ticketCode}/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final data = response.data;
      if (data is! List<int>) {
        throw Exception('Format de réponse invalide');
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/billet_${widget.ticketCode}.pdf');
      await file.writeAsBytes(data);
      if (!mounted) return;
      AdminToast.show(context, message: '${AppLocalizations.of(context)!.clientTicketPdfSaved} ${file.path}', isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException ? _describeDioError(e) : e.toString();
      AdminToast.show(context, message: '${AppLocalizations.of(context)!.clientTicketDownloadFailed} $msg', isSuccess: false);
    }
  }

  String _describeDioError(DioException e) {
    if (e.response != null) {
      return 'Erreur ${e.response!.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Timeout';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Connexion';
    }
    return e.message ?? 'Erreur inconnue';
  }

  Widget _buildQRCode(String base64) {
    try {
      final bytes = base64Decode(base64);
      return Image.memory(bytes, width: 200, height: 200);
    } catch (e) {
      return Container(
        width: 200,
        height: 200,
        color: AppColors.surface,
        child: const Icon(Icons.qr_code, size: 64),
      );
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
