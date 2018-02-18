pragma solidity ^0.4.17;

import "./Ownable.sol";
import "./AccessControl.sol";

contract RxDataBase is Ownable, AccessControl {

    // Member variables
    uint256 totalMedication;

    // Write data
    function registerManufacturer(address _manufacturerAddr, string _name) onlyAuthorized public;
    function removeManufacturer(address _manufacturerAddr) onlyAuthorized public;
    function registerWholesaler(address _wholesalerAddr, string _name) onlyAuthorized public;
    function removeWholesaler(address _wholesalerAddr) onlyAuthorized public;
    function registerPharmacy(address _pharmacyAddr, string _name) onlyAuthorized public;
    function removePharmacy(address _pharmacyAddr) onlyAuthorized public;
    function registerPatient(address _patientAddr) public;
    function removePatient(address _patientAddr) public;
    function registerMedication(
        address manufacturerAddr,
        address wholesalerAddr,
        uint64 expirationDate,
        uint64 manufactureCreationDate,
        uint64 wholesaleReceiptDate,
        bytes32 serialNumber,
        uint8 wholesalePrice,
        uint8 pharmacyPrice,
        uint8 patientPrice) onlyManufacturer public;

    // Read data
}
