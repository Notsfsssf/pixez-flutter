const https = require('https');
const fs = require('fs');

const PORT = 3000;
const HOST = '0.0.0.0';

// Read SSL certificate and private key
const privateKey = fs.readFileSync('../cert/privateKey.pem', 'utf8');
const certificate = fs.readFileSync('../cert/cert.pem', 'utf8');
const credentials = { key: privateKey, cert: certificate };

// Create a buffer filled with zeros
const oneKb = Buffer.alloc(1024, 0);
const tenMb = Buffer.alloc(10485760, 0);

const requestHandler = (request, response) => {
    let receivedBytes = 0;

    request.on('data', (chunk) => {
        receivedBytes += chunk.length;
        // Discard the data
    });

    request.on('end', () => {
        console.log(`Received ${receivedBytes} bytes`);
        response.statusCode = 200;

        let file;
        switch (request.url) {
            case '/small':
                file = oneKb;
                break;
            case '/large':
                file = tenMb;
                break;
            case '/upload':
                response.end(receivedBytes.toString());
                return;
        }

        if (file) {
            response.setHeader('Content-Type', 'application/octet-stream');
            response.setHeader('Content-Disposition', 'attachment; filename="zeros.bin"');
            response.setHeader('Content-Length', file.length);
            response.end(file);
        }
    });

    request.on('error', (err) => {
        console.error('Error receiving data:', err);
        response.statusCode = 500;
        response.end('Error receiving data');
    });
};

// Create HTTPS server with the provided SSL credentials and request handler
const server = https.createServer(credentials, requestHandler);

server.listen(PORT, HOST, () => {
    console.log(`Server listening on https://${HOST}:${PORT}`);
});
