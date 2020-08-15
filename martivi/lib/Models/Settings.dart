class Settings {
  bool stopOrdering;
  double maximumOrderPrice;
  double minimumOrderPrice;
  double deliveryFeeUnderMaximumOrderPrice;
  Settings();
  Map<String, dynamic> toJson() {
    return {
      'stopOrdering': stopOrdering,
      'maximumOrderPrice': maximumOrderPrice,
      'minimumOrderPrice': minimumOrderPrice,
      'deliveryFeeUnderMaximumOrderPrice': deliveryFeeUnderMaximumOrderPrice
    };
  }

  Settings.fromJson(Map<String, dynamic> json) {
    stopOrdering = json['stopOrdering'] as bool;
    maximumOrderPrice = (json['maximumOrderPrice'] as num)?.toDouble();
    minimumOrderPrice = (json['minimumOrderPrice'] as num)?.toDouble();
    deliveryFeeUnderMaximumOrderPrice =
        (json['deliveryFeeUnderMaximumOrderPrice'] as num)?.toDouble();
  }
}
