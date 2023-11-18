// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthRecord {

    // Data structures
    struct Patient {
        uint256 id;
        string name;
        string dob;
        address currentHospitalAddress; // Address of the hospital currently managing the record
        mapping(uint256 => bool) consent; // Patient consent for medical records
    }

    struct Doctor {
        uint256 id;
        string name;
        string specialization;
        address hospitalAddress; // Address of the hospital the doctor is associated with
    }

    struct MedicalRecord {
        uint256 id;
        string diagnosis;
        string treatmentPlan;
        string ipfsHash; // Hash of the medical record file stored on IPFS
        uint256 patientId;
        address doctorAddress;
    }

    // Mappings for storing patients, doctors, and medical records
    mapping(uint256 => Patient) public patients;
    mapping(address => Doctor) public doctors;
    mapping(uint256 => MedicalRecord) public medicalRecords;

    modifier onlyDoctorOrAdmin() {
        require(isDoctor(msg.sender) || isAdmin(msg.sender), "Unauthorized user");
        _;
    }

    modifier patientConsented(uint256 patientId) {
        require(patients[patientId].consent[msg.sender], "Patient consent not given");
        _;
    }


    // Events for tracking record creation, updates, and transfers
    event RecordAdded(uint256 recordId, string ipfsHash);
    event RecordUpdated(uint256 recordId, string ipfsHash);
    event RecordTransferred(uint256 recordId, address previousHospital, address newHospital);

    // Function to register a patient
    function registerPatient(uint256 id, string memory name, string memory dob, address hospitalAddress) public {
        require(!isPatientRegistered(id), "Patient already registered");
        patients[id] = Patient({id: id, name: name, dob: dob, currentHospitalAddress: hospitalAddress});
    }

    // Function to register a doctor
    function registerDoctor(string memory name, string memory specialization, address hospitalAddress) public {
        require(!isDoctorRegistered(msg.sender), "Doctor already registered");
        doctors[msg.sender] = Doctor({id: doctors.length + 1, name: name, specialization: specialization, hospitalAddress: hospitalAddress});
    }

    // Function to add a new medical record
    function addMedicalRecord(string memory diagnosis, string memory treatmentPlan, string memory ipfsHash, uint256 patientId) public isAuthorized(Role.Doctor) patientConsented(patientId, msg.sender) {
    // Encrypt sensitive data here before storing it in the contract
    string memory encryptedIpfsHash = encryptIPFSHash(ipfsHash);

    medicalRecords[medicalRecords.length + 1] = MedicalRecord({
        id: medicalRecords.length + 1,
        diagnosis: diagnosis,
        treatmentPlan: treatmentPlan,
        ipfsHash: encryptedIpfsHash,
        patientId: patientId,
        doctorAddress: msg.sender
    });

    emit RecordAdded(medicalRecords.length, encryptedIpfsHash);
    }


    // Function to retrieve a specific medical record
    function getMedicalRecord(uint256 recordId) public view returns (MedicalRecord memory) {
    require(medicalRecords[recordId].id > 0, "Record not found");
    // Decrypt the IPFS hash before returning it
    string memory decryptedIpfsHash = decryptIPFSHash(medicalRecords[recordId].ipfsHash);
    return MedicalRecord({
        id: medicalRecords[recordId].id,
        diagnosis: medicalRecords[recordId].diagnosis,
        treatmentPlan: medicalRecords[recordId].treatmentPlan,
        ipfsHash: decryptedIpfsHash,
        patientId: medicalRecords[recordId].patientId,
        doctorAddress: medicalRecords[recordId].doctorAddress
    });
    }

    // Modifier to check if a user has a specific role
    modifier hasRole(address user, Role requiredRole) {
    require(doctors[user].role == requiredRole, "Unauthorized user");
    _;
    }

    // Modifier to check if a doctor is associated with a patient's current hospital
    modifier doctorAssociatedWithHospital(uint256 patientId) {
    require(doctors[msg.sender].hospitalAddress == patients[patientId].currentHospitalAddress, "Doctor must be associated with patient's current hospital");
    _;
    }

    // Function to give patient consent for a doctor
function givePatientConsent(uint256 patientId, address doctorAddress) public {
    patients[patientId].consent[doctorAddress] = true;
}

// Function to revoke patient consent for a doctor
function revokePatientConsent(uint256 patientId, address doctorAddress) public {
    patients[patientId].consent[doctorAddress] = false;
}

// Function to check if a patient has given consent to a doctor
function checkPatientConsent(uint256 patientId, address doctorAddress) public view returns (bool) {
    return patients[patientId].consent[doctorAddress];
}

// Function to log access to medical records
function logAccessToMedicalRecord(uint256 recordId) private {
    // Implement logging logic here
}

// Function to register a patient
function registerPatient(uint256 id, string memory name, string memory dob, address hospitalAddress) public {
    require(!isPatientRegistered(id), "Patient already registered");
    patients[id] = Patient({id: id, name: name, dob: dob, currentHospitalAddress: hospitalAddress});
}

// Function to register a doctor
function registerDoctor(string memory name, string memory specialization, address hospitalAddress) public {
    require(!isDoctorRegistered(msg.sender), "Doctor already registered");
    doctors[msg.sender] = Doctor({id: doctors.length + 1, name: name, specialization: specialization, hospitalAddress: hospitalAddress, role: Role.Doctor});
}

// Function to transfer a medical record to another hospital
function transferRecord(uint256 recordId, address newHospitalAddress) public isAuthorized(Role.Doctor) doctorAssociatedWithHospital(medicalRecords[recordId].patientId) {
    require(medicalRecords[recordId].id > 0, "Record not found");

    address currentHospitalAddress = patients[medicalRecords[recordId].patientId].currentHospitalAddress;
    patients[medicalRecords[recordId].patientId].currentHospitalAddress = newHospitalAddress;

    emit RecordTransferred(recordId, currentHospitalAddress, newHospitalAddress);
}


    // Function to update a medical record
    function updateMedicalRecord(uint256 recordId, string memory diagnosis, string memory treatmentPlan, string memory ipfsHash) public {
        require(isDoctor(msg.sender), "Only doctors can update medical records");
        require(medicalRecords[recordId].id > 0, "Record not found");

        medicalRecords[recordId] = MedicalRecord({
            id: recordId,
            diagnosis: diagnosis,
            treatmentPlan: treatmentPlan,
            ipfsHash: ipfsHash,
            patientId: medicalRecords[recordId].patientId,
            doctorAddress: msg.sender
        });

        emit RecordUpdated(recordId, ipfsHash);
    }
        

    // Function to check if a patient is registered
    function isPatientRegistered(uint256 id) public view returns (bool) {
    return patients[id].id > 0;
   }

   // Function to check if a doctor is registered
   function isDoctorRegistered(address doctorAddress) public view returns (bool) {
    return doctors[doctorAddress].id > 0;
   }
}