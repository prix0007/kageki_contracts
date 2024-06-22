// Generated by dojo-bindgen on Sat, 22 Jun 2024 13:24:13 +0000. Do not modify this file manually.
import { Account } from "starknet";
import {
    Clause,
    Client,
    ModelClause,
    createClient,
    valueToToriiValueAndOperator,
} from "@dojoengine/torii-client";
import {
    LOCAL_KATANA,
    LOCAL_RELAY,
    LOCAL_TORII,
    createManifestFromJson,
} from "@dojoengine/core";

// Type definition for `core::byte_array::ByteArray` struct
export interface ByteArray {
    data: string[];
    pending_word: string;
    pending_word_len: number;
}

// Type definition for `kageki_duels::models::card::CardCount` struct
export interface CardCount {
    owner: string;
    total: bigint;
}

// Type definition for `core::option::Option::<core::integer::u32>` enum
type Option<A> = { type: 'Some'; data: A; } | { type: 'None'; }

// Type definition for `kageki_duels::systems::player_actions::actions::PlayerCardCreated` struct
export interface PlayerCardCreated {
    player: string;
    cardId: bigint;
}


// Type definition for `kageki_duels::models::player::PlayerParty` struct
export interface PlayerParty {
    player: string;
    partyId: bigint;
    is_active: boolean;
    card1: bigint;
    card2: bigint;
    card3: bigint;
    card4: bigint;
}


// Type definition for `kageki_duels::systems::stage_actions::actions::BattleResult` struct
export interface BattleResult {
    winner: string;
    loser: string;
    party_id1: bigint;
    party_id2: bigint;
}


// Type definition for `kageki_duels::models::environment::StageSettings` struct
export interface StageSettings {
    stage_setting: number;
    stage_count: bigint;
}


// Type definition for `kageki_duels::models::environment::Randomness` struct
export interface Randomness {
    contract: string;
    last_random_id: string;
}


// Type definition for `kageki_duels::models::card::Card` struct
export interface Card {
    owner: string;
    cardId: bigint;
    power: number;
    health: number;
    factor: number;
    experience: bigint;
    battles: bigint;
    skill: Skill;
    element: Element;
}

// Type definition for `kageki_duels::models::card::Skill` enum
type Skill = { type: 'Stealth'; data: boolean; } | { type: 'AuraManipulation'; data: number; } | { type: 'Regeneration'; data: number; } | { type: 'ElementalControl'; data: boolean; } | { type: 'None'; }
// Type definition for `kageki_duels::models::card::Element` enum
type Element = { type: 'Earth'; } | { type: 'Wind'; } | { type: 'Water'; } | { type: 'Fire'; }

// Type definition for `kageki_duels::models::player::Player` struct
export interface Player {
    player: string;
    battles: bigint;
    wins: bigint;
    loses: bigint;
    party_count: bigint;
}


// Type definition for `kageki_duels::systems::player_actions::actions::PartyCreated` struct
export interface PartyCreated {
    player: string;
    party: PlayerParty;
}


// Type definition for `kageki_duels::models::environment::Stage` struct
export interface Stage {
    p1: string;
    p2: string;
    stageId: bigint;
    p1_party: bigint;
    p2_party: bigint;
    is_finished: boolean;
    randomness: string;
    environment: Element;
}


class BaseCalls {
    contractAddress: string;
    account?: Account;

    constructor(contractAddress: string, account?: Account) {
        this.account = account;
        this.contractAddress = contractAddress;
    }

    async execute(entrypoint: string, calldata: any[] = []): Promise<void> {
        if (!this.account) {
            throw new Error("No account set to interact with dojo_starter");
        }

        await this.account.execute(
            {
                contractAddress: this.contractAddress,
                entrypoint,
                calldata,
            },
            undefined,
            {
                maxFee: 0,
            }
        );
    }
}

class ActionsCalls extends BaseCalls {
    constructor(contractAddress: string, account?: Account) {
        super(contractAddress, account);
    }

    async dojoResource(): Promise<void> {
        try {
            await this.execute("dojo_resource", [])
        } catch (error) {
            console.error("Error executing dojoResource:", error);
            throw error;
        }
    }

    async spawnPlayer(): Promise<void> {
        try {
            await this.execute("spawn_player", [])
        } catch (error) {
            console.error("Error executing spawnPlayer:", error);
            throw error;
        }
    }

    async makeParty(id1: bigint, id2: bigint, id3: bigint, id4: bigint): Promise<void> {
        try {
            await this.execute("make_party", [id1,
                id2,
                id3,
                id4])
        } catch (error) {
            console.error("Error executing makeParty:", error);
            throw error;
        }
    }

    async createCharacter(player: string, randomness: string): Promise<void> {
        try {
            await this.execute("create_character", [player,
                randomness])
        } catch (error) {
            console.error("Error executing createCharacter:", error);
            throw error;
        }
    }

    async dojoInit(): Promise<void> {
        try {
            await this.execute("dojo_init", [])
        } catch (error) {
            console.error("Error executing dojoInit:", error);
            throw error;
        }
    }
}
class ActionsCalls extends BaseCalls {
    constructor(contractAddress: string, account?: Account) {
        super(contractAddress, account);
    }

    async dojoInit(): Promise<void> {
        try {
            await this.execute("dojo_init", [])
        } catch (error) {
            console.error("Error executing dojoInit:", error);
            throw error;
        }
    }

    async battleParty(party_id1: bigint, party_id2: bigint): Promise<void> {
        try {
            await this.execute("battle_party", [party_id1,
                party_id2])
        } catch (error) {
            console.error("Error executing battleParty:", error);
            throw error;
        }
    }

    async stageCreationBattleMaker(party_id1: bigint, party_id2: bigint, raw_randomness: string): Promise<void> {
        try {
            await this.execute("stage_creation_battle_maker", [party_id1,
                party_id2,
                raw_randomness])
        } catch (error) {
            console.error("Error executing stageCreationBattleMaker:", error);
            throw error;
        }
    }

    async dojoResource(): Promise<void> {
        try {
            await this.execute("dojo_resource", [])
        } catch (error) {
            console.error("Error executing dojoResource:", error);
            throw error;
        }
    }
}

type Query = Partial<{
    CardCount: ModelClause<CardCount>;
    PlayerCardCreated: ModelClause<PlayerCardCreated>;
    PlayerParty: ModelClause<PlayerParty>;
    BattleResult: ModelClause<BattleResult>;
    StageSettings: ModelClause<StageSettings>;
    Randomness: ModelClause<Randomness>;
    Card: ModelClause<Card>;
    Player: ModelClause<Player>;
    PartyCreated: ModelClause<PartyCreated>;
    Stage: ModelClause<Stage>;
}>;

type ResultMapping = {
    CardCount: CardCount;
    PlayerCardCreated: PlayerCardCreated;
    PlayerParty: PlayerParty;
    BattleResult: BattleResult;
    StageSettings: StageSettings;
    Randomness: Randomness;
    Card: Card;
    Player: Player;
    PartyCreated: PartyCreated;
    Stage: Stage;
};

type QueryResult<T extends Query> = {
    [K in keyof T]: K extends keyof ResultMapping ? ResultMapping[K] : never;
};

// Only supports a single model for now, since torii doesn't support multiple models
// And inside that single model, there's only support for a single query.
function convertQueryToToriiClause(query: Query): Clause | undefined {
    const [model, clause] = Object.entries(query)[0];

    if (Object.keys(clause).length === 0) {
        return undefined;
    }

    const clauses: Clause[] = Object.entries(clause).map(([key, value]) => {
        return {
            Member: {
                model,
                member: key,
                ...valueToToriiValueAndOperator(value),
            },
        } satisfies Clause;
    });

    return clauses[0];
}
type GeneralParams = {
    toriiUrl?: string;
    relayUrl?: string;
    account?: Account;
};

type InitialParams = GeneralParams &
    (
        | {
                rpcUrl?: string;
                worldAddress: string;
                actionsAddress: string;
    actionsAddress: string;
            }
        | {
                manifest: any;
            }
    );

export class KagekiDuels {
    rpcUrl: string;
    toriiUrl: string;
    toriiPromise: Promise<Client>;
    relayUrl: string;
    worldAddress: string;
    private _account?: Account;
    actions: ActionsCalls;
    actionsAddress: string;
    actions: ActionsCalls;
    actionsAddress: string;

    constructor(params: InitialParams) {
        if ("manifest" in params) {
            const config = createManifestFromJson(params.manifest);
            this.rpcUrl = config.world.metadata.rpc_url;
            this.worldAddress = config.world.address;

            const actionsAddress = config.contracts.find(
                (contract) =>
                    contract.name === "dojo_starter::systems::actions::actions"
            )?.address;

            if (!actionsAddress) {
                throw new Error("No actions contract found in the manifest");
            }

            this.actionsAddress = actionsAddress;
    const actionsAddress = config.contracts.find(
                (contract) =>
                    contract.name === "dojo_starter::systems::actions::actions"
            )?.address;

            if (!actionsAddress) {
                throw new Error("No actions contract found in the manifest");
            }

            this.actionsAddress = actionsAddress;
        } else {
            this.rpcUrl = params.rpcUrl || LOCAL_KATANA;
            this.worldAddress = params.worldAddress;
            this.actionsAddress = params.actionsAddress;
    this.actionsAddress = params.actionsAddress;
        }
        this.toriiUrl = params.toriiUrl || LOCAL_TORII;
        this.relayUrl = params.relayUrl || LOCAL_RELAY;
        this._account = params.account;
        this.actions = new ActionsCalls(this.actionsAddress, this._account);
    this.actions = new ActionsCalls(this.actionsAddress, this._account);

        this.toriiPromise = createClient([], {
            rpcUrl: this.rpcUrl,
            toriiUrl: this.toriiUrl,
            worldAddress: this.worldAddress,
            relayUrl: this.relayUrl,
        });
    }

    get account(): Account | undefined {
        return this._account;
    }

    set account(account: Account) {
        this._account = account;
        this.actions = new ActionsCalls(this.actionsAddress, this._account);
    this.actions = new ActionsCalls(this.actionsAddress, this._account);
    }

    async query<T extends Query>(query: T, limit = 10, offset = 0) {
        const torii = await this.toriiPromise;

        return {
            torii,
            findEntities: async () => this.findEntities(query, limit, offset),
        };
    }

    async findEntities<T extends Query>(query: T, limit = 10, offset = 0) {
        const torii = await this.toriiPromise;

        const clause = convertQueryToToriiClause(query);

        const toriiResult = await torii.getEntities({
            limit,
            offset,
            clause,
        });

        return toriiResult as Record<string, QueryResult<T>>;
    }

    async findEntity<T extends Query>(query: T) {
        const result = await this.findEntities(query, 1);

        if (Object.values(result).length === 0) {
            return undefined;
        }

        return Object.values(result)[0] as QueryResult<T>;
    }
}