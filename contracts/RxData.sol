pragma solidity ^0.4.17;

import "./RxDataBase.sol";

contract RxData is RxDataBase {

    mapping(address => Manufacturer) public manufacturers;
    mapping(address => Wholesaler) public wholesalers;
    mapping(address => Pharmacy) public pharmacies;
    mapping(address => Patient) public patients;
    mapping(uint256 => Medication) public medications;
    mapping(uint256 => Prescription) public prescriptions;


    modifier onlyManufacturer (address _addr) {
        require (manufacturers[_addr] != 0);
        _;
    }

    modifier onlyPharmacy (address _addr) {
        require (pharmacies[_addr] != 0);
        _;
    }

    modifier onlyPharmacyOrPatient (address _addr) {
        require (pharmacies[_addr] != 0 || patients[_addr] != 0);
        _;
    }

    enum Status {
        MANUFACTURED,
        DISTRIBUTED, // at wholesale
        DISPENSED, // at pharmacy
        SOLD // given to patient
    }

    struct Manufacturer {
        address addr;
        bytes16 name;
    }

    struct Wholesaler {
        address addr;
        bytes16 name;
    }

    struct Pharmacy {
        address addr;
        bytes16 name;
    }

    struct Patient {
        address addr;
    }

    struct Medication {
        // Entity Id for each step in the process, allows for tracking
        uint256 medicationId;
        address manufacturerAddr;
        // Miscellaneous information
        bytes32 serialNumber;
        uint8 wholesalePrice;
        uint8 pharmacyPrice;
        uint8 patientPrice;
    }

    /**
     * TODO: Possibly change sequence ids to keccak hash of timestamp and other information
     */
    struct Prescription {
        uint256 prescriptionId;
        uint256 medicationId;
        // Allows for tracking throughout the process
        address wholesalerAddr;
        address pharmacyAddr;
        address patientAddr;
        // Dates for each step in the process
        uint64 expirationDate;
        uint64 manufactureCreationDate;
        uint64 wholesaleReceiptDate;
        uint64 pharmacyReceiptDate;
        uint64 patientReceiptDate;
    }

    // Implementations of RxDataBase
    function registerManufacturer(address _manufacturerAddr, bytes16 _name) onlyAuthorized public {
        Manufacturer memory m = Manufacturer(_manufacturerAddr, _name);
        manufacturers[_manufacturerAddr] = m;
    }

    function removeManufacturer(address _manufacturerAddr) onlyAuthorized public {
        delete manufacturers[_manufacturerAddr];
    }

    function registerWholesaler(address _wholesalerAddr, bytes16 _name) onlyAuthorized public {
        Wholesaler memory w = Wholesaler(_wholesalerAddr, _name);
        wholesalers[_wholesalerAddr] = w;
    }

    function removeWholesaler(address _wholesalerAddr) onlyAuthorized public {
        delete wholesalers[_wholesalerAddr];
    }

    function registerPharmacy(address _pharmacyAddr, bytes16 _name) onlyAuthorized public {
        Pharmacy memory p = Pharmacy(_pharmacyAddr, _name);
        pharmacies[_pharmacyAddr] = p;
    }

    function removePharmacy(address _pharmacyAddr) onlyAuthorized public {
        delete pharmacies[_pharmacyAddr];
    }

    function registerPatient(address _patientAddr) public {
        Patient memory p = Patient(_patientAddr);
        patients[_patientAddr] = p;
    }

    function removePatient(address _patientAddr) public {
        delete patients[_patientAddr];
    }

    function registerMedication(
        address _manufacturerAddr,
        bytes32 _serialNumber,
        uint8 _wholesalePrice,
        uint8 _pharmacyPrice,
        uint8 _patientPrice) onlyManufacturer public {

        Medication memory m = Medication(
            totalMedication,
            _manufacturerAddr,
            _serialNumber,
            _wholesalePrice,
            _pharmacyPrice,
            _patientPrice);
        medications[totalMedication] = m;

        totalMedication += 1;
    }

    function removeMedication(uint256 medicationId) onlyManufacturer public {
        delete medications[medicationId];
        totalMedication -= 1;
    }

    function createPrescription(
        uint256 _medicationId,
        address _wholesalerAddr,
        address _pharmacyAddr,
        address _patientAddr,
        uint64 _expirationDate,
        uint64 _manufactureCreationDate,
        uint64 _wholesaleReceiptDate,
        uint64 _pharmacyReceiptDate,
        uint64 _patientReceiptDate) onlyPharmacy public {

        // Change this to keccak hash
        uint256 prescriptionId = 1;

        Prescription memory p = Prescription(
            prescriptionId,
            _medicationId,
            _wholesalerAddr,
            _pharmacyAddr,
            _patientAddr,
            _expirationDate,
            _manufactureCreationDate,
            _wholesaleReceiptDate,
            _pharmacyReceiptDate,
            _patientReceiptDate);

        prescriptions[prescriptionId] = p;
    }

    function removePrescription(uint256 _prescriptionId) public onlyPharmacyOrPatient {
        delete prescriptions[_prescriptionId];
    }
}
