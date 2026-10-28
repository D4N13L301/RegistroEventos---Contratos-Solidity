// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

/**
 * @title RegistroEventos
 * @notice Registro verificable de versiones de entregas digitales y decisiones del receptor.
 * @dev Nunca almacena el documento, nombres, URLs, datos personales ni claves privadas.
 *      El hash SHA-256 o keccak256 del documento se calcula FUERA de la cadena;
 *      ambas partes deben usar exactamente el mismo algoritmo y los mismos bytes.
 *      No certifica lectura, recepción fuera de cadena, autoría ni validez legal.
 */
contract RegistroEventos {
    enum Estado { Inexistente, Pendiente, Aceptada, Rechazada, Reemplazada }

    struct Acuerdo {
        address emisor;
        address receptor;
        uint64 creadoEn;
        uint32 ultimaVersion;
        bool existe;
    }

    struct Entrega {
        bytes32 hashDocumento;
        uint64 registradaEn;
        uint64 decididaEn;
        Estado estado;
    }

    uint256 public siguienteId = 1;
    mapping(uint256 => Acuerdo) private acuerdos;
    mapping(uint256 => mapping(uint32 => Entrega)) private entregas;

    error DireccionInvalida();
    error HashInvalido();
    error AcuerdoInexistente();
    error SoloEmisor();
    error SoloReceptor();
    error VersionInvalida();
    error AcuerdoFinalizado();
    error EntregaNoPendiente();
    error EtherNoAceptado();

    event AcuerdoCreado(uint256 indexed id, address indexed emisor, address indexed receptor);
    event EntregaRegistrada(uint256 indexed id, uint32 indexed version, bytes32 hashDocumento, uint64 momento);
    event EntregaReemplazada(uint256 indexed id, uint32 indexed versionAnterior, uint32 indexed versionNueva);
    event EntregaDecidida(uint256 indexed id, uint32 indexed version, address indexed receptor, Estado estado, uint64 momento);

    /** @notice Abre un acuerdo y registra su primera versión. Emisor = msg.sender. */
    function crearAcuerdo(address receptor, bytes32 hashDocumento) external returns (uint256 id) {
        if (receptor == address(0) || receptor == msg.sender) revert DireccionInvalida();
        if (hashDocumento == bytes32(0)) revert HashInvalido();

        id = siguienteId++;
        acuerdos[id] = Acuerdo(msg.sender, receptor, uint64(block.timestamp), 1, true);
        entregas[id][1] = Entrega(hashDocumento, uint64(block.timestamp), 0, Estado.Pendiente);
        emit AcuerdoCreado(id, msg.sender, receptor);
        emit EntregaRegistrada(id, 1, hashDocumento, uint64(block.timestamp));
    }

    /** @notice Emisor registra otra versión; la pendiente anterior queda reemplazada.
     *          Una aceptación es final: este acuerdo ya no admite versiones nuevas.
     */
    function registrarVersion(uint256 id, bytes32 hashDocumento) external returns (uint32 version) {
        Acuerdo storage a = acuerdos[id];
        if (!a.existe) revert AcuerdoInexistente();
        if (msg.sender != a.emisor) revert SoloEmisor();
        if (hashDocumento == bytes32(0)) revert HashInvalido();
        Entrega storage anterior = entregas[id][a.ultimaVersion];
        if (anterior.estado == Estado.Aceptada) revert AcuerdoFinalizado();
        if (anterior.estado == Estado.Pendiente) {
            anterior.estado = Estado.Reemplazada;
            anterior.decididaEn = uint64(block.timestamp);
        }
        version = a.ultimaVersion + 1; // checked arithmetic
        a.ultimaVersion = version;
        entregas[id][version] = Entrega(hashDocumento, uint64(block.timestamp), 0, Estado.Pendiente);
        emit EntregaReemplazada(id, version - 1, version);
        emit EntregaRegistrada(id, version, hashDocumento, uint64(block.timestamp));
    }

    /** @notice Solo el receptor decide sobre la versión más reciente, si está pendiente. */
    function decidirEntrega(uint256 id, uint32 version, bool aceptar) external {
        Acuerdo storage a = acuerdos[id];
        if (!a.existe) revert AcuerdoInexistente();
        if (msg.sender != a.receptor) revert SoloReceptor();
        if (version != a.ultimaVersion) revert VersionInvalida();
        Entrega storage e = entregas[id][version];
        if (e.estado != Estado.Pendiente) revert EntregaNoPendiente();
        e.estado = aceptar ? Estado.Aceptada : Estado.Rechazada;
        e.decididaEn = uint64(block.timestamp);
        emit EntregaDecidida(id, version, msg.sender, e.estado, e.decididaEn);
    }

    function obtenerAcuerdo(uint256 id) external view returns (Acuerdo memory) {
        if (!acuerdos[id].existe) revert AcuerdoInexistente();
        return acuerdos[id];
    }

    function obtenerEntrega(uint256 id, uint32 version) external view returns (Entrega memory) {
        Acuerdo storage a = acuerdos[id];
        if (!a.existe) revert AcuerdoInexistente();
        if (version == 0 || version > a.ultimaVersion) revert VersionInvalida();
        return entregas[id][version];
    }

    /** @notice Compara el hash proporcionado con el registrado, sin consultar archivos externos. */
    function verificarHash(uint256 id, uint32 version, bytes32 hashCalculado) external view returns (bool) {
        Acuerdo storage a = acuerdos[id];
        if (!a.existe) revert AcuerdoInexistente();
        if (version == 0 || version > a.ultimaVersion) revert VersionInvalida();
        return entregas[id][version].hashDocumento == hashCalculado;
    }

    receive() external payable { revert EtherNoAceptado(); }
    fallback() external payable { revert EtherNoAceptado(); }
}
