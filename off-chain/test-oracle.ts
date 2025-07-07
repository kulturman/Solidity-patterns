import { ethers } from 'ethers';
import dotenv from 'dotenv';

dotenv.config();

const ORACLE_ABI = [
    'function updateRate(string memory currency, uint256 rate) external',
    'function getRate(string memory currency) external view returns (uint256, uint256)',
    'function owner() external view returns (address)',
    'error OnlyOwner()',
    'error EmptyCurrency()',
    'error InvalidRate()',
    'error RateNotAvailable()'
];

async function testOracle() {
    const RPC_URL = process.env.RPC_URL || 'http://localhost:8545';
    const PRIVATE_KEY = process.env.PRIVATE_KEY || '';
    const ORACLE_ADDRESS = process.env.ORACLE_ADDRESS || '';

    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    const oracleContract = new ethers.Contract(ORACLE_ADDRESS, ORACLE_ABI, wallet);

    console.log('Testing Oracle contract...');
    console.log('RPC URL:', RPC_URL);
    console.log('Oracle Address:', ORACLE_ADDRESS);
    console.log('Wallet Address:', wallet.address);

    try {
        // Test 1: Check if we can get the owner
        const owner = await oracleContract.owner();
        console.log('✅ Owner:', owner);
        
        // Test 2: Try to get a rate that doesn't exist (should fail with RateNotAvailable)
        try {
            const [rate, timestamp] = await oracleContract.getRate('USD');
            console.log('✅ USD rate found:', rate.toString(), 'at', timestamp.toString());
        } catch (error: any) {
            console.log('❌ USD rate not available (expected):', error.message);
        }

        // Test 3: Try to update a rate
        console.log('Setting USD rate to 1000...');
        const tx = await oracleContract.updateRate('USD', ethers.parseUnits('1000', 18));
        await tx.wait();
        console.log('✅ USD rate updated, tx hash:', tx.hash);

        // Test 4: Try to get the rate again
        const [rate, timestamp] = await oracleContract.getRate('USD');
        console.log('✅ USD rate retrieved:', ethers.formatUnits(rate, 18), 'at', timestamp.toString());

    } catch (error: any) {
        console.error('❌ Error:', error.message);
        if (error.data) {
            try {
                const iface = new ethers.Interface(ORACLE_ABI);
                const decodedError = iface.parseError(error.data);
                console.error('❌ Decoded error:', decodedError?.name);
            } catch (decodeError) {
                console.error('❌ Failed to decode error:', error.data);
            }
        }
    }
}

testOracle().catch(console.error);