const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');
const prometheus = require('prom-client');

const app = express();
const port = process.env.PORT || 8080;

// Prometheus metrics
const register = new prometheus.Registry();
prometheus.collectDefaultMetrics({ register });

const httpRequestsTotal = new prometheus.Counter({
    name: 'app_http_requests_total',
    help: 'Total HTTP requests',
    labelNames: ['method', 'path', 'status_code']
});

const httpRequestDuration = new prometheus.Histogram({
    name: 'app_http_request_duration_seconds',
    help: 'HTTP request duration in seconds',
    labelNames: ['method', 'path'],
    buckets: [0.1, 0.5, 1, 2, 5]
});

register.registerMetric(httpRequestsTotal);
register.registerMetric(httpRequestDuration);

// PostgreSQL
const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'appdb',
    user: process.env.DB_USER || 'appuser',
    password: process.env.DB_PASSWORD || 'password',
    max: 20,
    idleTimeoutMillis: 30000,
});

// Redis
const redisClient = redis.createClient({
    url: `redis://${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}`
});

redisClient.on('error', (err) => console.error('Redis Client Error', err));
redisClient.connect();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Metrics middleware
app.use((req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
        const duration = (Date.now() - start) / 1000;
        httpRequestsTotal.inc({
            method: req.method,
            path: req.path,
            status_code: res.statusCode
        });
        httpRequestDuration.observe({
            method: req.method,
            path: req.path
        }, duration);
    });
    next();
});

// Health endpoint
app.get('/health', async (req, res) => {
    const health = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        services: {
            database: 'unknown',
            redis: 'unknown'
        }
    };

    try {
        await pool.query('SELECT 1');
        health.services.database = 'connected';
    } catch (error) {
        health.services.database = 'disconnected';
        health.status = 'degraded';
    }

    try {
        await redisClient.ping();
        health.services.redis = 'connected';
    } catch (error) {
        health.services.redis = 'disconnected';
        health.status = 'degraded';
    }

    res.json(health);
});

// Readiness probe
app.get('/ready', (req, res) => {
    res.json({ status: 'ready' });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
});

// API endpoints
app.get('/api/users', async (req, res) => {
    const start = Date.now();
    try {
        const result = await pool.query('SELECT * FROM users LIMIT 100');
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/users', async (req, res) => {
    const { name, email } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO users (name, email, created_at) VALUES ($1, $2, NOW()) RETURNING *',
            [name, email]
        );
        res.status(201).json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(port, () => {
    console.log(`🚀 App running on port ${port}`);
});

module.exports = app;