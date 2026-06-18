import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/dio_config.dart';
import '../../core/api/endpoints.dart';
import '../../core/assets/app_colors.dart';
import '../../models/api_wrapper_model.dart';
import '../../models/ticket_model.dart';
import '../../core/utils/error_helper.dart';
import '../../generated/app_localizations.dart';

class ScanPage extends StatefulWidget {
  final int? eventId;

  const ScanPage({super.key, this.eventId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  final MobileScannerController _scannerCtrl = MobileScannerController();
  bool _isProcessing = false;
  TicketValidationResponse? _lastResult;
  String? _errorMessage;
  bool _offlineMode = false;
  Set<String> _cachedCodes = {};
  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _flashAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
    _loadCache();
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final codes = prefs.getStringList('offline_ticket_codes') ?? [];
    _cachedCodes = codes.toSet();
    if (codes.isNotEmpty) _offlineMode = true;
  }

  Future<void> _cacheCodes(List<String> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('offline_ticket_codes', codes);
    _cachedCodes = codes.toSet();
    _offlineMode = true;
  }

  Future<void> _refreshCache(int? eventId) async {
    if (eventId == null) return;
    try {
      final resp = await dio.get('${Endpoints.tickets}/event/$eventId/valid-codes');
      final data = (resp.data['data'] as List?)?.cast<String>() ?? [];
      await _cacheCodes(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${data.length} codes mis en cache pour le mode hors-ligne'), backgroundColor: AppColors.secondary),
        );
      }
    } catch (_) {}
  }

  Future<void> _handleBarcode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _flashCtrl.forward(from: 0.0);

    // Offline check
    if (_offlineMode && _cachedCodes.contains(code)) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _lastResult = TicketValidationResponse(
          valid: true,
          codeTicket: code,
          evenementTitre: '',
          placeNumero: '',
          message: 'Validé hors-ligne',
        );
        _errorMessage = null;
      });
      _isProcessing = false;
      return;
    }
    if (_offlineMode && !_cachedCodes.contains(code) && _cachedCodes.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _lastResult = TicketValidationResponse(
          valid: false,
          codeTicket: code,
          evenementTitre: '',
          placeNumero: '',
          message: 'Code inconnu (hors-ligne)',
        );
        _errorMessage = null;
      });
      _isProcessing = false;
      return;
    }

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
      if (e is SocketException || e.toString().contains('No address') || e.toString().contains('Connection')) {
        // Network error — check cache
        if (_cachedCodes.isEmpty) {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Pas de connexion et aucun code en cache. Scannez un QR de l\'événement pour télécharger le cache.';
            _lastResult = null;
          });
        } else {
          setState(() {
            _errorMessage = 'Erreur réseau — utilisez un QR valide déjà en cache';
            _lastResult = null;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = apiErrorString(e);
          _lastResult = null;
        });
      }
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

  void _scanEventQr(int eventId) {
    _refreshCache(eventId);
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
        title: Text(AppLocalizations.of(context)!.scanTitle),
        actions: [
          if (_offlineMode)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.cloud_off, size: 20, color: Colors.orange.shade300),
            ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_lastResult != null || _errorMessage != null)
              _buildResultBanner()
            else
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
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
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context)!.scanNext),
                    ),
                    if (widget.eventId != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _scanEventQr(widget.eventId!),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Mettre à jour le cache hors-ligne'),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 64, color: Colors.white70),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.scanAlignQr,
                  style: const TextStyle(color: Colors.white70),
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
    return AnimatedBuilder(
      animation: _flashAnim,
      builder: (context, child) {
        final flash = _flashCtrl.isAnimating ? _flashAnim.value * 0.3 : 0.0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: isValid
              ? AppTheme.secondaryColor.withValues(alpha: 0.15 + flash)
              : AppTheme.errorColor.withValues(alpha: 0.15 + flash),
          child: Column(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.cancel,
                size: 64,
                color: isValid ? AppTheme.secondaryColor : AppTheme.errorColor,
              ),
              const SizedBox(height: 12),
              Text(
                isValid ? AppLocalizations.of(context)!.scanValid : AppLocalizations.of(context)!.scanInvalid,
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
      },
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
            Text(AppLocalizations.of(context)!.scanCodeLabel(r.codeTicket), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (r.evenementTitre.isNotEmpty) Text(AppLocalizations.of(context)!.scanEventLabel(r.evenementTitre)),
            if (r.placeNumero.isNotEmpty) Text(AppLocalizations.of(context)!.scanPlaceLabel(r.placeNumero)),
            if (r.clientNom != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Flexible(child: Text(r.clientNom!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}