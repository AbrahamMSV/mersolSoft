class StatusMeta {
  final String title;
  final String description;
  final int? nextStatus;      // null -> sin acción
  final String? cta;          // null -> sin botón
  const StatusMeta({required this.title, required this.description, this.nextStatus, this.cta});
}

// Estados dinámicos (técnico):
// 5 Solicitud refacciones (en proceso)           => sin acción
// 6 Rechazada solicitud                           => acción: volver a solicitar -> 5
// 7 Aprobada refacciones                          => acción: iniciar reparación -> 8
// 8 En reparación                                  => acción: marcar terminada / enviar a aprobación -> 9
// 9 En espera de aprobación                        => sin acción
// 10 Rechazada (post-reparación)                   => acción: reenviar a aprobación -> 9
// 11 Aprobada / concluido                          => sin acción
const Map<int, StatusMeta> kTechStatuses = {
  4: StatusMeta(
    title: 'Solicitar refacciones',
    description: 'Puedes iniciar una solicitud de refacciones.',
    nextStatus: 5,
    cta: 'Solicitar refacciones',
  ),
  5: StatusMeta(
    title: 'Solicitud de refacciones',
    description: 'Tu solicitud está en proceso.',
  ),
  6: StatusMeta(
    title: 'Solicitud rechazada',
    description: 'La solicitud fue rechazada. Puedes volver a solicitar refacciones.',
    nextStatus: 5,
    cta: 'Volver a solicitar refacciones',
  ),
  7: StatusMeta(
    title: 'Refacciones aprobadas',
    description: 'Las refacciones fueron aprobadas. Puedes iniciar reparación.',
    nextStatus: 8,
    cta: 'Iniciar reparación',
  ),
  8: StatusMeta(
    title: 'En reparación',
    description: 'El equipo está en reparación. Marca como terminada para enviar a aprobación.',
    nextStatus: 9,
    cta: 'Marcar reparación terminada',
  ),
  9: StatusMeta(
    title: 'En espera de aprobación',
    description: 'La solicitud fue enviada y está en espera de aprobación.',
  ),
  10: StatusMeta(
    title: 'Rechazada',
    description: 'La aprobación fue rechazada. Puedes reenviar a aprobación.',
    nextStatus: 9,
    cta: 'Reenviar a aprobación',
  ),
  11: StatusMeta(
    title: 'Aprobada',
    description: 'El proceso se concluyó.',
  ),
};

const StatusMeta kNoPermisos = StatusMeta(
  title: 'Sin permisos',
  description: 'No puedes gestionar este estatus desde la app.',
);

StatusMeta metaFor(int? status) => kTechStatuses[status ?? -1] ?? kNoPermisos;
bool hasAction(int? status) => kTechStatuses[status ?? -1]?.nextStatus != null;
