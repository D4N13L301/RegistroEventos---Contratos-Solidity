// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import "../contracts/RegistroEventos.sol";

contract ActorReceptor {
    function decidir(RegistroEventos r, uint256 id, uint32 version, bool aceptar) external {
        r.decidirEntrega(id, version, aceptar);
    }
}

// Pruebas autocontenidas: ejecutar funciones test... desde Remix VM (cada una despliega su instancia).
// Si una condición falla, revierte con un mensaje.
contract RegistroEventosTest {
    bytes32 constant H1 = keccak256("documento v1");
    bytes32 constant H2 = keccak256("documento v2");

    function testCrearYVerificar() external {
        RegistroEventos r = new RegistroEventos();
        ActorReceptor receptor = new ActorReceptor();
        uint256 id = r.crearAcuerdo(address(receptor), H1);
        require(id == 1, "id");
        RegistroEventos.Acuerdo memory a = r.obtenerAcuerdo(id);
        require(a.emisor == address(this) && a.receptor == address(receptor), "partes");
        require(a.ultimaVersion == 1, "version");
        require(r.verificarHash(id, 1, H1), "hash esperado");
        require(!r.verificarHash(id, 1, H2), "hash diferente");
    }

    function testSoloReceptorPuedeDecidirYAceptacionFinal() external {
        RegistroEventos r = new RegistroEventos();
        ActorReceptor receptor = new ActorReceptor();
        uint256 id = r.crearAcuerdo(address(receptor), H1);
        (bool unauthorized,) = address(r).call(abi.encodeCall(r.decidirEntrega, (id, uint32(1), true)));
        require(!unauthorized, "emisor no debe decidir");
        receptor.decidir(r, id, 1, true);
        RegistroEventos.Entrega memory e = r.obtenerEntrega(id, 1);
        require(e.estado == RegistroEventos.Estado.Aceptada, "aceptacion");
        (bool repeated,) = address(receptor).call(abi.encodeCall(receptor.decidir, (r, id, uint32(1), false)));
        require(!repeated, "no doble decision");
        (bool newVersion,) = address(r).call(abi.encodeCall(r.registrarVersion, (id, H2)));
        require(!newVersion, "aceptacion final");
    }

    function testReemplazoInvalidaDecisionAnterior() external {
        RegistroEventos r = new RegistroEventos();
        ActorReceptor receptor = new ActorReceptor();
        uint256 id = r.crearAcuerdo(address(receptor), H1);
        uint32 v2 = r.registrarVersion(id, H2);
        require(v2 == 2, "version 2");
        RegistroEventos.Entrega memory vieja = r.obtenerEntrega(id, 1);
        require(vieja.estado == RegistroEventos.Estado.Reemplazada, "reemplazo");
        (bool oldVersion,) = address(receptor).call(abi.encodeCall(receptor.decidir, (r, id, uint32(1), true)));
        require(!oldVersion, "version vieja");
        receptor.decidir(r, id, 2, false);
        RegistroEventos.Entrega memory rechazada = r.obtenerEntrega(id, 2);
        require(rechazada.estado == RegistroEventos.Estado.Rechazada, "rechazo");
        require(r.registrarVersion(id, H1) == 3, "revision tras rechazo");
    }

    function testEntradasInvalidasYNoEther() external {
        RegistroEventos r = new RegistroEventos();
        (bool zeroRecipient,) = address(r).call(abi.encodeCall(r.crearAcuerdo, (address(0), H1)));
        require(!zeroRecipient, "receptor cero");
        (bool samePerson,) = address(r).call(abi.encodeCall(r.crearAcuerdo, (address(this), H1)));
        require(!samePerson, "mismas partes");
        ActorReceptor receptor = new ActorReceptor();
        (bool zeroHash,) = address(r).call(abi.encodeCall(r.crearAcuerdo, (address(receptor), bytes32(0))));
        require(!zeroHash, "hash cero");
        (bool nonexistent,) = address(r).call(abi.encodeCall(r.verificarHash, (uint256(99), uint32(1), H1)));
        require(!nonexistent, "acuerdo inexistente");
    }
}
