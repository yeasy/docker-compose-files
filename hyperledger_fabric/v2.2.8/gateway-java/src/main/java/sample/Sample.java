package sample;

import org.apache.commons.codec.binary.Base64;
import org.hyperledger.fabric.gateway.*;
import org.yaml.snakeyaml.Yaml;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Map;
import java.util.concurrent.TimeoutException;

public class Sample {

    private static String connectProfilePath = "./connection.yaml";
    private static  String channelName = ConfigProperties.values("CHANNEL_NAME");
    private static String chaincodeName = ConfigProperties.values("CHAINCODE_NAME");

    /**
     * Initialize a wallet with an admin identity
     *
     * @param connectionProfilePath file path to the connection profile
     * @param wallet                wallet to store identity
     * @throws IOException io failure
     * @throws CertificateException the certificate is with invalid format
     * @throws NoSuchAlgorithmException the algorithm is not supported
     * @throws InvalidKeySpecException the private key is with invalid format
     */
    private static void initWallet(String connectionProfilePath, Wallet wallet) throws IOException, CertificateException, NoSuchAlgorithmException, InvalidKeySpecException {
        // Load the network configuration profile file
        String profileFullPath = Paths.get(connectionProfilePath).normalize().toRealPath().toString();
        InputStream fis = new FileInputStream(profileFullPath);
        Yaml yaml = new Yaml();
        Map yamlMap = yaml.load(fis);
        Map clientInfo = (Map) yamlMap.get("client");
        String orgName = clientInfo.get("organization").toString();
        Map orgsInfo = (Map) yamlMap.get("organizations");
        Map orgInfo = (Map) orgsInfo.get(orgName);
        String mspId = orgInfo.get("mspid").toString();
        Map signedCert = (Map) orgInfo.get("signedCertPEM");
        String signedCertPath = signedCert.get("path").toString();
        Map privKey = (Map) orgInfo.get("adminPrivateKeyPEM");
        String privKeyPath = privKey.get("path").toString();

        // Load the certificate and the private key
        CertificateFactory fac = CertificateFactory.getInstance("X509");
        FileInputStream is = new FileInputStream(signedCertPath);
        X509Certificate cert = (X509Certificate) fac.generateCertificate(is);
        byte[] keyBytes = Files.readAllBytes(Paths.get(privKeyPath));
        String temp = new String(keyBytes);
        String privKeyPEM = temp.replace("-----BEGIN PRIVATE KEY-----\n", "");
        privKeyPEM = privKeyPEM.replace("-----END PRIVATE KEY-----", "");
        Base64 b64 = new Base64();
        byte[] decoded = b64.decode(privKeyPEM);
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(decoded);
        KeyFactory kf = KeyFactory.getInstance("EC");
        PrivateKey privateKey = kf.generatePrivate(spec);

        X509Identity identity = Identities.newX509Identity(mspId, cert, privateKey);
        wallet.put("admin", identity);
    }

    public static void main(String[] args) throws IOException, CertificateException, NoSuchAlgorithmException, InvalidKeySpecException {
        // Initialize a wallet to hold identities used to access the network.
        String walletPath = "/opt/test/wallet";
        Path walletDirectory = Paths.get(walletPath);
        Wallet wallet = Wallets.newFileSystemWallet(walletDirectory);
        initWallet(connectProfilePath, wallet);

        // Path to a common connection profile describing the network.
        Path networkConfigFile = Paths.get(connectProfilePath);

        // Configure the gateway connection used to access the network.
        Gateway.Builder builder = Gateway.createBuilder()
                .identity(wallet, "admin")
                .networkConfig(networkConfigFile);

        // Create a gateway connection
        try (Gateway gateway = builder.connect()) {
            // Obtain a smart contract deployed on the network.
            Network network = gateway.getNetwork(channelName);
            Contract contract = network.getContract(chaincodeName);

            // Submit transactions that store state to the ledger.
            byte[] createCarResult = contract.createTransaction("invoke")
                    .submit("a", "b", "1");
            System.out.println(new String(createCarResult, StandardCharsets.UTF_8));

            // Evaluate transactions that query state from the ledger.
            byte[] queryAllCarsResult = contract.evaluateTransaction("query", "a");
            System.out.println(new String(queryAllCarsResult, StandardCharsets.UTF_8));

        } catch (ContractException | TimeoutException | InterruptedException e) {
            e.printStackTrace();
        }
        System.exit(0);
    }
}
