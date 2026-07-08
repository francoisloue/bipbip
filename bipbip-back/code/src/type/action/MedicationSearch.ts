export type ApiMedication = {
    cis: number,
    elementPharmaceutique: string,
    formePharmaceutique: string,
    voiesAdministration: string[],
    statusAutorisation: string,
    typeProcedure: string,
    etatComercialisation: string,
    dateAMM: Date,
    titulaire: string,
    surveillanceRenforcee: string,
    composition: Composition[],
    generique: string | null,
    presentation: Presentation[]
    conditions: string[]
}

type Composition = {
    cis: number,
    elementPharmaceutique: string,
    codeSubstance: number,
    denominationSubstance: string,
    dosage: string,
    referenceDosage: string,
    natureComposant: string
}

type Presentation = {
    cis: number,
    cip7: number,
    libelle: string,
    statusAdministratif: string,
    etatComercialisation: string,
    dateDeclaration: Date,
    cip13: number,
    agreement: string,
    tauxRemboursement: string,
    prix: number
}