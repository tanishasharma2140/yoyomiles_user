class DailySlotModel {
  int? status;
  String? message;
  String? date;
  Slots? slots;

  DailySlotModel({this.status, this.message, this.date, this.slots});

  DailySlotModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    date = json['date'];
    slots = json['slots'] != null ? Slots.fromJson(json['slots']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['date'] = date;
    if (slots != null) {
      data['slots'] = slots!.toJson();
    }
    return data;
  }
}

class Slots {
  Morning? morning;
  Morning? afternoon;
  Morning? evening;

  Slots({this.morning, this.afternoon, this.evening});

  Slots.fromJson(Map<String, dynamic> json) {
    morning =
    json['Morning'] != null ? Morning.fromJson(json['Morning']) : null;
    afternoon = json['Afternoon'] != null
        ? Morning.fromJson(json['Afternoon'])
        : null;
    evening =
    json['Evening'] != null ? Morning.fromJson(json['Evening']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (morning != null) {
      data['Morning'] = morning!.toJson();
    }
    if (afternoon != null) {
      data['Afternoon'] = afternoon!.toJson();
    }
    if (evening != null) {
      data['Evening'] = evening!.toJson();
    }
    return data;
  }
}

class Morning {
  String? period;
  int? availableTimeStatus;
  String? amToPm;
  List<AvailableSlots>? availableSlots;

  Morning(
      {this.period,
        this.availableTimeStatus,
        this.amToPm,
        this.availableSlots});

  Morning.fromJson(Map<String, dynamic> json) {
    period = json['period'];
    availableTimeStatus = json['available_time_status'];
    amToPm = json['am_to_pm'];
    if (json['available_slots'] != null) {
      availableSlots = <AvailableSlots>[];
      json['available_slots'].forEach((v) {
        availableSlots!.add(AvailableSlots.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['period'] = period;
    data['available_time_status'] = availableTimeStatus;
    data['am_to_pm'] = amToPm;
    if (availableSlots != null) {
      data['available_slots'] =
          availableSlots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvailableSlots {
  int? dailySlotsId;
  int? slotId;
  String? slotName;
  int? maxBookings;
  int? currentBookings;
  int? remaining;

  AvailableSlots(
      {this.dailySlotsId,
        this.slotId,
        this.slotName,
        this.maxBookings,
        this.currentBookings,
        this.remaining});

  AvailableSlots.fromJson(Map<String, dynamic> json) {
    dailySlotsId = json['daily_slots_id'];
    slotId = json['slot_id'];
    slotName = json['slot_name'];
    maxBookings = json['max_bookings'];
    currentBookings = json['current_bookings'];
    remaining = json['remaining'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['daily_slots_id'] = dailySlotsId;
    data['slot_id'] = slotId;
    data['slot_name'] = slotName;
    data['max_bookings'] = maxBookings;
    data['current_bookings'] = currentBookings;
    data['remaining'] = remaining;
    return data;
  }
}
