// shared/lib/api/v1/order_api.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_le_transporteur/api/v1/api_client.dart';
import 'package:shared_le_transporteur/models/commande.dart';
import 'package:shared_le_transporteur/models/courier_review.dart';

class OrderApi {
  final ApiClient _client = ApiClient();

  Future<List<Commande>> getAvailableOrders() async {
    final response = await _client.get('/api/v1/order/available');
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => Commande.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Commande>> getAllOrders() async {
    final response = await _client.get('/api/v1/order/orders');
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => Commande.fromJson(e)).toList();
    }
    return [];
  }

  Future<Commande> createOrder(Map<String, dynamic> orderData) async {
    final response = await _client.post('/api/v1/order/', orderData);
    final data = jsonDecode(response.body);
    return Commande.fromJson(data);
  }

  Future<Commande> updateOrderStatus(String orderId, String status) async {
    final response = await _client.patch('/api/v1/order/$orderId/status', {
      'status': status,
    });
    final data = jsonDecode(response.body);
    return Commande.fromJson(data);
  }

  Future<List<Commande>> getOrdersByCourier(String userId) async {
    final response = await _client.get('/api/v1/order/user/$userId');
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => Commande.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Commande>> getOrdersByClient(String clientId) async {
    final response = await _client.get('/api/v1/order/client/$clientId');
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((e) => Commande.fromJson(e)).toList();
    }
    return [];
  }

  Future<Commande> getOrderById(String orderId) async {
    final response = await _client.get('/api/v1/order/$orderId');
    final data = jsonDecode(response.body);
    return Commande.fromJson(data);
  }

  Future<void> claimOrder(String orderId) async {
    await _client.patch('/api/v1/order/$orderId/claim', {});
  }

  Future<void> cancelOrderByCourier(String orderId, String reason) async {
    await _client.patch('/api/v1/order/$orderId/cancel-by-courier', {
      'reason': reason,
    });
  }

  Future<void> cancelOrderByClient(String orderId) async {
    await _client.patch('/api/v1/order/$orderId/cancel-by-client', {});
  }

  Future<CourierReview> reviewOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    final response = await _client.post('/api/v1/order/$orderId/review', {
      'rating': rating,
      'comment': comment,
    });
    final data = jsonDecode(response.body);
    return CourierReview.fromJson(data);
  }

  // Negotiation Endpoints
  Future<void> proposePrice(String orderId, double amount) async {
    await _client.patch('/api/v1/negotiation/$orderId/propose', {
      'amount': amount,
    });
  }

  Future<void> confirmPrice(String orderId, double amount, String paymentMethod) async {
    final payload = {
      'amount': amount,
      'method': paymentMethod,
      'paymentMethod': paymentMethod,
      'payment_method': paymentMethod,
    };
    debugPrint("DEBUG [confirmPrice] Payload: $payload");
    await _client.patch('/api/v1/negotiation/$orderId/confirm', payload);
  }





  Future<void> validatePrice(String orderId) async {

    await _client.patch('/api/v1/order/$orderId/validate-price', {});
  }

  Future<void> adminOverride(String orderId, double amount) async {
    await _client.patch('/api/v1/negotiation/$orderId/override', {
      'amount': amount,
    });
  }

  Future<Map<String, dynamic>?> getNegotiation(String orderId) async {
    try {
      final response = await _client.get('/api/v1/negotiation/$orderId');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching negotiation: $e");
    }
    return null;
  }
}


