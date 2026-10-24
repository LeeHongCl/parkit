class FeeStructure {
  final int? freeMinutes;
  final int? baseMinutes;
  final int? baseFee;
  final int? addMinutes;
  final int? addFee;
  final int? dayMaxFee;

  const FeeStructure({
    this.freeMinutes,
    this.baseMinutes,
    this.baseFee,
    this.addMinutes,
    this.addFee,
    this.dayMaxFee,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) => FeeStructure(
        freeMinutes: json['free_minutes'] as int?,
        baseMinutes: json['base_minutes'] as int?,
        baseFee: json['base_fee'] as int?,
        addMinutes: json['add_minutes'] as int?,
        addFee: json['add_fee'] as int?,
        dayMaxFee: json['day_max_fee'] as int?,
      );
}
