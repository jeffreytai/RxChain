pragma solidity 0.4.20;

import "./Ownable.sol";

contract AccessControl is Ownable {

    address[] public authorized;
    bool private stopped = false;

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
     * Prevent the function from being executed if "stopped" is currently on
     */
    modifier stopInEmergency {
        if (!stopped) {
            _;
        }
    }

    /**
     * Allow a function to specifically be executed when the contract is stopped, such as withdrawing
     */
    modifier onlyInEmergency {
        if (stopped) {
            _;
        }
    }

    /**
     * Temporarily stop or resume the contract, used for contract upgrades
     */
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }
}
