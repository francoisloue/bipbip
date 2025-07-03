import CreateEvent from './services/events/createEvent';
import  DeleteEventFromId from './services/events/deleteEvent';
import GetEventById from './services/events/getEventById';
import GetEventList from './services/events/getEventList';
import UpdateEventFromId from './services/events/updateEvent';
import CreateMedication from './services/medications/createMedication';
import DeleteMedicationFromId from './services/medications/deleteMedication';
import GetMedicationById from './services/medications/getMedicationById';
import GetMedicationList from './services/medications/getMedicationList';
import UpdateMedicationFromId from './services/medications/updateMedication';
import CreateUser from './services/users/createUser';
import DeleteUserFromId from './services/users/deleteUser';
import GetUserById from './services/users/getUserById';
import GetUserList from './services/users/getUserList';
import UpdateUserFromId from './services/users/updateUser';
import { Service } from './type/app/serviceType';

export const serviceRegister: Service[] = [
  {
    operationId: 'getUserList',
    className: GetUserList,
  },
  {
    operationId: 'createUser',
    className: CreateUser,
  },
  {
    operationId: 'getUserById',
    className: GetUserById,
  },
  {
    operationId: 'updateUser',
    className: UpdateUserFromId,
  },
  {
    operationId: 'deleteUser',
    className: DeleteUserFromId,
  },
  {
    operationId: 'getEventList',
    className: GetEventList,
  },
  {
    operationId: 'createEvent',
    className: CreateEvent,
  },
  {
    operationId: 'getEventById',
    className: GetEventById,
  },
  {
    operationId: 'updateEvent',
    className: UpdateEventFromId  ,
  },
  {
    operationId: 'deleteEvent',
    className: DeleteEventFromId,
  },
  {
    operationId: 'getEventByUserId',
    className: GetEventList
  },
  {
    operationId: 'getMedicationList',
    className: GetMedicationList,
  },
  {
    operationId: 'createMedication',
    className: CreateMedication,
  },
  {
    operationId: 'getMedicationById',
    className: GetMedicationById,
  },
  {
    operationId: 'updateMedication',
    className: UpdateMedicationFromId,
  },
  {
    operationId: 'deleteMedication',
    className: DeleteMedicationFromId,
  }
];
