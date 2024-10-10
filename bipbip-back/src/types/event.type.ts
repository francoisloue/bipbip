export type Event = {
    id: number,
    name: string,
    description?: string,
    author: number,
    creationDate: Date,
    takePillDate: Date,
    medication: number,
    isActive: Boolean
}