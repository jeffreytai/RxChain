pragma solidity 0.4.19;

import "./RxDataBase.sol";
import "./AccessControl.sol";
import "./SafeMath.sol";

contract RxData is RxDataBase, AccessControl {

    // Member variables
    uint256 totalMedication;

    // Entity mappings
    mapping(address => Manufacturer) public manufacturers;
    mapping(address => Wholesaler) public wholesalers;
    mapping(address => Pharmacy) public pharmacies;
    mapping(address => Patient) public patients;
    mapping(uint256 => Medication) public medications;
    mapping(uint256 => Prescription) public prescriptions;
    mapping(address => uint256) public balances;

    // Events
    event LogDepositReceived(address _from, uint256 _value);

    // Modifiers for access control
    modifier onlyManufacturer (address _addr) {
        require (manufacturers[_addr].addr != address(0));
        _;
    }

    modifier onlyPharmacy (address _addr) {
        require (pharmacies[_addr].addr != address(0));
        _;
    }

    modifier onlyPharmacyOrPatient (address _addr) {
        require (pharmacies[_addr].addr != address(0) || patients[_addr].addr != address(0));
        _;
    }

    enum PrescriptionStatus {
        AT_MANUFACTURER,
        AT_WHOLESALE,
        AT_PHARMACY,
        WITH_PATIENT
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
        PrescriptionStatus prescriptionStatus;
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
    function registerManufacturer(address _manufacturerAddr, bytes16 _name) onlyAuthorized external {
        Manufacturer memory m = Manufacturer(_manufacturerAddr, _name);
        manufacturers[_manufacturerAddr] = m;
    }

    function removeManufacturer(address _manufacturerAddr) onlyAuthorized external {
        delete manufacturers[_manufacturerAddr];
    }

    function registerWholesaler(address _wholesalerAddr, bytes16 _name) onlyAuthorized external {
        Wholesaler memory w = Wholesaler(_wholesalerAddr, _name);
        wholesalers[_wholesalerAddr] = w;
    }

    function removeWholesaler(address _wholesalerAddr) onlyAuthorized external {
        delete wholesalers[_wholesalerAddr];
    }

    function registerPharmacy(address _pharmacyAddr, bytes16 _name) onlyAuthorized external {
        Pharmacy memory p = Pharmacy(_pharmacyAddr, _name);
        pharmacies[_pharmacyAddr] = p;
    }

    function removePharmacy(address _pharmacyAddr) onlyAuthorized external {
        delete pharmacies[_pharmacyAddr];
    }

    function registerPatient(address _patientAddr) external {
        Patient memory p = Patient(_patientAddr);
        patients[_patientAddr] = p;
    }

    function removePatient(address _patientAddr) external {
        delete patients[_patientAddr];
    }

    function registerMedication(
        address _manufacturerAddr,
        bytes32 _serialNumber,
        uint8 _wholesalePrice,
        uint8 _pharmacyPrice,
        uint8 _patientPrice) onlyManufacturer(msg.sender) external {

        Medication memory m = Medication(
            totalMedication,
            _manufacturerAddr,
            _serialNumber,
            _wholesalePrice,
            _pharmacyPrice,
            _patientPrice);
        medications[totalMedication] = m;

        // Increment counter for the total number of medications
        totalMedication += 1;
    }

    function removeMedication(uint256 medicationId) onlyManufacturer(msg.sender) external {
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
        uint64 _patientReceiptDate) onlyPharmacy(msg.sender) external {

        // Change this to keccak hash
        uint256 prescriptionId = 1;

        Prescription memory p = Prescription(
            prescriptionId,
            _medicationId,
            PrescriptionStatus.AT_MANUFACTURER,
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

    function removePrescription(uint256 _prescriptionId) external onlyPharmacyOrPatient(msg.sender) {
        delete prescriptions[_prescriptionId];
    }

    /**
     * Identify payment sender and check that the payment amount is correct
     */
    function acknowledgeReceipt(uint256 _prescriptionId) public payable stopInEmergency returns (bool) {
        Prescription storage p = prescriptions[_prescriptionId];
        Medication memory med = medications[p.medicationId];

        uint256 paymentAmount = msg.value;

        // Wholesaler received prescription from manufacturer
        if (p.prescriptionStatus == PrescriptionStatus.AT_MANUFACTURER && wholesalers[msg.sender].addr != address(0)) {
            // Confirm sufficient payment
            require(paymentAmount < med.wholesalePrice);

            // Update prescription information
            p.wholesalerAddr = msg.sender;
            upgradeStatus(_prescriptionId);

            // Update manufacturer's balance with wholesale price
            balances[med.manufacturerAddr] += med.wholesalePrice;

            // Refund difference for any extra payment
            if (paymentAmount > med.wholesalePrice) {
                balances[msg.sender] += SafeMath.sub(paymentAmount, med.wholesalePrice);
            }

            return true;
        }
        // Pharmacy received prescription from wholesaler
        else if (p.prescriptionStatus == PrescriptionStatus.AT_WHOLESALE && pharmacies[msg.sender].addr != address(0)) {
            // Confirm sufficient payment
            require(paymentAmount < med.pharmacyPrice);

            // Update prescription information
            p.pharmacyAddr = msg.sender;
            upgradeStatus(_prescriptionId);

            // Update wholesaler's balance with pharmacy price
            balances[p.wholesalerAddr] += med.pharmacyPrice;

            // Refund difference for any extra payment
            if (paymentAmount > med.pharmacyPrice) {
                balances[msg.sender] += SafeMath.sub(paymentAmount, med.pharmacyPrice);
            }

            return true;
        }
        // Patient received prescription from pharmacy
        else if (p.prescriptionStatus == PrescriptionStatus.AT_PHARMACY && patients[msg.sender].addr != address(0)) {
            // Confirm sufficient payment
            require(paymentAmount < med.patientPrice);

            // Update prescription information
            p.patientAddr = msg.sender;
            upgradeStatus(_prescriptionId);

            // Update pharmacy's balance with patient price
            balances[p.pharmacyAddr] += med.patientPrice;

            // Refund difference for any extra payment
            if (paymentAmount > med.patientPrice) {
                balances[msg.sender] += SafeMath.sub(paymentAmount, med.patientPrice);
            }

            return true;
        }

        /**
         * No action was taken, could be a variety of reasons:
         * -Payment sender is not registered as any entity (manufacturer, wholesaler, pharmacy, or patient)
         * -Payment sender and current prescription status is not compatible. E.g. patient cannot be sending money when the prescription is still at the manufacturer
         */
        return false;
    }

    /**
     * Upgrade status of Prescription
     */
    function upgradeStatus(uint256 _prescriptionId) internal {
        Prescription storage p = prescriptions[_prescriptionId];

        // Mark the PrescriptionStatus as the next status
        p.prescriptionStatus = PrescriptionStatus(uint(p.prescriptionStatus) + 1);
    }

    function getPrescriptionStatus(uint256 _prescriptionId) view external returns (bytes32) {
        Prescription memory p = prescriptions[_prescriptionId];

        if (p.prescriptionStatus == PrescriptionStatus.AT_MANUFACTURER) {
            return "At Manufacturer";
        }
        else if (p.prescriptionStatus == PrescriptionStatus.AT_WHOLESALE) {
            return "At Wholesale";
        }
        else if (p.prescriptionStatus == PrescriptionStatus.AT_PHARMACY) {
            return "At Pharmacy";
        }
        else {
            return "With Patient";
        }
    }


    /**
     * Withdraw current ether balance to sender if exists
     */
    function withdraw() public {
        uint256 balance = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(balance);
    }

    /**
     * Fallback function to accept ether sent to this contract
     */
    function () payable public {
        LogDepositReceived(msg.sender, msg.value);
    }
}
