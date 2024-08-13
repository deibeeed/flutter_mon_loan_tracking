import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static generatePdf({
    User? user,
    required List<LoanSchedule> schedules,
    required Loan loan,
  }) {
    Printing.layoutPdf(
      // [onLayout] will be called multiple times
      // when the user changes the printer or printer settings
      onLayout: (PdfPageFormat format) {
        // Any valid Pdf document can be returned here as a list of int
        return _buildPdf(
          format,
          user: user,
          schedules: schedules,
          loan: loan,
        );
      },
    );
  }

  static Future<Uint8List> _buildPdf(
      PdfPageFormat format, {
        User? user,
        required List<LoanSchedule> schedules,
        required Loan loan,
      }) async {
    final pdfTheme = pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
        boldItalic: await PdfGoogleFonts.robotoBoldItalic(),
        italic: await PdfGoogleFonts.robotoItalic(),
        icons: await PdfGoogleFonts.robotoRegular()
    );
    // Create the Pdf documentf
    final pw.Document doc = pw.Document(
        theme: pdfTheme
    );
    printd('pageFormat: $format');
    // final finalFormat = format.copyWith(marginLeft: 1.0 * PdfPageFormat.cm);

    // Add one page with centered text "Hello World"
    // pw.Partitions
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return [
            pw.Container(
              // width: format.availableWidth * 0.3,
              child: pw.Column(children: [
                if (user != null)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Name'),
                      pw.Text(user.completeName),
                    ],
                  ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total contract price'),
                    pw.Text(loan.amount.toCurrency()),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Interest rate'),
                    pw.Text('${loan.loanInterestRate}%'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Type'),
                    pw.Text('${loan.monthsToPay} years to pay'),
                  ],
                ),
              ]),
            ),
            pw.SizedBox(
              height: 32,
            ),
            pw.Table( children: [
              pw.TableRow(
                repeat: true,
                children: Constants.loan_schedule_table_columns
                    .sublist(
                    0,
                    Constants.loan_schedule_table_columns
                        .length -
                        1)
                    .map((header) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide()
                    )
                  ),
                    width: header.toLowerCase() == 'month' ? 80 : 120,
                    height: 40,
                    child: pw.Text(header,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center)))
                    .toList(),
              ),
              // for (var schedule in schedules)
              //   pw.TableRow(children: [
              //     pw.Text(schedule.date.toDefaultDate()),
              //     pw.Text(schedule.outstandingBalance.toCurrency()),
              //     pw.Text(schedule.monthlyAmortization.toCurrency()),
              //     pw.Text(schedule.principalPayment.toCurrency()),
              //     pw.Text(schedule.interestPayment.toCurrency()),
              //     pw.Text(schedule.incidentalFee.toCurrency()),
              //   ]),
              ...schedules.mapIndexed((index, schedule) => pw.TableRow(children: [
                pw.Text('${index + 1}'),
                pw.Text(schedule.date.toDefaultDate()),
                pw.Text(schedule.outstandingBalance.toCurrency()),
                pw.Text(schedule.monthlyAmortization.toCurrency()),
                pw.Text(schedule.principalPayment.toCurrency()),
                pw.Text(schedule.interestPayment.toCurrency()),
              ])).toList(),
            ])
          ];
        },
      ),
    );

    // Build and return the final Pdf file data
    return await doc.save();
  }
}
