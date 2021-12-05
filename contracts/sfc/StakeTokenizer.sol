pragma solidity ^0.5.0;

import "./SFC.sol";
import "../erc20/base/ERC20Burnable.sol";
import "../erc20/base/ERC20Mintable.sol";
import "../common/Initializable.sol";

contract Spacer {
    address private _owner;
}

contract StakeTokenizer is Spacer, Initializable {
    SFC internal sfc;

    mapping(address => mapping(uint256 => uint256)) public outstandingSCRX;

    address public sCRXTokenAddress;

    function initialize(address _sfc, address _sCRXTokenAddress) public initializer {
        sfc = SFC(_sfc);
        sCRXTokenAddress = _sCRXTokenAddress;
    }

    function mintSCRX(uint256 toValidatorID) external {
        address delegator = msg.sender;
        uint256 lockedStake = sfc.getLockedStake(delegator, toValidatorID);
        require(lockedStake > 0, "delegation isn't locked up");
        require(lockedStake > outstandingSCRX[delegator][toValidatorID], "sCRX is already minted");

        uint256 diff = lockedStake - outstandingSCRX[delegator][toValidatorID];
        outstandingSCRX[delegator][toValidatorID] = lockedStake;

        // It's important that we mint after updating outstandingSCRX (protection against Re-Entrancy)
        require(ERC20Mintable(sCRXTokenAddress).mint(delegator, diff), "failed to mint sCRX");
    }

    function redeemSCRX(uint256 validatorID, uint256 amount) external {
        require(outstandingSCRX[msg.sender][validatorID] >= amount, "low outstanding sCRX balance");
        require(IERC20(sCRXTokenAddress).allowance(msg.sender, address(this)) >= amount, "insufficient allowance");
        outstandingSCRX[msg.sender][validatorID] -= amount;

        // It's important that we burn after updating outstandingSCRX (protection against Re-Entrancy)
        ERC20Burnable(sCRXTokenAddress).burnFrom(msg.sender, amount);
    }

    function allowedToWithdrawStake(address sender, uint256 validatorID) public view returns(bool) {
        return outstandingSCRX[sender][validatorID] == 0;
    }
}
