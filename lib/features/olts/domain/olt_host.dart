class OltHost {
  final int id;
  final String usuario;
  final String pass;
  final int olt;
  final String ipPublica;

  const OltHost({
    required this.id,
    required this.usuario,
    required this.pass,
    required this.olt,
    required this.ipPublica,
  });

  factory OltHost.fromJson(Map<String, dynamic> json) => OltHost(
    id: json['id'] as int,
    usuario: json['Usuario'] as String,
    pass: json['Pass'] as String,
    olt: json['Olt'] as int,
    ipPublica: json['IpPublica'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'Usuario': usuario,
    'Pass': pass,
    'Olt': olt,
    'IpPublica': ipPublica,
  };
}
