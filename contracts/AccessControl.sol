pragma solidity ^0.4.17;

contract AccessControl {

    address[] public authorized;
    address[] public manufacturers;

    /**
     * Only specific authorized people can perform action
     */
    modifier onlyAuthorized {
        bool isAuthorized = false;
        for (uint8 i=0; i<authorized.length; i++) {
            if (msg.sender == authorized[i]) {
                isAuthorized = true;
                break;
            }
        }
        require(isAuthorized);
        _;
    }

    /**
     * Check if there's a better way to maintain list or map of manufacturers
     * while avoiding circular dependencies of contracts or keeping 2 lists of manufacturers
     */
    modifier onlyManufacturer {
        bool isManufacturer = false;
        for (uint64 i=0; i<manufacturers.length; i++) {
            if (msg.sender == manufacturers[i]) {
                isManufacturer = true;
                break;
            }
        }
        require(isManufacturer);
        _;
    }
}
