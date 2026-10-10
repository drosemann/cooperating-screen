/**
 * Rate Limiter for WebSocket and HTTP endpoints.
 * This guard keeps the signaling server responsive by tracking how often a single
 * IP address or device emits requests within a rolling time window.
 */

export default class RateLimiter {
  constructor(options = {}) {
    // Each limiter instance is configured with a fixed window and request quota,
    // which makes abuse detection predictable and easy to tune per endpoint type.
    this.windowMs = options.windowMs || 60000; // 1 minute default
    this.maxRequests = options.maxRequests || 100; // 100 requests per minute
    this.requests = new Map();
  }

  /**
   * Check if request is allowed for identifier
   * @param {string} identifier - Device serial or IP address
   * @returns {boolean} true if request allowed
   */
  isAllowed(identifier) {
    const now = Date.now();

    if (!this.requests.has(identifier)) {
      this.requests.set(identifier, [now]);
      return true;
    }

    let requestTimes = this.requests.get(identifier);

    // Remove old requests outside time window
    requestTimes = requestTimes.filter((time) => now - time <= this.windowMs);
    this.requests.set(identifier, requestTimes);

    if (requestTimes.length >= this.maxRequests) {
      return false;
    }

    requestTimes.push(now);
    return true;
  }

  /**
   * Get remaining requests for identifier
   * @param {string} identifier
   * @returns {number} remaining requests
   */
  getRemainingRequests(identifier) {
    const now = Date.now();

    if (!this.requests.has(identifier)) {
      return this.maxRequests;
    }

    const requestTimes = this.requests.get(identifier);
    const validRequests = requestTimes.filter((time) => now - time <= this.windowMs).length;

    return Math.max(0, this.maxRequests - validRequests);
  }

  /**
   * Get reset time for identifier in seconds
   * @param {string} identifier
   * @returns {number} seconds until reset
   */
  getResetTime(identifier) {
    if (!this.requests.has(identifier)) {
      return 0;
    }

    const requestTimes = this.requests.get(identifier);
    if (requestTimes.length === 0) {
      return 0;
    }

    const oldestRequest = Math.min(...requestTimes);
    const resetAt = oldestRequest + this.windowMs;
    const now = Date.now();

    return Math.max(0, Math.ceil((resetAt - now) / 1000));
  }

  /**
   * Reset rate limit for identifier
   * @param {string} identifier
   */
  reset(identifier) {
    this.requests.delete(identifier);
  }

  /**
   * Clear all rate limits
   */
  clearAll() {
    this.requests.clear();
  }

  /**
   * Express middleware for rate limiting
   * @param {RateLimiter} limiter - RateLimiter instance
   * @returns {Function} middleware function
   */
  static middleware(limiter) {
    return (req, res, next) => {
      const identifier = req.ip || req.connection.remoteAddress || 'unknown';

      if (!limiter.isAllowed(identifier)) {
        const resetTime = limiter.getResetTime(identifier);
        res.set('Retry-After', resetTime);
        return res.status(429).json({
          error: 'Too many requests',
          retryAfter: resetTime,
        });
      }

      res.set('X-RateLimit-Remaining', limiter.getRemainingRequests(identifier));
      res.set('X-RateLimit-Reset', limiter.getResetTime(identifier));

      next();
    };
  }

  /**
   * WebSocket connection rate limiting
   * @param {RateLimiter} limiter
   * @returns {Function} validator function
   */
  static wsValidator(limiter) {
    return (info, callback) => {
      const ip = info.req.socket.remoteAddress || 'unknown';

      if (!limiter.isAllowed(ip)) {
        return callback(false, 429, 'Too many connection attempts');
      }

      callback(true);
    };
  }
}
