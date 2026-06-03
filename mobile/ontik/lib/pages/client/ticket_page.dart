import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/services/ticket_service.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../core/utils/error_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    setState(() => _loading = true);
    try {
      final _ticketService = TicketService();
      final qrResponse = await _ticketService.getTicket(widget.ticketCode);
      final validation = await _ticketService.validateTicket(widget.ticketCode);

      if (!mounted) return;
      setState(() {
        _qrData = {
          'codeTicket': qrResponse['codeTicket'],
          'evenementTitre': qrResponse['evenementTitre'],
          'placeNumero': qrResponse['placeNumero'],
          'rang': qrResponse['rang'],
          'typePlace': qrResponse['typePlace'],
          'prix': qrResponse['prix'],
          'qrCodeBase64': qrResponse['qrCodeBase64'],
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
      appBar: AppBar(title: const Text('Ticket')),
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
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _qrData == null
                  ? const Center(child: Text('Ticket not found'))
                  : _buildTicket(),
    );
  }

  Widget _buildTicket() {
    final isValid = _qrData!['valid'] as bool? ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
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
                  child: Text(
                    isValid ? 'VALID' : 'INVALID',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                if (_qrData!['qrCodeBase64'] != null)
                  _buildQRCode(_qrData!['qrCodeBase64'] as String),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _downloadPDF,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Télécharger PDF'),
                ),
                const SizedBox(height: 12),
                const Divider(),
                _infoRow('Event', _qrData!['evenementTitre'] ?? 'N/A'),
                _infoRow('Seat', _qrData!['placeNumero'] ?? 'N/A'),
                if (_qrData!['rang'] != null)
                  _infoRow('Row', _qrData!['rang']),
                if (_qrData!['typePlace'] != null)
                  _infoRow('Type', _qrData!['typePlace']),
                if (_qrData!['prix'] != null)
                  _infoRow('Price', 'Ar ${_qrData!['prix']}'),
                if (_qrData!['clientNom'] != null)
                  _infoRow('Holder', _qrData!['clientNom']),
                const Divider(),
                Text(
                  _qrData!['codeTicket'] ?? '',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPDF() async {
    try {
      await dio.get(
        '${Endpoints.tickets}/${widget.ticketCode}/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF téléchargé'), backgroundColor: AppColors.secondary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e'), backgroundColor: AppColors.error),
      );
    }
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
