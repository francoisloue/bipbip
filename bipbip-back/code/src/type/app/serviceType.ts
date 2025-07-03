import AbstractService from '../../contract/abstract.service';

export interface Service {
  operationId: string;
  className: AbstractService;
}
