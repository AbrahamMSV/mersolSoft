class PageResult<T> {
  final List<T> items;
  final int recordsTotal;
  final int recordsFiltered;

  const PageResult({
    required this.items,
    required this.recordsTotal,
    required this.recordsFiltered,
  });
}
