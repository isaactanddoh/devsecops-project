const request = require('supertest');
const app = require('../../src/app');

describe('API Integration Tests', () => {
    test('Server is running and responding', async () => {
        const response = await request(app).get('/');
        expect(response.status).toBe(200);
    });
}); 