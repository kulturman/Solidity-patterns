import { ethers } from 'ethers';
import dotenv from 'dotenv';

dotenv.config();

interface ExchangeRateResponse {
    rates: {
        [key: string]: number;
    };
    base: string;
    date: string;
}

enum Currency {
    EUR = 0,
    USD = 1,
}

class OracleFeeder {
    private readonly provider: ethers.Provider;
    private readonly wallet: ethers.Wallet;
    private oracleContract: ethers.Contract;
    private readonly API_URL = 'https://api.exchangerate-api.com/v4/latest/XOF';

    private readonly ORACLE_ABI = [
        'function updateRate(uint8 currency, uint256 rate) external',
        'function getRate(uint8 currency) external view returns (uint256, uint256)',
        'function owner() external view returns (address)',
        'error OnlyOwner()',
        'error RateNotAvailable()'
    ];

    constructor(
        rpcUrl: string,
        privateKey: string,
        oracleAddress: string
    ) {
        this.provider = new ethers.JsonRpcProvider(rpcUrl);
        this.wallet = new ethers.Wallet(privateKey, this.provider);
        this.oracleContract = new ethers.Contract(oracleAddress, this.ORACLE_ABI, this.wallet);
    }

    private decodeCustomError(error: any): string {
        if (error.data) {
            try {
                const iface = new ethers.Interface(this.ORACLE_ABI);
                const decodedError = iface.parseError(error.data);
                return `Custom error: ${decodedError?.name || 'Unknown'}`;
            } catch (decodeError) {
                return `Failed to decode custom error: ${error.data}`;
            }
        }
        return error.message || 'Unknown error';
    }

    async fetchExchangeRates(): Promise<{ USD: number; EUR: number }> {
        try {
            const response = await fetch(this.API_URL);

            const data: ExchangeRateResponse = await response.json();

            const usdToXof = 1 / data.rates.USD;
            const eurToXof = 1 / data.rates.EUR;

            return {
                USD: usdToXof,
                EUR: eurToXof
            };
        } catch (error) {
            console.error('Error fetching exchange rates:', error);
            throw error;
        }
    }

    async updateOracleRates(): Promise<void> {
        try {
            const rates = await this.fetchExchangeRates();

            const usdRateWei = ethers.parseUnits(rates.USD.toString(), 18);
            const eurRateWei = ethers.parseUnits(rates.EUR.toString(), 18);

            console.log(`Updating rates: USD=${rates.USD}, EUR=${rates.EUR}`);

            // Update USD rate
            try {
                const usdTx = await this.oracleContract.updateRate(Currency.USD, usdRateWei);
                await usdTx.wait();
                console.log(`USD rate updated: ${usdTx.hash}`);
            } catch (error) {
                const decodedError = this.decodeCustomError(error);
                console.error(`Failed to update USD rate: ${decodedError}`);
                new Error(`USD rate update failed: ${decodedError}`);
            }

            // Update EUR rate
            try {
                const eurTx = await this.oracleContract.updateRate(Currency.EUR, eurRateWei);
                await eurTx.wait();
                console.log(`EUR rate updated: ${eurTx.hash}`);
            } catch (error) {
                const decodedError = this.decodeCustomError(error);
                console.error(`Failed to update EUR rate: ${decodedError}`);
                new Error(`EUR rate update failed: ${decodedError}`);
            }

        } catch (error) {
            if (error instanceof Error && error.message?.includes('rate update failed')) {
                throw error;
            }
            console.error('Error updating oracle rates:', error);
            throw error;
        }

        //Check oracle was updated
        try {
            const usdRate = await this.oracleContract.getRate(Currency.USD);

            console.log(`Current USD rate: ${ethers.formatUnits(usdRate[0], 18)}`);
        } catch (error) {
            console.error('Error fetching updated rates:', error);
        }
    }

    async startPeriodicUpdates(intervalInSeconds: number = 60): Promise<void> {
        console.log(`Starting periodic updates every ${intervalInSeconds} minutes`);

        await this.updateOracleRates();

        setInterval(async () => {
            try {
                await this.updateOracleRates();
            } catch (error) {
                console.error('Failed to update rates:', error);
            }
        }, intervalInSeconds * 1000);
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