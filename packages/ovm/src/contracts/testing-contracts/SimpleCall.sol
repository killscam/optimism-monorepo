pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import {ExecutionManager} from "../ExecutionManager.sol";

/**
 * @title SimpleCall
 * @notice A simple contract testing the execution manager's CALL.
 */
contract SimpleCall {
    address executionManagerAddress;
    /**
     * Constructor currently accepts an execution manager & stores that in storage.
     * Note this should be the only storage that this contract ever uses & it should be replaced
     * by a hardcoded value once we have the transpiler.
     */
    constructor(address _executionManagerAddress) public {
        executionManagerAddress = _executionManagerAddress;
    }

    // expects _targetContract (address as bytes32), _calldata (variable-length bytes).
    // returns variable-length bytes result.
    function makeCall() public {
        bytes4 methodId = bytes4(keccak256("ovmCALL()") >> 224);
        address addr = executionManagerAddress;
        assembly {
            let callBytes := mload(0x40)
            calldatacopy(callBytes, 0, calldatasize)

            // replace the first 4 bytes with the right methodID
            mstore8(callBytes, shr(24, methodId))
            mstore8(add(callBytes, 1), shr(16, methodId))
            mstore8(add(callBytes, 2), shr(8, methodId))
            mstore8(add(callBytes, 3), methodId)

            // overwrite call params
            let result := mload(0x40)
            let success := call(gas, addr, 0, callBytes, calldatasize, result, 500000)

            if eq(success, 0) {
                revert(0, 0)
            }

            return(result, returndatasize)
        }
    }
}