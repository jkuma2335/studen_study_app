const https = require('https');
// const dotenv = require('dotenv');
// dotenv.config();

const apiKey = 'AIzaSyBqqqxql2mEyUyEBDEb0emFTJInQ95NV-I';
if (!apiKey) {
    console.error('No API Key found in .env');
    process.exit(1);
}

const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`;

https.get(url, (res) => {
    let data = '';
    res.on('data', (chunk) => data += chunk);
    res.on('end', () => {
        try {
            const json = JSON.parse(data);
            if (json.error) {
                console.error('API Error:', json.error);
            } else {
                console.log('Available Models:');
                if (json.models) {
                    json.models.forEach(m => {
                        if (m.supportedGenerationMethods.includes('generateContent')) {
                            console.log(`- ${m.name}`);
                        }
                    });
                } else {
                    console.log('No models found in response:', json);
                }
            }
        } catch (e) {
            console.error('Parse error:', e);
            console.log('Raw data:', data);
        }
    });
}).on('error', (e) => {
    console.error('Network error:', e);
});
