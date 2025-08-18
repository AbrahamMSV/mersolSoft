class User {
  final int id;
  final String usuario;
  final String pass;
  final int olt;
  final String ipPublica;

  const User({
    required this.id,
    required this.usuario,
    required this.pass,
    required this.olt,
    required this.ipPublica,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    usuario: json['Usuario'],
    pass: json['Pass'],
    olt: json['Olt'],
    ipPublica: json['IpPublica'],
  );

  Map<String, dynamic> toJson() => {'id': id, 'Usuario': usuario, 'Pass': pass,'Olt':olt,'IpPublica':ipPublica};
}
