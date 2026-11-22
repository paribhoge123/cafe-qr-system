import { Request } from 'express';

export interface PaginationOptions {
  page: number;
  limit: number;
  offset: number;
}

export function getPagination(req: Request, defaultLimit = 20): PaginationOptions {
  const page = Math.max(1, parseInt(req.query.page as string) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(req.query.limit as string) || defaultLimit));
  const offset = (page - 1) * limit;
  return { page, limit, offset };
}

export function getTotalPages(total: number, limit: number): number {
  return Math.ceil(total / limit);
}
