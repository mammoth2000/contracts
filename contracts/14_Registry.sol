// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.17;

contract Registry {
    address immutable Mammoth;
    address immutable Router;
    address immutable Ivory;
    address immutable MammothTreasury;
    address immutable BUSD;
    address immutable Ivory_BUSD_LP;
    address immutable BUSDTreasury;
    address immutable BUSDRedemptionPool;
    address immutable FlowData;
    address immutable IvoryTreasury;

    constructor(
        address _Mammoth,
        address _Router,
        address _Ivory,
        address _MammothTreasury,
        address _BUSD,
        address _Ivory_BUSD_LP,
        address _BUSDTreasury,
        address _BUSDRedemptionPool,
        address _FlowData,
        address _IvoryTreasury
    ) {
        Mammoth = _Mammoth;
        Router = _Router;
        Ivory = _Ivory;
        MammothTreasury = _MammothTreasury;
        BUSD = _BUSD;
        Ivory_BUSD_LP = _Ivory_BUSD_LP;
        BUSDTreasury = _BUSDTreasury;
        BUSDRedemptionPool = _BUSDRedemptionPool;
        FlowData = _FlowData;
        IvoryTreasury = _IvoryTreasury;
    }
}
