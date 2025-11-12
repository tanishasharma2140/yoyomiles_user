class PackerMoverOrderHistoryModel {
  int? status;
  String? message;
  List<Orders>? orders;

  PackerMoverOrderHistoryModel({this.status, this.message, this.orders});

  PackerMoverOrderHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Orders {
  int? id;
  int? totalQuantity;
  String? totalCharges;
  String? singleLayerCharges;
  String? multiLayerCharges;
  String? unpackingCharges;
  String? dismantleReassemblyCharges;
  String? liftCharges;
  String? pickupAddress;
  int? paymentStatus;
  String? dropAddress;
  String? distance;
  String? senderName;
  int? assignAgentStatus;
  dynamic agentName;
  dynamic agentMobile;
  int? rideStatus;
  String? shiftingDate;
  String? date;
  List<TotalItem>? totalItem;

  Orders(
      {this.id,
        this.totalQuantity,
        this.totalCharges,
        this.singleLayerCharges,
        this.multiLayerCharges,
        this.unpackingCharges,
        this.dismantleReassemblyCharges,
        this.liftCharges,
        this.pickupAddress,
        this.paymentStatus,
        this.dropAddress,
        this.distance,
        this.senderName,
        this.assignAgentStatus,
        this.agentName,
        this.agentMobile,
        this.rideStatus,
        this.shiftingDate,
        this.date,
        this.totalItem});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalQuantity = json['total_quantity'];
    totalCharges = json['total_charges'];
    singleLayerCharges = json['single_layer_charges'];
    multiLayerCharges = json['multi_layer_charges'];
    unpackingCharges = json['unpacking_charges'];
    dismantleReassemblyCharges = json['dismantle_reassembly_charges'];
    liftCharges = json['lift_charges'];
    pickupAddress = json['pickup_address'];
    paymentStatus = json['payment_status'];
    dropAddress = json['drop_address'];
    distance = json['distance'];
    senderName = json['sender_name'];
    assignAgentStatus = json['assign_agent_status'];
    agentName = json['agent_name'];
    agentMobile = json['agent_mobile'];
    rideStatus = json['ride_status'];
    shiftingDate = json['shifting_date'];
    date = json['date'];
    if (json['total_item'] != null) {
      totalItem = <TotalItem>[];
      json['total_item'].forEach((v) {
        totalItem!.add(TotalItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['total_quantity'] = totalQuantity;
    data['total_charges'] = totalCharges;
    data['single_layer_charges'] = singleLayerCharges;
    data['multi_layer_charges'] = multiLayerCharges;
    data['unpacking_charges'] = unpackingCharges;
    data['dismantle_reassembly_charges'] = dismantleReassemblyCharges;
    data['lift_charges'] = liftCharges;
    data['pickup_address'] = pickupAddress;
    data['payment_status'] = paymentStatus;
    data['drop_address'] = dropAddress;
    data['distance'] = distance;
    data['sender_name'] = senderName;
    data['assign_agent_status'] = assignAgentStatus;
    data['agent_name'] = agentName;
    data['agent_mobile'] = agentMobile;
    data['ride_status'] = rideStatus;
    data['shifting_date'] = shiftingDate;
    data['date'] = date;
    if (totalItem != null) {
      data['total_item'] = totalItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TotalItem {
  int? id;
  String? packerName;
  String? packerAndMoverTypeName;
  int? quantity;

  TotalItem(
      {this.id, this.packerName, this.packerAndMoverTypeName, this.quantity});

  TotalItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packerName = json['packer_name'];
    packerAndMoverTypeName = json['packer_and_mover_type_name'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['packer_name'] = packerName;
    data['packer_and_mover_type_name'] = packerAndMoverTypeName;
    data['quantity'] = quantity;
    return data;
  }
}
