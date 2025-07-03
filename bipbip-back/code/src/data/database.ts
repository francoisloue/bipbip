import { Pool } from 'pg'
import { Kysely, PostgresDialect } from 'kysely'
import apiConfig from "../config/config";
import { BipBipDatabase } from "../type/data/database";

const dialect = new PostgresDialect({
    pool: new Pool({
        database: apiConfig.dataBaseName,
        host: apiConfig.dataBaseHost,
        user: apiConfig.dataBaseCredentials.user,
        password: apiConfig.dataBaseCredentials.password,
        port: apiConfig.dataBasePort,
        max: 10
    })
})

export const db = new Kysely<BipBipDatabase>({
    dialect,
})