class SaveSelectedItemModel {
  bool? status;
  String? message;
  int? insertedItems;
  int? updatedItems;
  int? deletedItems;
  String? totalItems; // Yeh string hai API response mein
  Data? data;

  SaveSelectedItemModel({
    this.status,
    this.message,
    this.insertedItems,
    this.updatedItems,
    this.deletedItems,
    this.totalItems, // String rahega
    this.data,
  });

  SaveSelectedItemModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    insertedItems = _parseInt(json['inserted_items']);
    updatedItems = _parseInt(json['updated_items']);
    deletedItems = _parseInt(json['deleted_items']);
    totalItems = json['total_items']?.toString(); // String hi rahega
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  // Helper method for safe integer parsing
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['inserted_items'] = insertedItems;
    data['updated_items'] = updatedItems;
    data['deleted_items'] = deletedItems;
    data['total_items'] = totalItems;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
class Data {
  int? userId;
  int? cityType;
  int? distance;
  PickupPoint? pickupPoint;
  PickupPoint? dropPoint;
  List<SelectedItems>? selectedItems;

  Data({
    this.userId,
    this.cityType,
    this.distance,
    this.pickupPoint,
    this.dropPoint,
    this.selectedItems,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userId = _parseInt(json['user_id']);
    cityType = _parseInt(json['city_type']);
    distance = _parseInt(json['distance']);
    pickupPoint = json['pickup_point'] != null
        ? PickupPoint.fromJson(json['pickup_point'])
        : null;
    dropPoint = json['drop_point'] != null
        ? PickupPoint.fromJson(json['drop_point'])
        : null;
    if (json['selected_items'] != null) {
      selectedItems = <SelectedItems>[];
      json['selected_items'].forEach((v) {
        selectedItems!.add(SelectedItems.fromJson(v));
      });
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['city_type'] = cityType;
    data['distance'] = distance;
    if (pickupPoint != null) {
      data['pickup_point'] = pickupPoint!.toJson();
    }
    if (dropPoint != null) {
      data['drop_point'] = dropPoint!.toJson();
    }
    if (selectedItems != null) {
      data['selected_items'] = selectedItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PickupPoint {
  int? hasLift;
  int? floors;

  PickupPoint({this.hasLift, this.floors});

  PickupPoint.fromJson(Map<String, dynamic> json) {
    hasLift = Data._parseInt(json['has_lift']);
    floors = Data._parseInt(json['floors']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['has_lift'] = hasLift;
    data['floors'] = floors;
    return data;
  }
}

class SelectedItems {
  int? packerAndMoverTypeId;
  int? quantity;

  SelectedItems({this.packerAndMoverTypeId, this.quantity});

  SelectedItems.fromJson(Map<String, dynamic> json) {
    packerAndMoverTypeId = Data._parseInt(json['packer_and_mover_type_id']);
    quantity = Data._parseInt(json['quantity']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['packer_and_mover_type_id'] = packerAndMoverTypeId;
    data['quantity'] = quantity;
    return data;
  }
}