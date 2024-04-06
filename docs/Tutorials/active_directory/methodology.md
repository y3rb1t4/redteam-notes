# Algunas metodologias de AD


## Cómo pasar de Pentester a Red Teamer: Checklist de Quickwins

1. Aprende a programar en C/C++: Domina la creación de cargadores dinámicos de malware y módulos para tus ataques (especialmente en Cobalt Strike).

2. Conoce el registro de eventos y evita dejar rastros: Aprende a logear y borrar evidencias en las máquinas objetivo para operar de forma sigilosa.

3. Desarrolla movimientos laterales discretos: Busca técnicas de movimiento lateral que no sean fáciles de detectar, como DCOM en lugar de métodos convencionales como PsExec o WMIExec.

4. Extracción de volcados de lsass de manera no convencional: Investiga el uso de handles leakeados de lsass para extraer volcados sin alertar a los sistemas de seguridad.

5. Aprovecha BloodHound para identificar objetivos de valor: Utiliza BloodHound no solo para encontrar vulnerabilidades, sino también para identificar servidores relevantes, como servidores MSSQL, mediante la búsqueda de SPNs.

6. Prioriza autenticaciones Kerberos y evita RC4: Utiliza siempre autenticaciones Kerberos y evita el uso de RC4, optando por AES cuando sea posible. Usa credenciales de admin local para reducir la telemetría en el DC.

7. Persitencia sin llamar la atención: Evita dejar rastros sospechosos utilizando técnicas como DLL hijacking en lugar de registros o startups en ubicaciones obvias.

8. Búsqueda de credenciales en las máquinas: Explora el Credential Vault en busca de credenciales, ya que puedes encontrar información valiosa como user:pass de sitios web relevantes, lo que te permitirá moverte lateralmente con facilidad.

9. Usa SOCKS5 para acciones no locales: Cuando realices acciones en máquinas remotas, como accesos SMB, MSSQL, RPC o DCOM, siempre utiliza SOCKS5 para dificultar la detección de actividad maliciosa.

10. Registra tu Command and Control en dominios de alta reputación: Para evitar levantar sospechas, aloja tu Command and Control en dominios de confianza.
Emplea protocolos difíciles de detectar: Utiliza HTTPS o DNS para evitar la detección, aunque ten en cuenta que el uso de DNS puede afectar la velocidad.

11. Exfiltración de archivos de gran tamaño: Sube archivos al SharePoint del objetivo y descárgalos desde tu navegador. Otra opción es subirlos a servicios como Mega.

12. Evita cuentas super administrativas: En lugar de atacar cuentas de Domain Admin o Enterprise Admin, apunta a grupos de cuentas con admin local en varias máquinas.

13. Escoge cuentas activas recientemente: Prefiere pwnear cuentas que hayan tenido actividad reciente, evitando cuentas inactivas durante largos períodos.

14. Escalada por ADCS: Utiliza ADCS como vector de escalada para obtener acceso a cuentas privilegiadas.

15. Persistencia con ADCS: Emplea certificados ADCS para mantener la persistencia en cuentas de dominio privilegiadas, ya que no expiran a menos que sean revocados.

16. Evita crear cuentas privilegiadas: La creación de cuentas administrativas en el dominio es riesgosa y puede llamar la atención.

17. Borra evidencias al salir: Cuando termines tus operaciones en una máquina, borra todas las evidencias, incluyendo el historial del navegador si es necesario.

18. Acceso antes que implantación: Intenta acceder a máquinas a través de RDP u otros métodos antes de implantar tu malware, para reducir las posibilidades de detección.

19. Impacket, tu aliado: Conviértete en un experto en Impacket, una herramienta indispensable en el arsenal de un Red Teamer.

20. Cautela con lsass: Evita tocar lsass a menos que sea estrictamente necesario, ya que suele alertar a los equipos de defensa.

21. Escaneos de BloodHound: Realiza escaneos de BloodHound con la opción "ldaponly" para minimizar el ruido y pasar desapercibido.

22. Practica con Elastic Security: Monta un laboratorio de pruebas con Elastic Security para poner a prueba tus habilidades y mejorar tu metodología.