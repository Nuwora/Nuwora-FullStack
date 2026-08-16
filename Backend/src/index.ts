import 'dotenv/config';
import { createApp } from './app';
import { env } from './env';
import { logger } from './logger';
import { prisma } from './lib/prisma';

const app = createApp();

const server = app.listen(env.PORT, () => {
  logger.info(`Nuwora backend listening on port ${env.PORT} (${env.NODE_ENV})`);
});

async function shutdown(signal: string): Promise<void> {
  logger.info(`Received ${signal}, shutting down gracefully...`);
  server.close(async (err) => {
    if (err) {
      logger.error({ err }, 'Error while closing HTTP server');
    }
    await prisma.$disconnect();
    process.exit(err ? 1 : 0);
  });

  // Force-exit if connections don't drain in time.
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10_000).unref();
}

process.on('SIGINT', () => void shutdown('SIGINT'));
process.on('SIGTERM', () => void shutdown('SIGTERM'));
