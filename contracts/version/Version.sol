pragma solidity ^0.5.0;

/**
 * @dev Version contract gives the versioning information of the implementation contract
 */
contract Version {
    /**
     * @dev Returns the address of the current owner.
     */
    function version() public pure returns (bytes3) {
        // version 1.0.1
        return "101";
    }
}
