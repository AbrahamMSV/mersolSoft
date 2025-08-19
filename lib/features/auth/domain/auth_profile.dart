class AuthProfile {
  final int idUsuario;
  final String login;
  final String nombre;
  final String? puesto;
  final String? rol;
  final int idSucursal;
  final String? sucursal;
  final String? personal;
  final int idIntelisis;
  final String? correo;
  final String? departamento;
  final int? puestoId;
  final String? alias;

  const AuthProfile({
    required this.idUsuario,
    required this.login,
    required this.nombre,
    this.puesto,
    this.rol,
    required this.idSucursal,
    this.sucursal,
    this.personal,
    required this.idIntelisis,
    this.correo,
    this.departamento,
    this.puestoId,
    this.alias,
  });

  factory AuthProfile.fromJson(Map<String, dynamic> j) => AuthProfile(
    idUsuario: (j['Id_Usuario'] ?? 0) as int,
    login: (j['Login'] ?? '') as String,
    nombre: (j['Nombre'] ?? '') as String,
    puesto: j['Puesto'] as String?,
    rol: j['Rol'] as String?,
    idSucursal: (j['Id_Sucursal'] ?? 0) as int,
    sucursal: j['Sucursal'] as String?,
    personal: j['Personal'] as String?,
    idIntelisis: (j['Id_Intelisis'] ?? 0) as int,
    correo: j['Correo'] as String?,
    departamento: j['Departamento'] as String?,
    puestoId: (j['PuestoID'] as num?)?.toInt(),
    alias: j['Alias'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'Id_Usuario': idUsuario,
    'Login': login,
    'Nombre': nombre,
    'Puesto': puesto,
    'Rol': rol,
    'Id_Sucursal': idSucursal,
    'Sucursal': sucursal,
    'Personal': personal,
    'Id_Intelisis': idIntelisis,
    'Correo': correo,
    'Departamento': departamento,
    'PuestoID': puestoId,
    'Alias': alias,
  };
}
