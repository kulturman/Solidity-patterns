"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ethers_1 = require("ethers");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const ORACLE_ABI = [
    'function updateRate(string memory currency, uint256 rate) external',
    'function getRate(string memory currency) external view returns (uint256, uint256)',
    'function owner() external view returns (address)',
    'error OnlyOwner()',
    'error EmptyCurrency()',
    'error InvalidRate()',
    'error RateNotAvailable()'
];
function testOracle() {
    return __awaiter(this, void 0, void 0, function* () {
        const RPC_URL = process.env.RPC_URL || 'http://localhost:8545';
        const PRIVATE_KEY = process.env.PRIVATE_KEY || '';
        const ORACLE_ADDRESS = process.env.ORACLE_ADDRESS || '';
        const provider = new ethers_1.ethers.JsonRpcProvider(RPC_URL);
        const wallet = new ethers_1.ethers.Wallet(PRIVATE_KEY, provider);
        const oracleContract = new ethers_1.ethers.Contract(ORACLE_ADDRESS, ORACLE_ABI, wallet);
        console.log('Testing Oracle contract...');
        console.log('RPC URL:', RPC_URL);
        console.log('Oracle Address:', ORACLE_ADDRESS);
        console.log('Wallet Address:', wallet.address);
        try {
            // Test 1: Check if we can get the owner
            const owner = yield oracleContract.owner();
            console.log('✅ Owner:', owner);
            // Test 2: Try to get a rate that doesn't exist (should fail with RateNotAvailable)
            try {
                const [rate, timestamp] = yield oracleContract.getRate('USD');
                console.log('✅ USD rate found:', rate.toString(), 'at', timestamp.toString());
            }
            catch (error) {
                console.log('❌ USD rate not available (expected):', error.message);
            }
            // Test 3: Try to update a rate
            console.log('Setting USD rate to 1000...');
            const tx = yield oracleContract.updateRate('USD', ethers_1.ethers.parseUnits('1000', 18));
            yield tx.wait();
            console.log('✅ USD rate updated, tx hash:', tx.hash);
            // Test 4: Try to get the rate again
            const [rate, timestamp] = yield oracleContract.getRate('USD');
            console.log('✅ USD rate retrieved:', ethers_1.ethers.formatUnits(rate, 18), 'at', timestamp.toString());
        }
        catch (error) {
            console.error('❌ Error:', error.message);
            if (error.data) {
                try {
                    const iface = new ethers_1.ethers.Interface(ORACLE_ABI);
                    const decodedError = iface.parseError(error.data);
                    console.error('❌ Decoded error:', decodedError === null || decodedError === void 0 ? void 0 : decodedError.name);
                }
                catch (decodeError) {
                    console.error('❌ Failed to decode error:', error.data);
                }
            }
        }
    });
}
testOracle().catch(console.error);
