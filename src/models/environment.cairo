use starknet::ContractAddress;
use super::card::Element;

const STAGE_SETTINGS_ID: u32 = 999999999;

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
struct StageSettings {
    #[key]
    stage_setting: u32,
    stage_count: u128,
}

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
struct Stage {
    #[key]
    p1: ContractAddress,
    #[key]
    p2: ContractAddress,
    #[key]
    stageId: u128,
    p1_party: u64,
    p2_party: u64,
    is_finished: bool,
    randomness: felt252,
    environment: Element,
}


#[derive(Drop, Serde, Introspect)]
#[dojo::model]
struct Randomness {
    #[key]
    contract: ContractAddress,
    last_random_id: felt252
}
