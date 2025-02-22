const request = require('supertest');
const app = require('../../src/app');

describe('App Routes', () => {
    test('GET / should return 200', async () => {
        const response = await request(app).get('/');
        expect(response.statusCode).toBe(200);
        expect(response.text).toContain('Isaac Tandoh');
    });

    test('GET /nonexistent should return 404', async () => {
        const response = await request(app).get('/nonexistent');
        expect(response.statusCode).toBe(404);
        expect(response.text).toContain('Page Not Found');
    });

    test('Headers should be secure', async () => {
        const response = await request(app).get('/');
        expect(response.headers['x-powered-by']).toBeUndefined();
    });
}); 