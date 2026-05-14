import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
enum PlanType { workout, diet, general }
enum PlanStatus { pending, accepted, rejected, completed }

class AIPlanModel {
  final String id;
  final String userId;
  final PlanType type;
  final String title;
  final String content; // Markdown content
  final PlanStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final Map<String, dynamic>? metadata;

  AIPlanModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.status = PlanStatus.pending,
    required this.createdAt,
    this.acceptedAt,
    this.metadata,
  });

  factory AIPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIPlanModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: PlanType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PlanType.general,
      ),
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      status: PlanStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PlanStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null 
          ? (data['acceptedAt'] as Timestamp).toDate() 
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'content': content,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'metadata': metadata,
    };
  }

  AIPlanModel copyWith({
    String? id,
    PlanStatus? status,
    DateTime? acceptedAt,
  }) {
    return AIPlanModel(
      id: id ?? this.id,
      userId: userId,
      type: type,
      title: title,
      content: content,
      status: status ?? this.status,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      metadata: metadata,
    );
  }

  String get statusLabel {
    switch (status) {
      case PlanStatus.pending: return 'Pending';
      case PlanStatus.accepted: return 'Active';
      case PlanStatus.rejected: return 'Declined';
      case PlanStatus.completed: return 'Completed';
    }
  }

  Color get statusColor {
    switch (status) {
      case PlanStatus.pending: return Colors.orange;
      case PlanStatus.accepted: return Colors.green;
      case PlanStatus.rejected: return Colors.red;
      case PlanStatus.completed: return Colors.blue;
    }
  }
}