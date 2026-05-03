import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/api/v1/order_api.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/models/user.dart';
import 'package:shared_le_transporteur/services/notification_service.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final OrderApi _orderApi = OrderApi();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0, locale: 'fr_FR');

  Future<void> generateAndShareReport(BuildContext context, {required bool isCourier}) async {
    try {
      final user = await ApiClient().user;
      if (user == null) throw Exception("Session expirée");

      NotificationService().showSuccess("Génération du rapport en cours...");

      List<Commande> orders;
      final userId = user.id ?? "";
      if (isCourier) {
        orders = await _orderApi.getOrdersByCourier(userId);
      } else {
        orders = await _orderApi.getOrdersByClient(userId);
      }

      final pdf = pw.Document();
      
      // Load Font for UTF-8 support
      final font = await PdfGoogleFonts.poppinsRegular();
      final fontBold = await PdfGoogleFonts.poppinsBold();
      
      // Load Logo
      final logoData = await rootBundle.load('packages/shared_le_transporteur/assets/images/logo_le_transporteur_orange.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Define Theme Colors
      const PdfColor primaryColor = PdfColor.fromInt(0xFFFF6B00);
      const PdfColor secondaryColor = PdfColor.fromInt(0xFF333333);
      const PdfColor lightGrey = PdfColor.fromInt(0xFFF5F5F5);

      // Calculations
      double totalAmount = 0;
      int completedCount = 0;
      int cancelledCount = 0;
      
      for (var order in orders) {
        final status = order.status.toLowerCase();
        if (status.contains('livree') || status.contains('delivered') || status.contains('completed')) {
          completedCount++;
          totalAmount += order.finalPrice ?? order.estimatedPrice ?? 0;
        } else if (status.contains('annul')) {
          cancelledCount++;
        }
      }

      double earnings = isCourier ? totalAmount * 0.3 : totalAmount;
      double platformFees = isCourier ? totalAmount * 0.7 : 0;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          header: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logoImage, width: 120),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('RAPPORT D\'ACTIVITÉ', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                  pw.Text('Généré le ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ],
              ),
            ],
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text('Page ${context.pageNumber} sur ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ),
          build: (context) => [
            pw.SizedBox(height: 20),
            
            // User Information Section
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Utilisateur : ${user.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text('Email : ${user.email}', style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('Rôle : ${isCourier ? 'Livreur' : 'Client'}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('ID : ${userId.length > 8 ? userId.substring(0, 8) : userId}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),
            pw.Text('Résumé des Statistiques', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 12),

            // Summary Cards Grid-like
            pw.Row(
              children: [
                _buildSummaryCard('Total Courses', '$completedCount', primaryColor),
                pw.SizedBox(width: 16),
                _buildSummaryCard(
                  isCourier ? 'Mes Gains (30%)' : 'Total Dépensé',
                  _currencyFormat.format(earnings),
                  PdfColors.green,
                ),
                if (isCourier) ...[
                  pw.SizedBox(width: 16),
                  _buildSummaryCard('Frais Service (70%)', _currencyFormat.format(platformFees), PdfColors.orange),
                ],
              ],
            ),

            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                _buildSummaryCard('Taux de Réussite', '${completedCount > 0 ? ((completedCount / (completedCount + cancelledCount)) * 100).toInt() : 100}%', PdfColors.blue),
                pw.SizedBox(width: 16),
                _buildSummaryCard('Annulations', '$cancelledCount', PdfColors.red),
              ],
            ),

            pw.SizedBox(height: 32),
            pw.Text('Historique Récent', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
            pw.SizedBox(height: 8),

            // Table of Orders
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: secondaryColor),
                  children: [
                    _buildTableCell('Date', isHeader: true),
                    _buildTableCell('Départ', isHeader: true),
                    _buildTableCell('Arrivée', isHeader: true),
                    _buildTableCell('Montant', isHeader: true),
                    _buildTableCell('Statut', isHeader: true),
                  ],
                ),
                // Table Rows
                ...orders.take(20).map((order) {
                  final status = order.getDisplayStatus();
                  return pw.TableRow(
                    children: [
                      _buildTableCell(_dateFormat.format(order.dateCreation)),
                      _buildTableCell(order.pickupAddress?.street ?? order.pickup.adresse),
                      _buildTableCell(order.deliveryAddress?.street ?? order.livraison.adresse),
                      _buildTableCell(_currencyFormat.format(order.finalPrice ?? order.estimatedPrice ?? 0)),
                      _buildTableCell(status),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 40),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 1),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'Note : Ce rapport est généré automatiquement par l\'application Le Transporteur. Les revenus indiqués sont basés sur les courses finalisées et confirmées dans le système.',
                style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        ),
      );

      // Print/Share the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Rapport_${isCourier ? 'Livreur' : 'Client'}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

    } catch (e) {
      debugPrint("Error generating report: $e");
      NotificationService().showError("Échec de la génération du rapport : $e");
    }
  }

  pw.Widget _buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(left: pw.BorderSide(color: color, width: 4)),
          color: PdfColors.white,
          boxShadow: const [
            pw.BoxShadow(color: PdfColors.grey100, blurRadius: 2, offset: PdfPoint(0, 2)),
          ],
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          color: isHeader ? PdfColors.white : PdfColors.black,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
