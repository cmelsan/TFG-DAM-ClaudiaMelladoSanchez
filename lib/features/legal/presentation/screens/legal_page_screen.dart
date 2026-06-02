import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';

class LegalPageScreen extends StatefulWidget {
  const LegalPageScreen({required this.type, super.key});

  final LegalPageType type;

  @override
  State<LegalPageScreen> createState() => _LegalPageScreenState();
}

class _LegalPageScreenState extends State<LegalPageScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 10;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pageData(widget.type);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: WebNavbar(isScrolled: _isScrolled),
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          ColoredBox(
            color: Colors.white,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 64),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Breadcrumb chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTokens.brandPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Información legal',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTokens.brandPrimary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.title,
                        style: GoogleFonts.inter(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF111111),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        page.lastUpdated,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFFE5E7EB), height: 32),
                      for (final section in page.sections) ...[
                        const SizedBox(height: 8),
                        Text(
                          section.title,
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111111),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          section.body,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: const Color(0xFF374151),
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Divider(color: Color(0xFFF3F4F6), height: 1),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const WebFooter(),
        ],
      ),
    );
  }
}

enum LegalPageType {
  legalNotice,
  privacy,
  cookies,
  terms,
  faq,
}

class _PageData {
  const _PageData({
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final List<_SectionData> sections;
}

class _SectionData {
  const _SectionData({required this.title, required this.body});

  final String title;
  final String body;
}

_PageData _pageData(LegalPageType type) {
  switch (type) {
    // ── AVISO LEGAL ─────────────────────────────────────────────────────────
    case LegalPageType.legalNotice:
      return const _PageData(
        title: 'Aviso legal',
        lastUpdated: 'Última actualización: 02 de junio de 2026',
        sections: [
          _SectionData(
            title: '1. Datos identificativos del titular',
            body:
                'En cumplimiento del artículo 10 de la Ley 34/2002, de 11 de julio, de Servicios de la Sociedad de la Información y del Comercio Electrónico (LSSI-CE), se informa que el titular de este sitio web y de la aplicación móvil "Sabor de Casa" es:\n\n'
                '• Denominación: Sabor de Casa\n'
                '• Actividad: Elaboración y venta de comida preparada para llevar, servicio de reparto a domicilio y catering para eventos\n'
                '• Domicilio: Sanlúcar de Barrameda, Cádiz (España)\n'
                '• Correo electrónico: sabordecasasanlucar@gmail.com\n'
                '• Plataformas: Aplicación web (sabordecasa.vercel.app) y aplicación Android disponible como APK',
          ),
          _SectionData(
            title: '2. Objeto y ámbito de aplicación',
            body:
                'El presente Aviso Legal regula el acceso, navegación y uso de la plataforma digital de Sabor de Casa, tanto en su versión web como en su aplicación Android. El mero acceso a la plataforma implica la aceptación plena y sin reservas de las presentes condiciones. Si el usuario no está de acuerdo con alguna de las disposiciones contenidas en este aviso, deberá abstenerse de utilizar la plataforma.',
          ),
          _SectionData(
            title: '3. Condiciones de uso',
            body:
                'El usuario se compromete a hacer un uso lícito, diligente y correcto de la plataforma, conforme a la legislación vigente, a las buenas costumbres y al orden público. Queda expresamente prohibido:\n\n'
                '• Utilizar la plataforma con fines fraudulentos o para actividades ilícitas.\n'
                '• Introducir, almacenar o difundir información falsa, difamatoria, ofensiva o que vulnere derechos de terceros.\n'
                '• Suplantar la identidad de otros usuarios, del establecimiento o de su personal.\n'
                '• Realizar acciones que puedan dañar, inutilizar, sobrecargar o deteriorar la plataforma o sus sistemas informáticos.\n'
                '• Intentar acceder de forma no autorizada a áreas restringidas, sistemas internos o datos de otros usuarios.\n'
                '• Utilizar robots, spiders, scrapers u otros sistemas automatizados para extraer información sin autorización expresa.',
          ),
          _SectionData(
            title: '4. Propiedad intelectual e industrial',
            body:
                'Todos los contenidos de la plataforma —incluyendo, sin carácter limitativo, textos, fotografías, ilustraciones, logotipos, iconos, código fuente, diseño de interfaz, nombres comerciales y marcas— son propiedad de Sabor de Casa o de terceros que han autorizado su uso, y están protegidos por la legislación española e internacional de propiedad intelectual e industrial.\n\n'
                'Queda prohibida la reproducción total o parcial, distribución, comunicación pública, transformación o cualquier otra forma de explotación de dichos contenidos sin autorización expresa y por escrito del titular. El incumplimiento de esta prohibición podrá dar lugar a las acciones legales oportunas.',
          ),
          _SectionData(
            title: '5. Limitación de responsabilidad',
            body:
                'Sabor de Casa se esfuerza por mantener la plataforma operativa y los contenidos actualizados, pero no garantiza la disponibilidad continua ni la ausencia de errores. En consecuencia, Sabor de Casa no será responsable de:\n\n'
                '• Interrupciones o fallos técnicos ajenos a su control (caídas de servidores, ataques informáticos, cortes de suministro eléctrico).\n'
                '• Daños causados por virus u otros elementos tecnológicos introducidos por terceros.\n'
                '• Inexactitudes o desactualizaciones en la información, siempre que no sean imputables a negligencia grave del titular.\n'
                '• El contenido de sitios web de terceros enlazados desde la plataforma.',
          ),
          _SectionData(
            title: '6. Legislación aplicable y jurisdicción',
            body:
                'El presente Aviso Legal se rige por la legislación española. Para cualquier controversia derivada del acceso o uso de la plataforma, las partes se someten, con renuncia expresa a cualquier otro fuero que pudiera corresponderles, a los Juzgados y Tribunales de Sanlúcar de Barrameda o de la ciudad de Cádiz, conforme a lo establecido en la normativa procesal española vigente.',
          ),
        ],
      );

    // ── PRIVACIDAD ───────────────────────────────────────────────────────────
    case LegalPageType.privacy:
      return const _PageData(
        title: 'Política de privacidad',
        lastUpdated: 'Última actualización: 02 de junio de 2026',
        sections: [
          _SectionData(
            title: '1. Responsable del tratamiento',
            body:
                'De conformidad con el Reglamento (UE) 2016/679 del Parlamento Europeo y del Consejo (RGPD) y la Ley Orgánica 3/2018, de 5 de diciembre, de Protección de Datos Personales y Garantía de los Derechos Digitales (LOPDGDD), el responsable del tratamiento de sus datos personales es:\n\n'
                '• Denominación: Sabor de Casa\n'
                '• Correo de contacto: sabordecasasanlucar@gmail.com\n'
                '• Domicilio: Sanlúcar de Barrameda, Cádiz, España',
          ),
          _SectionData(
            title: '2. Datos personales que recabamos',
            body:
                'Según la interacción que mantenga con nuestra plataforma, podemos recabar los siguientes datos:\n\n'
                '• Datos de registro: nombre o alias, dirección de correo electrónico y contraseña (almacenada en formato hash irreversible mediante Supabase Auth).\n'
                '• Datos de pedido: nombre del destinatario, dirección de entrega, número de teléfono de contacto, detalle de productos solicitados, importe y método de pago (solo referencia Stripe, nunca datos de tarjeta en bruto).\n'
                '• Datos de contacto y soporte: nombre, correo electrónico, asunto y contenido del mensaje enviado a través del formulario de contacto.\n'
                '• Datos de suscripción al newsletter: dirección de correo electrónico.\n'
                '• Datos técnicos: dirección IP, tipo de navegador, sistema operativo, páginas visitadas y duración de la sesión, tratados de forma agregada y anonimizada.',
          ),
          _SectionData(
            title: '3. Finalidad y base jurídica del tratamiento',
            body:
                '• Gestión de pedidos online: necesario para la ejecución del contrato de compraventa (art. 6.1.b RGPD).\n'
                '• Procesamiento de pagos: necesario para la ejecución del contrato; los pagos se procesan mediante Stripe, con sus propias políticas de privacidad.\n'
                '• Atención al cliente y soporte: interés legítimo en prestar asistencia postventa y resolver incidencias (art. 6.1.f RGPD).\n'
                '• Newsletter y comunicaciones comerciales: consentimiento explícito del interesado (art. 6.1.a RGPD). Puede retirar su consentimiento en cualquier momento.\n'
                '• Seguridad y prevención del fraude: interés legítimo en proteger la integridad de la plataforma y de sus usuarios (art. 6.1.f RGPD).\n'
                '• Cumplimiento de obligaciones legales: conservación de datos de facturación durante el período legalmente exigido (art. 6.1.c RGPD).',
          ),
          _SectionData(
            title: '4. Plazos de conservación',
            body:
                'Los datos se conservarán durante el tiempo estrictamente necesario para la finalidad para la que fueron recabados y, como mínimo, durante los plazos legalmente establecidos:\n\n'
                '• Datos de facturación y pedidos: 5 años conforme a la Ley 58/2003 General Tributaria.\n'
                '• Comunicaciones y mensajes de soporte: 3 años.\n'
                '• Datos de newsletter: hasta que el interesado solicite la baja o retire su consentimiento.\n'
                '• Datos técnicos anonimizados: sin plazo determinado al no constituir datos personales.',
          ),
          _SectionData(
            title: '5. Destinatarios y transferencias internacionales',
            body:
                'Sus datos no se cederán a terceros salvo obligación legal o necesidad directa para prestar el servicio. Los proveedores de servicio con los que trabajamos actúan como encargados del tratamiento bajo contrato:\n\n'
                '• Supabase Inc. (EE.UU.): infraestructura de base de datos y autenticación. Adherido a mecanismos de transferencia internacional conforme al RGPD (Standard Contractual Clauses).\n'
                '• Stripe Inc. (EE.UU.): procesamiento de pagos, con certificación PCI-DSS nivel 1. Opera bajo sus propias políticas de privacidad.\n'
                '• Brevo SAS (Francia): plataforma de envío de correos transaccionales y newsletter, con servidores en la Unión Europea.\n'
                '• Google Firebase (Google LLC, EE.UU.): envío de notificaciones push, bajo cláusulas contractuales tipo aprobadas por la Comisión Europea.',
          ),
          _SectionData(
            title: '6. Derechos del interesado',
            body:
                'En cualquier momento puede ejercer los siguientes derechos ante el responsable del tratamiento:\n\n'
                '• Acceso: conocer qué datos personales suyos tratamos.\n'
                '• Rectificación: corregir datos inexactos o incompletos.\n'
                '• Supresión ("derecho al olvido"): solicitar la eliminación de sus datos cuando ya no sean necesarios.\n'
                '• Oposición: oponerse al tratamiento basado en interés legítimo.\n'
                '• Limitación: solicitar la suspensión temporal del tratamiento en determinadas circunstancias.\n'
                '• Portabilidad: recibir sus datos en formato estructurado y de uso común.\n'
                '• Retirada del consentimiento: en todo momento, sin que ello afecte a la licitud del tratamiento previo.\n\n'
                'Para ejercer sus derechos, envíe un correo a sabordecasasanlucar@gmail.com indicando el derecho que desea ejercer y adjuntando copia de documento acreditativo de identidad. Responderemos en el plazo máximo de un mes. Si considera que el tratamiento no es conforme a la normativa, puede presentar reclamación ante la Agencia Española de Protección de Datos (www.aepd.es).',
          ),
          _SectionData(
            title: '7. Medidas de seguridad',
            body:
                'Aplicamos medidas técnicas y organizativas adecuadas para garantizar la seguridad de sus datos, incluyendo:\n\n'
                '• Cifrado TLS/HTTPS en todas las comunicaciones entre la app y el servidor.\n'
                '• Contraseñas almacenadas con hash irreversible (bcrypt vía Supabase Auth).\n'
                '• Políticas de seguridad a nivel de fila (Row Level Security) en la base de datos para garantizar que cada usuario solo accede a sus propios datos.\n'
                '• Auditoría de accesos y registros de actividad en el backend.',
          ),
        ],
      );

    // ── COOKIES ──────────────────────────────────────────────────────────────
    case LegalPageType.cookies:
      return const _PageData(
        title: 'Política de cookies',
        lastUpdated: 'Última actualización: 02 de junio de 2026',
        sections: [
          _SectionData(
            title: '1. ¿Qué son las cookies?',
            body:
                'Las cookies son pequeños archivos de texto que un sitio web o aplicación web almacena en el dispositivo del usuario cuando este lo visita. Sirven para recordar preferencias, mantener sesiones activas y recopilar información sobre el comportamiento de navegación con el fin de mejorar la experiencia de uso y, en algunos casos, mostrar contenido personalizado.\n\n'
                'Las cookies pueden ser propias (emitidas por el dominio del sitio web visitado) o de terceros (emitidas por dominios distintos). Según su vigencia, pueden ser de sesión (se eliminan al cerrar el navegador) o persistentes (permanecen durante un período determinado o hasta que el usuario las elimine).',
          ),
          _SectionData(
            title: '2. Cookies utilizadas en esta plataforma',
            body:
                'A continuación se detalla el listado de cookies utilizadas:\n\n'
                '• sb-access-token / sb-refresh-token (Supabase Auth): cookies de sesión de autenticación. Imprescindibles para mantener al usuario autenticado durante su navegación. Duración: sesión o hasta caducidad del token (1 hora / 7 días). Tipo: técnica necesaria.\n\n'
                '• flutter-web-canvaskit-key: cookie técnica que el motor de Flutter Web utiliza para determinar el renderizador a emplear (CanvasKit o HTML). No contiene datos personales. Tipo: técnica necesaria.\n\n'
                '• _stripe_mid / _stripe_sid (Stripe): cookies de la plataforma de pago Stripe, utilizadas para la detección de fraude y la correcta atribución de las sesiones de pago. Duración variable. Tipo: terceros necesarios para el servicio de pago.\n\n'
                '• En la actualidad no utilizamos cookies analíticas de terceros (Google Analytics, Hotjar, etc.). En caso de incorporarlas en el futuro, esta política será actualizada y se solicitará su consentimiento previo.',
          ),
          _SectionData(
            title: '3. Base jurídica',
            body:
                'Las cookies técnicas estrictamente necesarias se instalan sin necesidad de consentimiento previo, al amparo del artículo 22.2 de la Ley 34/2002 (LSSI-CE) y del considerando 25 de la Directiva 2002/58/CE (Directiva ePrivacy), dado que son imprescindibles para la prestación del servicio solicitado por el usuario.\n\n'
                'Las cookies analíticas o de personalización que pudieran incorporarse en el futuro requerirán consentimiento expreso e informado por parte del usuario antes de su instalación.',
          ),
          _SectionData(
            title: '4. ¿Cómo gestionar o eliminar las cookies?',
            body:
                'Puede configurar su navegador para rechazar, eliminar o recibir notificaciones sobre la instalación de cookies. A continuación se indican los enlaces a las instrucciones de los principales navegadores:\n\n'
                '• Google Chrome: Configuración → Privacidad y seguridad → Cookies y otros datos de sitios\n'
                '• Mozilla Firefox: Opciones → Privacidad y seguridad → Cookies y datos del sitio\n'
                '• Microsoft Edge: Configuración → Cookies y permisos del sitio\n'
                '• Safari (macOS/iOS): Preferencias → Privacidad → Gestionar datos de sitios web\n\n'
                'Tenga en cuenta que deshabilitar las cookies técnicas puede impedir el correcto funcionamiento de la autenticación y del proceso de pedido. Sabor de Casa no se hace responsable del mal funcionamiento de la plataforma derivado de la desactivación de cookies necesarias.',
          ),
          _SectionData(
            title: '5. Actualizaciones de esta política',
            body:
                'Sabor de Casa podrá modificar esta Política de Cookies para adaptarla a cambios normativos, técnicos o de negocio. Cuando se produzcan cambios relevantes, se informará al usuario mediante aviso en la plataforma. Se recomienda revisar periódicamente esta página para mantenerse informado.',
          ),
        ],
      );

    // ── TÉRMINOS Y CONDICIONES ───────────────────────────────────────────────
    case LegalPageType.terms:
      return const _PageData(
        title: 'Términos y condiciones',
        lastUpdated: 'Última actualización: 02 de junio de 2026',
        sections: [
          _SectionData(
            title: '1. Aceptación y ámbito',
            body:
                'Los presentes Términos y Condiciones regulan el acceso y la utilización de la plataforma Sabor de Casa y la realización de pedidos a través de ella. Al registrarse o realizar un pedido, el usuario declara haber leído, entendido y aceptado íntegramente estos términos. Si actúa en nombre de una empresa o entidad, declara tener capacidad legal para vincularla.',
          ),
          _SectionData(
            title: '2. Registro y cuenta de usuario',
            body:
                'Para acceder a funcionalidades avanzadas (historial de pedidos, encargos programados, catering, soporte interno), el usuario debe crear una cuenta con un correo electrónico válido y una contraseña segura. El usuario es responsable de mantener la confidencialidad de sus credenciales y de todas las actividades realizadas bajo su cuenta. Ante cualquier uso no autorizado, debe notificarlo de inmediato a sabordecasasanlucar@gmail.com.\n\n'
                'Sabor de Casa se reserva el derecho a suspender o cancelar cuentas que incumplan estos términos, sin perjuicio de las acciones legales que pudieran corresponder.',
          ),
          _SectionData(
            title: '3. Tipos de pedido y disponibilidad',
            body:
                'La plataforma ofrece cuatro modalidades de pedido:\n\n'
                '• Mostrador: pedido presencial o anónimo sin necesidad de registro.\n'
                '• Para llevar / Recogida: el cliente recoge en local. Disponible según horario de apertura.\n'
                '• Domicilio: sujeto a zona de reparto activa y disponibilidad del repartidor. No se garantiza reparto fuera del área de Sanlúcar de Barrameda y sus alrededores inmediatos.\n'
                '• Encargo programado: pedido para fecha futura. Sujeto a confirmación de disponibilidad por parte del equipo.\n\n'
                'Todos los pedidos están sujetos a disponibilidad diaria de platos. Si un producto no estuviera disponible tras confirmar el pedido, el equipo contactará al cliente para ofrecer alternativa o proceder al reembolso.',
          ),
          _SectionData(
            title: '4. Precios, IVA y pagos',
            body:
                'Todos los precios mostrados en la plataforma incluyen el IVA aplicable conforme a la legislación española vigente. Sabor de Casa se reserva el derecho a modificar precios en cualquier momento, sin que ello afecte a pedidos ya confirmados y pagados.\n\n'
                'Los pagos online se procesan mediante Stripe, plataforma certificada PCI-DSS nivel 1. Sabor de Casa no almacena en ningún momento datos de tarjeta bancaria; únicamente retiene una referencia de pago de Stripe. Se aceptan tarjetas de crédito y débito Visa, Mastercard y American Express.',
          ),
          _SectionData(
            title: '5. Cancelaciones y devoluciones',
            body:
                'Dado que los productos son bienes perecederos elaborados bajo demanda, el derecho de desistimiento previsto en el RDL 1/2007 (TRLGDCU) no resulta aplicable conforme a su artículo 103.d.\n\n'
                '• Cancelación antes de preparación: reembolso completo si el equipo puede confirmar que el pedido aún no ha sido procesado en cocina. Contacte a través del formulario de soporte o por teléfono.\n'
                '• Cancelación una vez en preparación: no se emitirá reembolso salvo error imputable a Sabor de Casa (producto equivocado, alérgeno no declarado, etc.).\n'
                '• Producto en mal estado o error en el pedido: el cliente debe comunicarlo dentro de las 2 horas siguientes a la recepción, aportando fotografía como evidencia. Se procederá a la corrección, sustitución o reembolso según el caso.',
          ),
          _SectionData(
            title: '6. Alérgenos e información nutricional',
            body:
                'Sabor de Casa elabora sus productos en una cocina donde se manipulan los 14 alérgenos de declaración obligatoria según el Reglamento (UE) n.º 1169/2011. Aunque se indica la presencia de alérgenos en cada plato, no podemos garantizar la ausencia de trazas de contaminación cruzada.\n\n'
                'Los clientes con alergias o intolerancias graves deben comunicarlo expresamente antes de realizar el pedido, contactando a través del formulario de la plataforma o por teléfono. Sabor de Casa hará lo posible por adaptar la elaboración, pero no puede garantizar la ausencia total de trazas en todos los casos.',
          ),
          _SectionData(
            title: '7. Catering y eventos',
            body:
                'Los servicios de catering están sujetos a condiciones específicas negociadas individualmente con cada cliente. Una solicitud de catering no constituye contrato vinculante hasta que ambas partes hayan firmado el presupuesto correspondiente y se haya abonado el depósito acordado (habitualmente el 30% del importe total). Las condiciones de cancelación del catering se establecerán en el documento de presupuesto firmado.',
          ),
          _SectionData(
            title: '8. Modificaciones y vigencia',
            body:
                'Sabor de Casa podrá modificar los presentes Términos y Condiciones en cualquier momento. Los cambios relevantes se comunicarán mediante aviso en la plataforma con al menos 15 días de antelación. La continuación del uso de la plataforma tras la entrada en vigor de los nuevos términos implicará su aceptación.',
          ),
        ],
      );

    // ── FAQ ──────────────────────────────────────────────────────────────────
    case LegalPageType.faq:
      return const _PageData(
        title: 'Preguntas frecuentes',
        lastUpdated: 'Última actualización: 02 de junio de 2026',
        sections: [
          _SectionData(
            title: '¿Necesito cuenta para hacer un pedido?',
            body:
                'Para pedidos sencillos de mostrador o recogida puedes hacerlo sin registrarte. Sin embargo, para acceder a pedidos a domicilio, encargos programados, historial de pedidos, soporte interno y otras funcionalidades avanzadas, necesitarás crear una cuenta gratuita con tu correo electrónico.',
          ),
          _SectionData(
            title: '¿Cómo realizo un pedido online?',
            body:
                'Accede al menú desde la barra de navegación, selecciona los platos que desees y añádelos al carrito. Cuando estés listo, pulsa el icono del carrito y sigue los pasos del checkout: elige el tipo de pedido (recogida o domicilio), la dirección de entrega si procede, y completa el pago con tarjeta a través de Stripe. Recibirás una confirmación por pantalla y, si tienes cuenta, en tu historial de pedidos.',
          ),
          _SectionData(
            title: '¿Puedo programar un pedido para otro día?',
            body:
                'Sí. La modalidad de Encargo programado te permite indicar la fecha y hora de entrega o recogida con antelación. El equipo de Sabor de Casa revisará la disponibilidad y confirmará el encargo. Es especialmente útil para cumpleaños, eventos familiares o cuando quieres asegurarte de tener tu plato favorito disponible.',
          ),
          _SectionData(
            title: '¿Cuál es la zona de reparto a domicilio?',
            body:
                'El servicio de reparto a domicilio opera dentro de Sanlúcar de Barrameda y zonas limítrofes inmediatas. Al introducir tu dirección de entrega en el checkout, la plataforma verificará automáticamente si está dentro del área de cobertura activa. Para consultas sobre zonas especiales o eventos fuera del área habitual, contacta con nosotros.',
          ),
          _SectionData(
            title: '¿Cuáles son los horarios de atención y reparto?',
            body:
                'Nuestro horario de atención habitual es de lunes a sábado de 9:00 a 21:00 h y domingos de 10:00 a 15:00 h, aunque puede variar en festivos o por causas excepcionales. El servicio a domicilio está activo durante el horario de comidas (12:00–15:30 h) y cenas (19:30–21:30 h). Consulta el horario actualizado en la sección de Inicio de la app.',
          ),
          _SectionData(
            title: '¿Cómo pago? ¿Es seguro?',
            body:
                'Los pagos se realizan mediante Stripe, una de las plataformas de pago más seguras del mundo, con certificación PCI-DSS nivel 1. Aceptamos tarjetas Visa, Mastercard y American Express. Sabor de Casa no almacena en ningún momento los datos de tu tarjeta bancaria; toda la información de pago se procesa directamente en los servidores seguros de Stripe.',
          ),
          _SectionData(
            title: '¿Puedo cancelar o modificar mi pedido?',
            body:
                'Puedes cancelar o modificar tu pedido siempre que aún no haya entrado en preparación en cocina. Para ello, utiliza la sección "Mis pedidos" en tu perfil o contacta de inmediato a través del formulario de soporte o por teléfono. Una vez que el pedido ha comenzado a prepararse, no es posible realizar cambios, aunque en caso de error imputable a Sabor de Casa siempre buscaremos la mejor solución.',
          ),
          _SectionData(
            title: '¿Tenéis opciones para personas con alergias?',
            body:
                'Sí. Cada plato del menú lleva indicados sus alérgenos de declaración obligatoria (gluten, lácteos, huevo, frutos secos, etc.). Además, puedes activar el filtro de alérgenos en el menú para ver solo los platos que se adaptan a tus necesidades. Si tienes una alergia grave, te recomendamos que nos contactes previamente para que el equipo pueda informarte con detalle sobre los procesos de elaboración y la posibilidad de contaminación cruzada.',
          ),
          _SectionData(
            title: '¿Ofrecéis servicio de catering para eventos?',
            body:
                'Sí. Disponemos de un servicio completo de catering para bodas, comuniones, eventos corporativos, reuniones familiares y cualquier tipo de celebración. Puedes solicitar un presupuesto personalizado desde la sección "Catering" de la aplicación, indicando fecha, número de comensales, tipo de servicio y cualquier requerimiento especial. Nos pondremos en contacto contigo en menos de 24 horas.',
          ),
          _SectionData(
            title: '¿Cómo contacto con el soporte si tengo un problema?',
            body:
                'Tienes varias vías de contacto disponibles:\n\n'
                '• Formulario de contacto público: accesible desde la sección "Contacto" de la web, no requiere estar registrado.\n'
                '• Soporte interno (usuarios registrados): disponible en tu perfil de usuario, con seguimiento del estado de tu consulta.\n'
                '• Correo electrónico: sabordecasasanlucar@gmail.com. Respondemos en un plazo máximo de 24 horas en días laborables.',
          ),
          _SectionData(
            title: '¿Cómo doy de baja mi suscripción al newsletter?',
            body:
                'Puedes darte de baja en cualquier momento de dos formas: haciendo clic en el enlace "Darme de baja" que aparece al pie de cada correo del newsletter, o enviando una solicitud a sabordecasasanlucar@gmail.com indicando tu dirección de correo. La baja es efectiva de forma inmediata y no recibirás más comunicaciones.',
          ),
          _SectionData(
            title: '¿Dónde descargo la aplicación Android?',
            body:
                'La aplicación Sabor de Casa para Android está disponible como archivo APK descargable directamente desde nuestro sitio web. Próximamente estará disponible en Google Play Store. Para instalar el APK en tu dispositivo, asegúrate de haber habilitado la opción "Instalar aplicaciones de fuentes desconocidas" en los ajustes de seguridad de Android.',
          ),
        ],
      );
  }
}
