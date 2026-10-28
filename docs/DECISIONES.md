# Decisiones del diseño

**Participantes:** emisor y receptor, direcciones diferentes. No hay administrador privilegiado.

**Unidad de registro:** un acuerdo (id) con versiones numeradas secuencialmente. Cada versión tiene un hash y su estado. Solo el emisor registra o reemplaza una versión; solo el receptor decide sobre la última pendiente. Una versión aceptada finaliza el acuerdo. Versiones reemplazadas permanecen consultables.

**On-chain:** direcciones, hashes bytes32, números de versión, marcas de tiempo del bloque, estados, eventos. **Off-chain:** documento original, entrega del archivo, almacenamiento, comprobación de identidad, consentimiento legal, cálculo del hash.

**Sin oráculos ni IPFS obligatorios:** el contrato no necesita datos externos para hacer sus transiciones; IPFS sería una opción futura de distribución, no una garantía de persistencia. No afirmar que IPFS está implementado.

**Riesgos:** claves perdidas (no hay recuperación administrativa); privacidad (datos públicos); autoría e identidad no verificadas; disponibilidad off-chain fuera de alcance; costes de gas variables; colisiones criptográficas teóricamente posibles; aceptación solo constancia técnica, no certificación legal. Sin funciones payable ni llamadas externas: reentrancy no tiene un punto de entrada útil en esta implementación.

**Posibles mejoras futuras:** firma EIP-712 sobre términos y versión; expiraciones; política de cancelación; múltiples documentos por acuerdo; cifrado y gestión de accesos; front-end MetaMask; pruebas más amplias; revisión externa de seguridad. No implementadas.
