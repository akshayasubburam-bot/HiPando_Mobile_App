/**
 * Centralized error handler — must have 4 parameters for Express to treat it
 * as an error-handling middleware.
 */
// eslint-disable-next-line no-unused-vars
export function errorHandler(err, req, res, next) {
  console.error('[ErrorHandler]', err.message);

  // Never expose internal error details or stack traces in production
  const statusCode = err.statusCode || 500;
  const message =
    process.env.NODE_ENV === 'development'
      ? err.message
      : 'An unexpected error occurred';

  res.status(statusCode).json({
    success: false,
    message,
  });
}
