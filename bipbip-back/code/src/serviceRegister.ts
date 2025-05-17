import HelloWorld from './services/helloWorld';
import GetUserList from './services/users/getUserList';
import { Service } from './type/app/serviceType';

export const serviceRegister: Service[] = [
  {
    operationId: 'getUserList',
    className: GetUserList,
  },
  {
    operationId: 'createUser',
    className: HelloWorld,
  },
  {
    operationId: 'getUserById',
    className: HelloWorld,
  },
  {
    operationId: 'updateUser',
    className: HelloWorld,
  },
  {
    operationId: 'deleteUser',
    className: HelloWorld,
  },
  {
    operationId: 'getEventList',
    className: HelloWorld,
  },
  {
    operationId: 'createEvent',
    className: HelloWorld,
  },
  {
    operationId: 'getEventById',
    className: HelloWorld,
  },
  {
    operationId: 'updateEvent',
    className: HelloWorld,
  },
  {
    operationId: 'deleteEvent',
    className: HelloWorld,
  },
  {
    operationId: 'getMedicationList',
    className: HelloWorld,
  },
  {
    operationId: 'createMedication',
    className: HelloWorld,
  },
  {
    operationId: 'getMedicationById',
    className: HelloWorld,
  },
  {
    operationId: 'updateMedication',
    className: HelloWorld,
  },
  {
    operationId: 'deleteMedication',
    className: HelloWorld,
  },
];
