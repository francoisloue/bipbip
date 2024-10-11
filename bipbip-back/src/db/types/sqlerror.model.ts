export enum SQLError {
    DUPLICATED = "ER_DUP_ENTRY"
}

export type Error = {
    code?: String,
    errno?: number
    sqlState?: String,
    sqlMessage?: String,
    sql?: String
}