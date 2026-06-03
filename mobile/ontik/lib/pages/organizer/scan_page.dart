import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../models/api_wrapper_model.dart';
import '../../models/ticket_model.dart';
import '../../core/utils/error_helper.dart';

class ScanPage extends StatefulWidget {
  final int? eventId;

  const ScanPage({super.key, this.eventId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _scannerCtrl = MobileScannerController();
  bool _isProcessing = false;
  TicketValidationResponse? _lastResult;
  String? _errorMessage;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final response = await dio.post(
        Endpoints.ticketValidate,
        queryParameters: {'codeTicket': code},
      );
      final wrapper = ApiWrapper.fromJson(response.data);
      final result = wrapper.getData((d) => TicketValidationResponse.fromJson(d));
      if (!mounted) return;
      setState(() {
        _lastResult = result;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = apiErrorString(e);
        _lastResult = null;
      });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _resetScanner() {
    setState(() {
      _lastResult = null;
      _errorMessage = null;
    });
    _scannerCtrl.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerCtrl.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _scannerCtrl.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_lastResult != null || _errorMessage != null)
            _buildResultBanner()
          else
            Expanded(
              child: MobileScanner(
                controller: _scannerCtrl,
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  if (barcode?.rawValue != null) {
                    _scannerCtrl.stop();
                    _handleBarcode(barcode!.rawValue!);
                  }
                },
                overlayBuilder: (context, constraints) {
                  return _buildScanOverlay(constraints);
                },
              ),
            ),
          if (_lastResult != null || _errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _resetScanner,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Next'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(BoxConstraints constraints) {
    return Stack(
      children: [
        Container(
          color: AppTheme.textPrimary.withValues(alpha: 0.3),
        ),
        Center(
          child: Container(
            width: constraints.maxWidth * 0.7,
            height: constraints.maxWidth * 0.7,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, size: 64, color: Colors.white70),
                SizedBox(height: 8),
                Text(
                  'Align QR code within frame',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultBanner() {
    final isValid = _lastResult?.valid ?? false;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: isValid ? AppTheme.secondaryColor.withValues(alpha: 0.15) : AppTheme.errorColor.withValues(alpha: 0.15),
      child: Column(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            size: 64,
            color: isValid ? AppTheme.secondaryColor : AppTheme.errorColor,
          ),
          const SizedBox(height: 12),
          Text(
            isValid ? 'Valid Ticket' : 'Invalid Ticket',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isValid ? AppTheme.secondaryColor : AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          if (_lastResult != null && _lastResult!.message != null)
            Text(
              _lastResult!.message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isValid ? AppTheme.secondaryColor : AppTheme.errorColor,
              ),
            ),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.errorColor),
            ),
          if (_lastResult != null) ...[
            const SizedBox(height: 16),
            _buildTicketDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketDetails() {
    final r = _lastResult!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${r.codeTicket}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (r.evenementTitre.isNotEmpty) Text('Event: ${r.evenementTitre}'),
            if (r.placeNumero.isNotEmpty) Text('Place: ${r.placeNumero}'),
            if (r.clientNom != null) Text('Client: ${r.clientNom}'),
          ],
        ),
      ),
    );
  }
}
