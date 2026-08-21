import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../domain/entities/group.dart';
import '../../domain/entities/group_split.dart';
import '../providers/group_split_providers.dart';
import '../services/group_pdf_report_service.dart';

class GroupPdfExportButton extends ConsumerStatefulWidget {
  const GroupPdfExportButton({required this.group, super.key});

  final Group group;

  @override
  ConsumerState<GroupPdfExportButton> createState() =>
      _GroupPdfExportButtonState();
}

class _GroupPdfExportButtonState extends ConsumerState<GroupPdfExportButton> {
  static const GroupPdfReportService _reportService = GroupPdfReportService();

  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<GroupSplit>> splitsAsync = ref.watch(
      groupSplitsProvider(widget.group.id),
    );

    return OutlinedButton.icon(
      key: const Key('export_group_pdf_button'),
      onPressed: _isExporting || splitsAsync.isLoading
          ? null
          : () {
              unawaited(_export(splitsAsync));
            },
      icon: _isExporting
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.picture_as_pdf_outlined),
      label: Text(_isExporting ? 'Generating PDF...' : 'Export PDF report'),
    );
  }

  Future<void> _export(AsyncValue<List<GroupSplit>> splitsAsync) async {
    final List<GroupSplit>? splits = splitsAsync.value;

    if (splits == null) {
      _showMessage('Unable to load group expenses.');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final Uint8List bytes = await _reportService.buildReport(
        group: widget.group,
        splits: splits,
      );

      await Printing.layoutPdf(
        name: '${widget.group.name} Report',
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } on Object catch (error) {
      if (mounted) {
        _showMessage('Unable to generate PDF: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
