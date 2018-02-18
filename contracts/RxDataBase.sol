pragma solidity ^0.4.17;

import "./Ownable.sol";
import "./AccessControl.sol";

contract RxDataBase is Ownable, AccessControl {

    // Member variables
    uint256 totalMedication;

    // Write data
    function registerManufacturer(address _manufacturerAddr, bytes16 _name) onlyAuthorized public;
    function removeManufacturer(address _manufacturerAddr) onlyAuthorized public;
    function registerWholesaler(address _wholesalerAddr, bytes16 _name) onlyAuthorized public;
    function removeWholesaler(address _wholesalerAddr) onlyAuthorized public;
    function registerPharmacy(address _pharmacyAddr, bytes16 _name) onlyAuthorized public;
    function removePharmacy(address _pharmacyAddr) onlyAuthorized public;
    function registerPatient(address _patientAddr) public;
    function removePatient(address _patientAddr) public;
    function registerMedication(
        address manufacturerAddr,
        bytes32 serialNumber,
        uint8 wholesalePrice,
        uint8 pharmacyPrice,
        uint8 patientPrice) onlyManufacturer public;
    function removeMedication(uint256 medicationId) onlyManufacturer public;
    function createPrescription(
        uint256 _medicationId,
        address _wholesalerAddr,
        address _pharmacyAddr,
        address _patientAddr,
        uint64 _expirationDate,
        uint64 _manufactureCreationDate,
        uint64 _wholesaleReceiptDate,
        uint64 _pharmacyReceiptDate,
        uint64 _patientReceiptDate) onlyPharmacy public;
    function removePrescription(uint256 _prescriptionId) public onlyPharmacyOrPatient


    // Read data

}
