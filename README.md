# RegistroEventos — contrato inteligente

Implementación inicial del flujo del whitepaper. Solidity **0.8.34**, sin librerías externas. **Probar primero en Remix VM; Sepolia solamente después de revisar los resultados.** Código propuesto, no auditado ni previamente desplegado.

## Carpetas

- `contracts/RegistroEventos.sol`: lógica on-chain.
- `tests/RegistroEventos_test.sol`: pruebas de comportamiento autocontenidas (contrato de prueba con funciones `test...`).
- `docs/REMIX.md`: compilación, prueba manual con dos cuentas y Sepolia.
- `docs/DECISIONES.md`: modelo, límites y relación con el whitepaper.

## API

| Función | Quién | Efecto |
|---|---|---|
| `crearAcuerdo(receptor,hashDocumento)` | emisor | Crea id, versión 1 pendiente |
| `registrarVersion(id,hashDocumento)` | emisor | Nueva versión; marca anterior pendiente como reemplazada |
| `decidirEntrega(id,version,aceptar)` | receptor | Acepta o rechaza versión vigente |
| `obtenerAcuerdo(id)` | cualquiera | Emisor, receptor, fecha, última versión |
| `obtenerEntrega(id,version)` | cualquiera | Hash, fechas, estado |
| `verificarHash(id,version,hashCalculado)` | cualquiera | Compara bytes32 y retorna bool |

Estados: Inexistente=0, Pendiente=1, Aceptada=2, Rechazada=3, Reemplazada=4.

### Importante
- El hash se calcula **fuera** del contrato sobre los bytes exactos del archivo. Usar SHA-256 o keccak256 de manera consistente. No cargar texto legible, nombres ni documentos en la cadena.
- `msg.sender` identifica la cuenta que firmó la transacción, pero **no demuestra por sí solo la identidad civil ni la firma legal**.
- La acción de aceptar expresa una decisión on-chain sobre un hash/version concreto; no prueba lectura efectiva, calidad, disponibilidad del archivo ni contrato legal.
- Una aceptación cierra el acuerdo. Para otra entrega, abrir un acuerdo nuevo.
- No recibe ni transfiere ETH, no utiliza llamadas externas, no requiere `nonReentrant`; esto minimiza superficie de reentrancy en esta versión. Si luego se agregan pagos, rediseñar y auditar.
- La blockchain es pública: los hashes, direcciones, estados y eventos son visibles. Un hash de un documento predecible puede permitir comprobaciones por terceros. No insertar datos personales ni URLs de acceso.

## Validación
Los tests suministrados son autocontenidos. La compilación y ejecución en Remix son pasos a realizar por el usuario: **no se declara que estén aprobados hasta ejecutarlos**. Guardar captura de pruebas y dirección del contrato si se despliega en Sepolia.
