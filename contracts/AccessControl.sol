pragma solidity ^0.4.17;

contract AccessControl {

    address[] public authorized;

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
}
