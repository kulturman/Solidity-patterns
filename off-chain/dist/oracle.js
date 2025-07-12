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
var Currency;
(function (Currency) {
    Currency[Currency["EUR"] = 0] = "EUR";
    Currency[Currency["USD"] = 1] = "USD";
})(Currency || (Currency = {}));
class OracleFeeder {
    constructor(rpcUrl, privateKey, oracleAddress) {
        this.API_URL = 'https://api.exchangerate-api.com/v4/latest/XOF';
        this.ORACLE_ABI = [
            'function updateRate(uint8 currency, uint256 rate) external',
            'function getRate(uint8 currency) external view returns (uint256, uint256)',
            'function owner() external view returns (address)',
            'error OnlyOwner()',
            'error RateNotAvailable()'
        ];
        this.provider = new ethers_1.ethers.JsonRpcProvider(rpcUrl);
        this.wallet = new ethers_1.ethers.Wallet(privateKey, this.provider);
        this.oracleContract = new ethers_1.ethers.Contract(oracleAddress, this.ORACLE_ABI, this.wallet);
    }
    decodeCustomError(error) {
        if (error.data) {
            try {
                const iface = new ethers_1.ethers.Interface(this.ORACLE_ABI);
                const decodedError = iface.parseError(error.data);
                return `Custom error: ${(decodedError === null || decodedError === void 0 ? void 0 : decodedError.name) || 'Unknown'}`;
            }
            catch (decodeError) {
                return `Failed to decode custom error: ${error.data}`;
            }
        }
        return error.message || 'Unknown error';
    }
    fetchExchangeRates() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const response = yield fetch(this.API_URL);
                const data = yield response.json();
                const usdToXof = 1 / data.rates.USD;
                const eurToXof = 1 / data.rates.EUR;
                return {
                    USD: usdToXof,
                    EUR: eurToXof
                };
            }
            catch (error) {
                console.error('Error fetching exchange rates:', error);
                throw error;
            }
        });
    }
    updateOracleRates() {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const rates = yield this.fetchExchangeRates();
                const usdRateWei = ethers_1.ethers.parseUnits(rates.USD.toString(), 18);
                const eurRateWei = ethers_1.ethers.parseUnits(rates.EUR.toString(), 18);
                console.log(`Updating rates: USD=${rates.USD}, EUR=${rates.EUR}`);
                // Update USD rate
                try {
                    const usdTx = yield this.oracleContract.updateRate(Currency.USD, usdRateWei);
                    yield usdTx.wait();
                    console.log(`USD rate updated: ${usdTx.hash}`);
                }
                catch (error) {
                    const decodedError = this.decodeCustomError(error);
                    console.error(`Failed to update USD rate: ${decodedError}`);
                    new Error(`USD rate update failed: ${decodedError}`);
                }
                // Update EUR rate
                try {
                    const eurTx = yield this.oracleContract.updateRate(Currency.EUR, eurRateWei);
                    yield eurTx.wait();
                    console.log(`EUR rate updated: ${eurTx.hash}`);
                }
                catch (error) {
                    const decodedError = this.decodeCustomError(error);
                    console.error(`Failed to update EUR rate: ${decodedError}`);
                    new Error(`EUR rate update failed: ${decodedError}`);
                }
            }
            catch (error) {
                if (error instanceof Error && ((_a = error.message) === null || _a === void 0 ? void 0 : _a.includes('rate update failed'))) {
                    throw error;
                }
                console.error('Error updating oracle rates:', error);
                throw error;
            }
            //Check oracle was updated
            try {
                const usdRate = yield this.oracleContract.getRate(Currency.USD);
                console.log(`Current USD rate: ${ethers_1.ethers.formatUnits(usdRate[0], 18)}`);
            }
            catch (error) {
                console.error('Error fetching updated rates:', error);
            }
        });
    }
    startPeriodicUpdates() {
        return __awaiter(this, arguments, void 0, function* (intervalInSeconds = 60) {
            console.log(`Starting periodic updates every ${intervalInSeconds} minutes`);
            yield this.updateOracleRates();
            setInterval(() => __awaiter(this, void 0, void 0, function* () {
                try {
                    yield this.updateOracleRates();
                }
                catch (error) {
                    console.error('Failed to update rates:', error);
                }
            }), intervalInSeconds * 1000);
        });
    }
}
const RPC_URL = process.env.RPC_URL || 'http://localhost:8545';
const PRIVATE_KEY = process.env.PRIVATE_KEY || '';
const ORACLE_ADDRESS = process.env.ORACLE_ADDRESS || '';
if (!PRIVATE_KEY || !ORACLE_ADDRESS) {
    console.error('Please set PRIVATE_KEY and ORACLE_ADDRESS environment variables!!');
}
const oracleFeeder = new OracleFeeder(RPC_URL, PRIVATE_KEY, ORACLE_ADDRESS);
oracleFeeder.startPeriodicUpdates(3)
    .then(() => console.log('Oracle feeder started successfully'))
    .catch(error => console.error('Error starting oracle feeder:', error));
