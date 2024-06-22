use starknet::ContractAddress;

#[derive(Drop, Serde, Copy, Introspect)]
#[dojo::model]
struct Player {
    #[key]
    player: ContractAddress,
    battles: u64,
    wins: u64,
    loses: u64,
    party_count: u64,
}

#[derive(Drop, Serde, Copy, Introspect)]
#[dojo::model]
struct PlayerParty {
    #[key]
    player: ContractAddress,
    #[key]
    partyId: u64,
    is_active: bool,
    card1: u128,
    card2: u128,
    card3: u128,
    card4: u128,
}

