import { Response } from 'express';
import { HttpStatus } from '../enum/app/HttpStatus';
import { ApiRequest } from '../type/app/apiRequest';
import { serviceRegister } from '../serviceRegister';
import AbstractService from '../contract/abstract.service';
import packageJson from '../../package.json';

export class Controller {
  public healthcheck(req: ApiRequest, res: Response): void {
    this.returnResponse(req, res, HttpStatus.OK, {});
  }
  public version(req: ApiRequest, res: Response): void {
    this.returnResponse(req, res, HttpStatus.OK, {
      version: packageJson.version,
    });
  }

  public async render(req: ApiRequest, res: Response): Promise<void> {
    await this.commonRender(req, res, {
      headers: req.headers,
      ...req.body,
      ...req.query,
      ...req.params,
    });
  }

  private returnResponse(
    _req: ApiRequest,
    res: Response,
    status: number,
    body: object,
  ) {
    if (body) {
      res.status(status).json(body);
    } else {
      res.status(status).end();
    }
  }

  private findService(serviceName: string): AbstractService | null {
    let foundService = null;
    serviceRegister.forEach((service) => {
      if (service.operationId === serviceName) {
        foundService = service.className;
      }
    });
    return foundService;
  }

  private async commonRender(
    req: ApiRequest,
    res: Response,
    requestBody: object,
  ) {
    const serviceName = req.operationDoc.operationId;
    const service = this.findService(serviceName);

    if (service === null) {
      this.returnResponse(req, res, HttpStatus.SERVER_ERROR, {
        errorMessage: 'Service introuvable',
      });
    } else {
      console.log(req);
      const serviceResponse: object = await service.process(requestBody);
      this.returnResponse(req, res, HttpStatus.OK, serviceResponse);
    }
  }
}
