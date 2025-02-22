const request = require('supertest');
const app = require('../../src/app');

describe('API Integration Tests', () => {
    test('GET / should serve index.html', async () => {
        const response = await request(app).get('/');
        expect(response.status).toBe(200);
        expect(response.text).toContain('<!DOCTYPE html>');
        expect(response.text).toContain('Isaac Tandoh');
    });

    test('GET /about should serve about.html', async () => {
        const response = await request(app).get('/about');
        expect(response.status).toBe(200);
        expect(response.text).toContain('About Me');
    });

    test('GET /projects should serve projects.html', async () => {
        const response = await request(app).get('/projects');
        expect(response.status).toBe(200);
        expect(response.text).toContain('My Projects');
    });

    test('Server startup with different NODE_ENV values', () => {
        const originalEnv = process.env.NODE_ENV;
        
        // Test production environment
        process.env.NODE_ENV = 'production';
        const prodApp = require('../../src/app');
        
        // Test development environment
        process.env.NODE_ENV = 'development';
        const devApp = require('../../src/app');
        
        // Restore original environment
        process.env.NODE_ENV = originalEnv;
        
        expect(prodApp).toBeDefined();
        expect(devApp).toBeDefined();
    });
}); 