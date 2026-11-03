import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/entities/quotation_entity.dart';
import '../../domain/entities/quotation_options.dart';

/// "Estimate to Customer" PDF layout — letterhead, estimate meta grid, item
/// table, cost summary, subsidy notice, terms + signatory block.
class QuotationPdfGenerator {
  QuotationPdfGenerator._();

  // Solar Universe's real brand colors (matches AppColorConstants.
  // secondaryNavy/primary — scraped from the real reference site,
  // thesolaruniverse.vercel.app: forest green + orange). These were
  // previously a navy/red palette scraped from the wrong reference site
  // during an earlier clone and never corrected.
  static final PdfColor _navy = PdfColor.fromInt(0xFF25362E);
  static final PdfColor _navyContainer = PdfColor.fromInt(0xFFE3F0E8);
  static final PdfColor _accent = PdfColor.fromInt(0xFFED7627);
  static final PdfColor _accentLight = PdfColor.fromInt(0xFFFDECDF);
  // The reference "estimate meta" badges use a 3-color system (pink/blue/
  // green), not just navy+orange — matched from the real web-generated PDF
  // the user shared, not guessed.
  static final PdfColor _blue = PdfColor.fromInt(0xFF1A56DB);
  static final PdfColor _blueLight = PdfColor.fromInt(0xFFE8F0FE);
  static final PdfColor _green = PdfColor.fromInt(0xFF1B7A3D);
  static final PdfColor _greenLight = PdfColor.fromInt(0xFFE6F4EA);
  static final PdfColor _amber = PdfColor.fromInt(0xFFB45309);
  static final PdfColor _amberLight = PdfColor.fromInt(0xFFFEF3E0);

  static Future<pw.Document> generate(QuotationEntity quotation) async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final date = DateTime.tryParse(quotation.createdAt) ?? DateTime.now();
    final subsidy = QuotationOptions.subsidyForStored(quotation.solarSystem, quotation.capacity);

    final logoBytes =
        (await rootBundle.load('assets/images/solar_universe_logo.png')).buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);
    // Real authorised-signatory signature, supplied by the user
    // (assets/images/solaruniversesign.jpeg) — printed in the footer's
    // signatory block. Do NOT reuse another company's real seal/signature
    // from elsewhere in this workspace.
    final signatureBytes =
        (await rootBundle.load('assets/images/solaruniversesign.jpeg')).buffer.asUint8List();
    final signatureImage = pw.MemoryImage(signatureBytes);

    // Base14 Helvetica (the pdf package's default) has no ₹ (U+20B9) glyph,
    // so every currency figure rendered as a missing-glyph box. Rather than
    // replace the base font (and lose its bold variant / existing look),
    // Noto Sans is added as a *fallback* — Helvetica keeps rendering
    // everything it already draws correctly, and only glyphs it can't draw
    // (₹) fall back to Noto Sans.
    final notoSansBytes =
        (await rootBundle.load('assets/fonts/NotoSans-Regular.ttf')).buffer.asUint8List();
    final notoSansFont = pw.Font.ttf(notoSansBytes.buffer.asByteData());
    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      fontFallback: [notoSansFont],
    );

    // pw.Page is a fixed single page — content taller than it silently
    // CLIPS at the bottom rather than flowing to a second page (no error,
    // no warning; flutter analyze/build both stay green). The colored
    // badges/selected-brands section added here made the total content
    // taller than one A4 page, so terms 4-5 and the whole signatory block
    // were being cut off entirely. Confirmed by generating the real
    // 2-page reference PDF from the web and comparing — this app's PDF
    // only rendered page 1's worth of content. pw.MultiPage paginates
    // automatically, matching the reference's real page break (terms 1-3
    // on page 1, 4-5 + signature on page 2).
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        build: (context) => [
          _header(logoImage),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 1.4, color: _navy),
          pw.SizedBox(height: 12),
          _customerBanner(quotation),
          pw.SizedBox(height: 14),
          _metaRow(quotation, date),
          pw.SizedBox(height: 18),
          _itemsTable(quotation),
          pw.SizedBox(height: 16),
          _selectedBrands(quotation),
          pw.SizedBox(height: 16),
          _costSummary(quotation, currency, subsidy),
          pw.SizedBox(height: 16),
          _importantNotice(subsidy, currency),
          pw.SizedBox(height: 24),
          _footer(signatureImage),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey400),
          pw.Text(
            'Generated by: ${quotation.preparedBy}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 12),
          _thankYouBanner(),
        ],
      ),
    );

    return doc;
  }

  static pw.Widget _header(pw.MemoryImage logo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: 150),
        pw.SizedBox(
          width: 260,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _officeLine('Office:', '1/60, Vibhav Khand, Gomti Nagar, Lucknow, UP – 226010'),
              _officeLine('Email:', 'asarvindshl1@gmail.com'),
              _officeLine('Call:', '+91 76072 37555'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _officeLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        textAlign: pw.TextAlign.right,
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: '$label ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
            pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 8.5)),
          ],
        ),
      ),
    );
  }

  /// "ESTIMATE TO CUSTOMER" + name, in a bordered/tinted box — matches the
  /// real web-generated PDF (a plain centered heading + name below it was
  /// this app's own earlier guess, not what's actually printed).
  static pw.Widget _customerBanner(QuotationEntity quotation) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _accentLight,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: _accent, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ESTIMATE TO CUSTOMER',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _accent, letterSpacing: 0.6),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            quotation.customerName,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 3 colored badges (pink/blue/green) — matches the real web-generated
  /// PDF exactly; the plain 2-column text list this app printed before was
  /// this app's own guess at "light, colorful," not what the site actually
  /// does.
  static pw.Widget _metaRow(QuotationEntity quotation, DateTime date) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _metaBadge(
            color: _accent,
            bg: _accentLight,
            lines: [_MetaLine('ESTIMATE NO', quotation.quotationNumber)],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _metaBadge(
            color: _blue,
            bg: _blueLight,
            lines: [
              _MetaLine('DATE', DateFormat('d/M/yyyy').format(date)),
              _MetaLine('VALIDITY', '${QuotationOptions.validityDays} Days'),
            ],
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: _metaBadge(
            color: _green,
            bg: _greenLight,
            lines: [
              _MetaLine('SYSTEM / CAPACITY', '${quotation.solarSystem} · ${quotation.capacity}'),
              _MetaLine('', QuotationOptions.subsidyScheme.toUpperCase()),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _metaBadge({
    required PdfColor color,
    required PdfColor bg,
    required List<_MetaLine> lines,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final line in lines) ...[
            if (line.label.isNotEmpty)
              pw.Text(
                line.label,
                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: color),
              ),
            pw.Text(
              line.value,
              style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
            ),
            if (line != lines.last) pw.SizedBox(height: 3),
          ],
        ],
      ),
    );
  }

  // The full component breakdown (Panels, Inverter, Battery, Mounting
  // Structure, DC/AC Wire, Earthing, Lightning Arrestor, ACDB/DCDB,
  // Installation) prints in full here — confirmed against the real
  // web-generated PDF, which lists every item too. An earlier pass of this
  // file filtered this table down to just Panels+Inverter, misreading
  // "shows only the selected panel + inverter brand" as a table filter —
  // it's actually the separate `_selectedBrands` section below, not a
  // change to this table. Reverted.
  static pw.Widget _itemsTable(QuotationEntity quotation) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.6),
      columnWidths: const {
        0: pw.FixedColumnWidth(32),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(3),
        3: pw.FlexColumnWidth(1.3),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _accentLight),
          children: [
            _headCell('SR. NO.'),
            _headCell('COMPONENT / ITEM'),
            _headCell('SPECIFICATION'),
            _headCell('QTY'),
          ],
        ),
        for (var i = 0; i < quotation.items.length; i++)
          pw.TableRow(
            decoration: i.isOdd ? pw.BoxDecoration(color: PdfColors.grey100) : null,
            children: [
              _cell('${i + 1}', center: true),
              _cell(quotation.items[i].item, bold: true),
              _cell(quotation.items[i].spec),
              _cell(quotation.items[i].qty, center: true),
            ],
          ),
      ],
    );
  }

  /// New section, not previously part of this app's PDF — a highlighted
  /// callout naming just the panel + inverter brand (the two components a
  /// customer actually cares about at a glance), separate from the full
  /// itemized table above. Brand names are derived from the same item specs
  /// already in `quotation.items` (`"$brand · $type · $dcr"` etc. — see
  /// `_buildItems()` in `quick_quote_screen.dart`), not a new data field —
  /// no fabricated logo images are shown (the reference PDF's own attempt
  /// to show a panel product photo renders as a broken-image icon there).
  static pw.Widget _selectedBrands(QuotationEntity quotation) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SELECTED EQUIPMENT BRANDS',
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _navy, letterSpacing: 0.5),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _brandChip('SOLAR PANEL', _brandFor(quotation, 'Solar Panels'), _navy, _navyContainer)),
              pw.SizedBox(width: 12),
              pw.Expanded(child: _brandChip('INVERTER', _brandFor(quotation, 'Inverter'), _accent, _accentLight)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _brandChip(String label, String brand, PdfColor color, PdfColor bg) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        pw.SizedBox(height: 3),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(color: bg, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3))),
          child: pw.Text(brand, style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  /// Item specs are built as `"$brand · $type · $dcr"` (see `_buildItems()`
  /// in `quick_quote_screen.dart`) — the brand is always the first segment.
  static String _brandFor(QuotationEntity quotation, String itemName) {
    for (final item in quotation.items) {
      if (item.item == itemName && item.spec.isNotEmpty) {
        return item.spec.split(' · ').first;
      }
    }
    return '—';
  }

  static pw.Widget _headCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false, bool center = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 9),
      ),
    );
  }

  static pw.Widget _costSummary(QuotationEntity quotation, NumberFormat currency, num subsidy) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 270,
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.6)),
        child: pw.Column(
          children: [
            _summaryRow('Project Cost (incl. GST):', currency.format(quotation.price)),
            if (quotation.discount > 0)
              _summaryRow('Discount:', '- ${currency.format(quotation.discount)}'),
            _summaryRow('Final Cost (incl. GST):', currency.format(quotation.finalAmount), highlight: true),
            _summaryRow('Est. Govt. Subsidy:', '- ${currency.format(subsidy)}', isLast: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {bool highlight = false, bool isLast = false}) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: highlight ? _accentLight : null,
        border: isLast
            ? null
            : const pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.6)),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: highlight ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: highlight ? _accent : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _importantNotice(num subsidy, NumberFormat currency) {
    return pw.Container(
      width: double.infinity,
      // No borderRadius here — the `pdf` package asserts a Border must be
      // uniform (Border.all) when borderRadius is set; this is deliberately
      // a left-only accent border, so it stays a plain rectangle.
      decoration: pw.BoxDecoration(
        color: _amberLight,
        border: pw.Border(left: pw.BorderSide(color: _amber, width: 3)),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
          children: [
            pw.TextSpan(
              text: 'Important Notice: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
            ),
            const pw.TextSpan(
              text: 'This price represents gross development costs. Eligible customers can claim up to ',
            ),
            pw.TextSpan(
              text: '${currency.format(subsidy)} Government Subsidy',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            const pw.TextSpan(
              text: ' on On Grid / Hybrid residential applications. Support for liaisoning with '
                  'national solar portals is covered within this proposal.',
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _footer(pw.MemoryImage signature) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('TERMS & CONDITIONS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Divider(color: PdfColors.grey300, height: 1),
              pw.SizedBox(height: 6),
              _term('1.', 'Adjustable but not refundable Registration Fee.'),
              _term('2.', 'This quotation is valid for exactly ${QuotationOptions.validityDays} days from the issue date.'),
              _term('3.', 'Standard installation covers standard roofing up to 100 meters of cable routing.'),
              _term('4.', "Inverter warranty terms are as per manufacturer's specification."),
              _term(
                '5.',
                'Payments should be cleared in favour of the corporate business account details provided '
                    'herewith.',
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('From Solar Universe Enterprises', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Container(
                height: 72,
                alignment: pw.Alignment.bottomRight,
                child: pw.Image(signature, width: 130, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: 140, child: pw.Divider(color: PdfColors.grey600)),
              pw.Text('Authorised Signatory', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('Solar Universe Enterprises', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _thankYouBanner() {
    return pw.Container(
      width: double.infinity,
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: pw.BoxDecoration(
        color: _accentLight,
        border: const pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.6)),
      ),
      child: pw.Text(
        'Thank you for choosing Solar Universe Enterprises — your trusted solar partner.',
        style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
      ),
    );
  }

  static pw.Widget _term(String number, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 14, child: pw.Text(number, style: const pw.TextStyle(fontSize: 8.5))),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 8.5))),
        ],
      ),
    );
  }
}

class _MetaLine {
  final String label;
  final String value;
  const _MetaLine(this.label, this.value);
}
