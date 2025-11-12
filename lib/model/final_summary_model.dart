class FinalSummaryModel {
  bool? success;
  String? message;
  int? userId;
  int? cityType;
  int? distance;
  String? date;
  PickupPoint? pickupPoint;
  PickupPoint? dropPoint;
  Charges? charges;
  int? totalAmount;
  List<DateBaseAddAmount>? dateBaseAddAmount;

  FinalSummaryModel({
    this.success,
    this.message,
    this.userId,
    this.cityType,
    this.distance,
    this.date,
    this.pickupPoint,
    this.dropPoint,
    this.charges,
    this.totalAmount,
    this.dateBaseAddAmount,
  });

  FinalSummaryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    userId = _parseInt(json['user_id']);
    cityType = _parseInt(json['city_type']);
    distance = _parseInt(json['distance']);
    date = json['date']?.toString();
    pickupPoint = json['pickup_point'] != null
        ? PickupPoint.fromJson(json['pickup_point'])
        : null;
    dropPoint = json['drop_point'] != null
        ? PickupPoint.fromJson(json['drop_point'])
        : null;
    charges = json['charges'] != null ? Charges.fromJson(json['charges']) : null;
    totalAmount = _parseInt(json['total_amount']);
    if (json['date_base_add_amount'] != null) {
      dateBaseAddAmount = <DateBaseAddAmount>[];
      json['date_base_add_amount'].forEach((v) {
        dateBaseAddAmount!.add(DateBaseAddAmount.fromJson(v));
      });
    }
  }

  // Safe integer parsing helper
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['user_id'] = userId;
    data['city_type'] = cityType;
    data['distance'] = distance;
    data['date'] = date;
    if (pickupPoint != null) {
      data['pickup_point'] = pickupPoint!.toJson();
    }
    if (dropPoint != null) {
      data['drop_point'] = dropPoint!.toJson();
    }
    if (charges != null) {
      data['charges'] = charges!.toJson();
    }
    data['total_amount'] = totalAmount;
    if (dateBaseAddAmount != null) {
      data['date_base_add_amount'] =
          dateBaseAddAmount!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PickupPoint {
  int? hasLift;
  int? floors;

  PickupPoint({this.hasLift, this.floors});

  PickupPoint.fromJson(Map<String, dynamic> json) {
    hasLift = _parseInt(json['has_lift']);
    floors = _parseInt(json['floors']);
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['has_lift'] = hasLift;
    data['floors'] = floors;
    return data;
  }
}

class Charges {
  int? normalCharges;
  SingleLayerCharges? singleLayerCharges;
  SingleLayerCharges? multiLayerCharges;
  SingleLayerCharges? unpackingCharges;
  SingleLayerCharges? dismantleReassemblyCharges;

  Charges({
    this.normalCharges,
    this.singleLayerCharges,
    this.multiLayerCharges,
    this.unpackingCharges,
    this.dismantleReassemblyCharges,
  });

  Charges.fromJson(Map<String, dynamic> json) {
    normalCharges = _parseInt(json['normal_charges']);
    singleLayerCharges = json['single_layer_charges'] != null
        ? SingleLayerCharges.fromJson(json['single_layer_charges'])
        : null;
    multiLayerCharges = json['multi_layer_charges'] != null
        ? SingleLayerCharges.fromJson(json['multi_layer_charges'])
        : null;
    unpackingCharges = json['unpacking_charges'] != null
        ? SingleLayerCharges.fromJson(json['unpacking_charges'])
        : null;
    dismantleReassemblyCharges = json['dismantle_reassembly_charges'] != null
        ? SingleLayerCharges.fromJson(json['dismantle_reassembly_charges'])
        : null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['normal_charges'] = normalCharges;
    if (singleLayerCharges != null) {
      data['single_layer_charges'] = singleLayerCharges!.toJson();
    }
    if (multiLayerCharges != null) {
      data['multi_layer_charges'] = multiLayerCharges!.toJson();
    }
    if (unpackingCharges != null) {
      data['unpacking_charges'] = unpackingCharges!.toJson();
    }
    if (dismantleReassemblyCharges != null) {
      data['dismantle_reassembly_charges'] =
          dismantleReassemblyCharges!.toJson();
    }
    return data;
  }
}

class SingleLayerCharges {
  String? heading;
  String? subHeading;
  int? applied;
  int? amount;

  SingleLayerCharges({
    this.heading,
    this.subHeading,
    this.applied,
    this.amount,
  });

  SingleLayerCharges.fromJson(Map<String, dynamic> json) {
    heading = json['heading']?.toString();
    subHeading = json['sub_heading']?.toString();
    applied = _parseInt(json['applied']);
    amount = _parseInt(json['amount']);
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['heading'] = heading;
    data['sub_heading'] = subHeading;
    data['applied'] = applied;
    data['amount'] = amount;
    return data;
  }
}

class DateBaseAddAmount {
  String? date;
  String? label;
  int? applied;
  int? amount;

  DateBaseAddAmount({
    this.date,
    this.label,
    this.applied,
    this.amount,
  });

  DateBaseAddAmount.fromJson(Map<String, dynamic> json) {
    date = json['date']?.toString();
    label = json['label']?.toString();
    applied = _parseInt(json['applied']);
    amount = _parseInt(json['amount']);
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['label'] = label;
    data['applied'] = applied;
    data['amount'] = amount;
    return data;
  }
}