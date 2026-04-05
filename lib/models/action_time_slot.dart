class ActionTimeSlot {
  final int? id;
  final int? actionId;
  final String startTime;
  final String endTime;
  final String? createdAt;
  final String? updateAt;

  ActionTimeSlot({
    this.id,
    this.actionId,
    required this.startTime,
    required this.endTime,
    this.createdAt,
    this.updateAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action_id': actionId,
      'start_time': startTime,
      'end_time': endTime,
      'created_at': createdAt,
      'update_at': updateAt,
    };
  }

  factory ActionTimeSlot.fromMap(Map<String, dynamic> map) {
    return ActionTimeSlot(
      id: map['id'] as int?,
      actionId: map['action_id'] as int?,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      createdAt: map['created_at'] as String?,
      updateAt: map['update_at'] as String?,
    );
  }
}
