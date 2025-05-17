import { Request } from 'express';
import { OpenAPIV3 } from 'openapi-types';

export interface ApiRequest extends Request {
  apiDoc?: OpenAPIV3.Document;
  operationDoc?: any;
}
