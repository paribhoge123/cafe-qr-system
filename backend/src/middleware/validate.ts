import { Request, Response, NextFunction } from 'express';
import { ZodSchema } from 'zod';

interface ValidateSchemas {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}

// Usage: router.post('/route', validate({ body: mySchema }), controller)
export function validate(schemas: ValidateSchemas) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (schemas.body) {
      const result = schemas.body.safeParse(req.body);
      if (!result.success) return next(result.error);
      req.body = result.data;
    }

    if (schemas.query) {
      const result = schemas.query.safeParse(req.query);
      if (!result.success) return next(result.error);
      req.query = result.data as typeof req.query;
    }

    if (schemas.params) {
      const result = schemas.params.safeParse(req.params);
      if (!result.success) return next(result.error);
      req.params = result.data;
    }

    next();
  };
}
