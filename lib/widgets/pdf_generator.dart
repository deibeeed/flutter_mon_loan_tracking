import 'dart:typed_data';

import 'package:flutter_mon_loan_tracking/models/loan.dart';
import 'package:flutter_mon_loan_tracking/models/loan_schedule.dart';
import 'package:flutter_mon_loan_tracking/models/lot.dart';
import 'package:flutter_mon_loan_tracking/models/user.dart';
import 'package:flutter_mon_loan_tracking/utils/constants.dart';
import 'package:flutter_mon_loan_tracking/utils/extensions.dart';
import 'package:flutter_mon_loan_tracking/utils/print_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator {
  static generatePdf({
    required User user,
    required List<LoanSchedule> schedules,
    required Loan loan,
    required Lot lot,
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
          lot: lot,
        );
      },
    );
  }

  static Future<Uint8List> _buildPdf(
      PdfPageFormat format, {
        required User user,
        required List<LoanSchedule> schedules,
        required Loan loan,
        required Lot lot,
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
                    pw.Text('Lot details'),
                    pw.Column(children: [
                      pw.Text(lot.completeBlockLotNo),
                      pw.Text('${lot.area} sqm'),
                      pw.Text(lot.lotCategory),
                      pw.Text(lot.description),
                    ]),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Rate per sqm'),
                    pw.Text(loan.perSquareMeterRate.toCurrency()),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total contract price'),
                    pw.Text(loan.totalContractPrice.toCurrency()),
                  ],
                ),
                for (var deduction in loan.deductions)
                  pw.Row(
                    mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Less: ${deduction.description}'),
                      pw.Text(deduction.discount
                          .toCurrency(isDeduction: true)),
                    ],
                  ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Less: Downpayment'),
                    pw.Text(
                        loan.downPayment.toCurrency(isDeduction: true)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Outstanding balance'),
                    pw.Text(loan.outstandingBalance.toCurrency()),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Transfer fees'),
                    pw.Text(loan.incidentalFees.toCurrency()),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Type'),
                    pw.Text('${loan.yearsToPay} years to pay'),
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
                children: Constants.user_loan_schedule_table_columns
                    .sublist(
                    0,
                    Constants.user_loan_schedule_table_columns
                        .length -
                        1)
                    .map((header) => pw.Container(
                  margin: pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide()
                    )
                  ),
                    width: 120,
                    height: 40,
                    child: pw.Text(header,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center)))
                    .toList(),
              ),
              for (var schedule in schedules)
                pw.TableRow(children: [
                  pw.Text(schedule.date.toDefaultDate()),
                  pw.Text(schedule.outstandingBalance.toCurrency()),
                  pw.Text(schedule.monthlyAmortization.toCurrency()),
                  pw.Text(schedule.principalPayment.toCurrency()),
                  pw.Text(schedule.interestPayment.toCurrency()),
                  pw.Text(schedule.incidentalFee.toCurrency()),
                ]),
            ])
          ];
        },
      ),
    );

    // Build and return the final Pdf file data
    return await doc.save();
  }
}
