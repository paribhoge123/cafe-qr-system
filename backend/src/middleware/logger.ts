import morgan from 'morgan';
import { env } from '../config/env';

// Detailed in development, minimal in production
export const logger = morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev');
