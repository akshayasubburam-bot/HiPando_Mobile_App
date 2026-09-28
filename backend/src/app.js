import express from 'express';
import helmet from 'helmet';
import cors from 'cors';

import propertyRoutes from './routes/propertyRoutes.js';
import { errorHandler } from './middleware/errorHandler.js';

const app = express();

// ── Security ────────────────────────────────────────────────────────────────
app.use(helmet());

// CORS: allow the Android emulator (10.0.2.2) and localhost in development.
// In production, replace the origin list with your actual deployed domain.
const allowedOrigins =
  process.env.NODE_ENV === 'production'
    ? ['https://your-production-domain.com'] // update when deploying
    : true; // allow all origins in development

app.use(cors({ origin: allowedOrigins }));

// ── Body parsing ─────────────────────────────────────────────────────────────
app.use(express.json({ limit: '10kb' }));

// ── Health check ─────────────────────────────────────────────────────────────
app.get('/api/v1/health', (_req, res) => {
  res.status(200).json({
    success: true,
    message: 'Hi Pando backend is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  });
});

// ── Property routes ──────────────────────────────────────────────────────────
app.use('/api/v1/properties', propertyRoutes);

// ── 404 handler ──────────────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

// ── Centralized error handler (must be last) ─────────────────────────────────
app.use(errorHandler);

export default app;
