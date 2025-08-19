class ArticuloSuggestion {
  final String articulo;
  final String? descripcion;
  final String? fabricante;
  final int stock;
  final int stockSucursal;

  const ArticuloSuggestion({
    required this.articulo,
    this.descripcion,
    this.fabricante,
    required this.stock,
    required this.stockSucursal,
  });

  factory ArticuloSuggestion.fromJson(Map<String, dynamic> j) => ArticuloSuggestion(
    articulo: (j['Articulo'] ?? '') as String,
    descripcion: j['Descripcion'] as String?,
    fabricante: j['Fabricante'] as String?,
    stock: (j['stock'] ?? 0) as int,
    stockSucursal: (j['stocksucursal'] ?? 0) as int,
  );

  @override
  String toString() => articulo; // para TypeAhead
}
