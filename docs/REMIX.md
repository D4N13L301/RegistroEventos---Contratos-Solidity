# Guía de Remix

1. Abrir https://remix.ethereum.org/ (o app.remix.live si se prefiere). Crear workspace `RegistroEventos` y carpetas `contracts`, `tests`.
2. Subir/pegar `contracts/RegistroEventos.sol` y `tests/RegistroEventos_test.sol` conservando las rutas relativas.
3. En Solidity Compiler elegir **0.8.34**, optimizer **Enabled**, runs **200**. Compilar primero `RegistroEventos.sol`, luego el test. Si hay un aviso por una versión de EVM, usar la opción predeterminada compatible del entorno de pruebas; no cambiar el pragma a ciegas.
4. En Deploy & Run elegir **Remix VM**. Seleccionar `RegistroEventosTest`, desplegar y ejecutar, por separado, las cuatro funciones `test...`. Cada una debe completar sin revertir. Esto comprueba lógica en una red simulada.
5. Prueba manual: desplegar `RegistroEventos`. Copiar dirección de la **cuenta B** de Remix. Con **cuenta A** llamar `crearAcuerdo(B, HASH_V1)` y consultar evento para obtener id (primer despliegue id=1). El hash debe ser `bytes32`, por ejemplo `0x` seguido de 64 dígitos hexadecimales; para prueba usar `0x1111111111111111111111111111111111111111111111111111111111111111`.
6. `verificarHash(1,1,HASH_V1)` debe devolver true. Otro hash devuelve false. Cambiar a **cuenta B**: `decidirEntrega(1,1,true)`; verificar estado 2. Probar con cuenta A: debe revertir. Para probar versiones, crear **otro acuerdo** antes de aceptar y registrar v2; la v1 pasa a estado 4 (Reemplazada).
7. Solo después, configurar una wallet dedicada de prueba en **Sepolia**, obtener ETH de prueba desde faucet y seleccionar **Browser Extension / Injected Provider** en Deploy & Run (el nombre puede variar). Revisar que la wallet indique Sepolia y que VALUE sea cero. Aprobar el deploy en la wallet.
8. Guardar dirección desplegada, hash de transacción, compiler/settings y enlace al explorador; no publicar semilla ni clave privada. Sepolia no implica dinero real, aunque las firmas y direcciones siguen siendo públicas.

Nota: la interfaz de Remix cambia; buscar `Solidity Compiler` y `Deploy & Run Transactions` si varían los nombres.
