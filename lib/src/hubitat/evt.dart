import 'dart:convert';

class Evt {
  final int deviceId;
  final String value;
  final int unixTime;
  final String date;
  final String location;
  final String attribute;
  final bool stateChanged;
  Evt({
    this.deviceId,
    this.value,
    this.unixTime,
    this.date,
    this.location,
    this.attribute,
    this.stateChanged,
  });

  Evt copyWith({
    int deviceId,
    String value,
    int unixTime,
    String date,
    String location,
    String attribute,
    bool stateChanged,
  }) {
    return Evt(
      deviceId: deviceId ?? this.deviceId,
      value: value ?? this.value,
      unixTime: unixTime ?? this.unixTime,
      date: date ?? this.date,
      location: location ?? this.location,
      attribute: attribute ?? this.attribute,
      stateChanged: stateChanged ?? this.stateChanged,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'value': value,
      'unixTime': unixTime,
      'date': date,
      'location': location,
      'attribute': attribute,
      'stateChanged': stateChanged,
    };
  }

  static Evt fromMap(Map<String, dynamic> map) {
    if (map == null) return null;
  
    return Evt(
      deviceId: map['deviceId']?.toInt(),
      value: map['value'],
      unixTime: map['unixTime']?.toInt(),
      date: map['date'],
      location: map['location'],
      attribute: map['attribute'],
      stateChanged: map['stateChanged'],
    );
  }

  String toJson() => json.encode(toMap());

  static Evt fromJson(String source) => fromMap(json.decode(source));

  @override
  String toString() {
    return 'Evt(deviceId: $deviceId, value: $value, unixTime: $unixTime, date: $date, location: $location, attribute: $attribute, stateChanged: $stateChanged)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
  
    return o is Evt &&
      o.deviceId == deviceId &&
      o.value == value &&
      o.unixTime == unixTime &&
      o.date == date &&
      o.location == location &&
      o.attribute == attribute &&
      o.stateChanged == stateChanged;
  }

  @override
  int get hashCode {
    return deviceId.hashCode ^
      value.hashCode ^
      unixTime.hashCode ^
      date.hashCode ^
      location.hashCode ^
      attribute.hashCode ^
      stateChanged.hashCode;
  }
}