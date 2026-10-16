class CustomerInfo {
  final String fullName;
  final int tableNumber;
  final String comment;

  const CustomerInfo({
    required this.fullName,
    required this.tableNumber,
    this.comment = '',
  });

  @override
  String toString() =>
      'CustomerInfo(fullName: $fullName, tableNumber: $tableNumber, comment: $comment)';
}
