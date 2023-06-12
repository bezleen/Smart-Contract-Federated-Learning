// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IAdminControl {
    function isAdmin(address account) external view returns (bool);
}
