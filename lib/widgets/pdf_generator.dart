import 'dart:typed_data';

import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static generatePdf() {
    Printing.layoutPdf(
      // [onLayout] will be called multiple times
      // when the user changes the printer or printer settings
      onLayout: (PdfPageFormat format) {
        // Any valid Pdf document can be returned here as a list of int
        return _buildPdf(format);
      },
    );
  }

  static Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    // Create the Pdf documentf
    final pw.Document doc = pw.Document();
    printd('pageFormat: $format');
    final finalFormat = format.copyWith(marginLeft: 1.0 * PdfPageFormat.cm);

    // Add one page with centered text "Hello World"
    doc.addPage(
      pw.Page(
        pageFormat: finalFormat,
        build: (pw.Context context) {
          return pw.ConstrainedBox(
            constraints: pw.BoxConstraints.tightForFinite(),
            child: pw.Container(
              color: PdfColors.cyan,
              child: pw.Table(border: pw.TableBorder.all(), children: [
                pw.TableRow(
                  children: Constants.user_loan_schedule_table_columns
                      .map((header) => pw.Container(
                    width: 120,
                    child: pw.Text(header,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center)
                  ))
                      .toList(),
                ),
                for (int i = 0; i < 4000; i++)
                for (int i = 0; i < 4000; i++)
                  pw.TableRow(children: [
                    pw.Text('content 1'),
                    pw.Text('content 1'),
                    pw.Text('content 2'),
                    pw.Text('content 3'),
                    pw.Text('content 1'),
                    pw.Text('content 1'),
                    pw.Text('content 1'),
                  ]),
              ]),
            ),
          );
        },
      ),
    );

    // Build and return the final Pdf file data
    return await doc.save();
  }
}
