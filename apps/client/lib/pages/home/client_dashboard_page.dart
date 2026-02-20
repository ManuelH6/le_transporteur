import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_le_transporteur/core/app_dimensions.dart';
import 'package:shared_le_transporteur/core/app_theme.dart';
import 'package:shared_le_transporteur/services/mock_database.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'new_order_form_page.dart';

class ClientDashboardPage extends StatefulWidget {
  const ClientDashboardPage({super.key});

  @override
  State<ClientDashboardPage> createState() => _ClientDashboardPageState();
}

class _ClientDashboardPageState extends State<ClientDashboardPage> {
  final MockDatabase _db = MockDatabase();
  List<Commande> _commandesActives = [];

  @override
  void initState() {
    super.initState();
    _db.genererDonneesInitiales();
    _chargerCommandes();
  }

  void _chargerCommandes() {
    setState(() {
      _commandesActives = _db.getCommandesClient();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Le Transporteur', style: TextStyle(fontSize: AppDimensions.fontLg)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: AppDimensions.iconMd),
            onPressed: _chargerCommandes,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, Manuel 👋',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: AppDimensions.paddingSm),
                  Text(
                    'Prêt pour une nouvelle expédition ?',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppDimensions.paddingLg),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Livraison Simple',
                          subtitle: 'Envoyer un colis',
                          icon: Icons.local_shipping_outlined,
                          color: AppTheme.primaryColor,
                          onTap: () => _navigateToNewOrder(context, 'livraison'),
                        ),
                      ),
                      SizedBox(width: AppDimensions.paddingMd),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Achat & Livraison',
                          subtitle: 'On achète pour vous',
                          icon: Icons.shopping_cart_outlined,
                          color: AppTheme.secondaryColor,
                          onTap: () => _navigateToNewOrder(context, 'achat'),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppDimensions.paddingXl),
                  Text(
                    'Vos courses en cours',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.paddingSm),
                ],
              ),
            ),
          ),
          
          _commandesActives.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingXl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 64.w, color: AppTheme.textSecondary.withOpacity(0.5)),
                        SizedBox(height: AppDimensions.paddingMd),
                        Text('Aucune course en cours', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cmd = _commandesActives[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd, vertical: AppDimensions.paddingSm / 2),
                      child: _buildCommandeCard(cmd),
                    );
                  },
                  childCount: _commandesActives.length,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingSm),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(icon, color: Colors.white, size: AppDimensions.iconLg),
            ),
            SizedBox(height: AppDimensions.paddingMd),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandeCard(Commande cmd) {
    Color statusColor = AppTheme.secondaryColor;
    if (cmd.statut == 'Terminée' || cmd.statut == 'Livré') statusColor = AppTheme.successColor;
    if (cmd.statut == 'Disponible') statusColor = AppTheme.primaryColor;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSm, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    cmd.statut.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: AppDimensions.fontXs, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  cmd.type == 'achat' ? '🛒 Achat' : '📦 Livraison',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: AppDimensions.fontXs, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.paddingMd),
            Text(
              cmd.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppDimensions.fontMd),
            ),
            SizedBox(height: AppDimensions.paddingSm),
            Row(
              children: [
                Icon(Icons.location_on, size: AppDimensions.iconSm, color: AppTheme.primaryColor),
                SizedBox(width: AppDimensions.paddingSm),
                Expanded(child: Text(cmd.livraison.adresse, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            SizedBox(height: AppDimensions.paddingMd),
            Divider(height: 1),
            SizedBox(height: AppDimensions.paddingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cmd.prixFinal != null ? 'Prix fixé :' : 'Prix suggéré :',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: AppDimensions.fontSm),
                ),
                Text(
                  cmd.prixFinal != null 
                    ? '\${cmd.prixFinal?.toInt()} FCFA'
                    : '\${cmd.prixSuggere[0].toInt()} - \${cmd.prixSuggere[1].toInt()} FCFA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontMd, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNewOrder(BuildContext context, String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewOrderFormPage(type: type)),
    );
    _chargerCommandes(); // Refund active orders
  }
}
