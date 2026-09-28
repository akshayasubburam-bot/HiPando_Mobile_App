import 'dotenv/config';
import app from './src/app.js';
import { connectDB } from './src/config/db.js';

const PORT = parseInt(process.env.PORT) || 5000;

async function start() {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`[Server] Hi Pando backend listening on http://localhost:${PORT}`);
      console.log(`[Server] Health: http://localhost:${PORT}/api/v1/health`);
      console.log(`[Server] Properties: http://localhost:${PORT}/api/v1/properties`);
    });
  } catch (err) {
    console.error('[Server] Failed to start:', err.message);
    process.exit(1);
  }
}

start();
