/*
    Copyright 2020 Chromie Dollar Devs, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Market.sol";
import "./Regulator.sol";
import "./Bonding.sol";
import "./Govern.sol";
import "../Constants.sol";

contract Implementation is State, Bonding, Market, Regulator, Govern {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() initializer public {
        // committer reward:
        mintToAccount(msg.sender, 150e18); // 150 CSD to committer
        // contributor  rewards:
        mintToAccount(0x49dE6D4040C15d2305a0a63b019f61e8F30c4D99, 10000e18); // 1000 CSD to devnull
    }

    function advance() external incentivized {
        Bonding.step();
        Regulator.step();
        Market.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }

    modifier incentivized {
        // Mint advance reward to sender
        uint256 incentive = Constants.getAdvanceIncentive();
        mintToAccount(msg.sender, incentive);
        emit Incentivization(msg.sender, incentive);
        _;
    }
}
