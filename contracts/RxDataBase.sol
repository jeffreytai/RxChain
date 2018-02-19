pragma solidity 0.4.20;

interface RxDataBase {

    // Write data
    function registerManufacturer(address _manufacturerAddr, bytes16 _name) external;
    function removeManufacturer(address _manufacturerAddr) external;
    function registerWholesaler(address _wholesalerAddr, bytes16 _name) external;
    function removeWholesaler(address _wholesalerAddr) external;
    function registerPharmacy(address _pharmacyAddr, bytes16 _name) external;
    function removePharmacy(address _pharmacyAddr) external;
    function registerPatient(address _patientAddr) external;
    function removePatient(address _patientAddr) external;
    function registerMedication(
        address manufacturerAddr,
        bytes32 serialNumber,
        uint8 wholesalePrice,
        uint8 pharmacyPrice,
        uint8 patientPrice) external;
    function removeMedication(uint256 medicationId) external;
    function createPrescription(
        uint256 _medicationId,
        address _wholesalerAddr,
        address _pharmacyAddr,
        address _patientAddr,
        uint64 _expirationDate,
        uint64 _manufactureCreationDate,
        uint64 _wholesaleReceiptDate,
        uint64 _pharmacyReceiptDate,
        uint64 _patientReceiptDate) external;
    function removePrescription(uint256 _prescriptionId) external;


    // Read data

}
