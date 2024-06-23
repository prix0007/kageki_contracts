use kageki_duels::models::player::{Player, PlayerParty};
use kageki_duels::models::card::{Card, CardCount, Skill, Element};
use kageki_duels::models::environment::{Randomness, Stage, StageSettings, STAGE_SETTINGS_ID};

use starknet::ContractAddress;

// define the interface
#[dojo::interface]
trait IActions {
    fn battle_party(ref world: IWorldDispatcher, party_id1: u64, party_id2: u64);
    fn stage_creation_battle_maker(
        ref world: IWorldDispatcher,
        p1: ContractAddress,
        party_id1: u64,
        p2: ContractAddress,
        party_id2: u64,
        raw_randomness: felt252
    );
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use super::{
        Card, Player, PlayerParty, Randomness, Element, Stage, StageSettings, STAGE_SETTINGS_ID,
        battle_cards
    };

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct BattleResult {
        #[key]
        winner: ContractAddress,
        #[key]
        loser: ContractAddress,
        party_id1: u64,
        party_id2: u64,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        // Implementation of the battle_party for the ContractState struct.
        fn battle_party(ref world: IWorldDispatcher, party_id1: u64, party_id2: u64) {
            // Get the address of the current caller, possibly the player's address.
            let caller = get_caller_address();

            // Retrieve the player's current state
            let mut caller_party: PlayerParty = get!(world, party_id1, PlayerParty);
            assert(caller_party.player == caller, 'caller not party owner');
            // Retrieve the opponent's party 
            let mut opponent_party: PlayerParty = get!(world, party_id2, PlayerParty);
            assert(opponent_party.player != caller, 'caller is other party owner');

            assert(caller_party.is_active, 'caller party not active');
            assert(opponent_party.is_active, 'opponent party not active');
        // Ideally call the randomness source now, and it will generate randonmenss and call the stage creation and calculation.
        }

        fn stage_creation_battle_maker(
            ref world: IWorldDispatcher,
            p1: ContractAddress,
            party_id1: u64,
            p2: ContractAddress,
            party_id2: u64,
            raw_randomness: felt252
        ) {
            // Will lock this via stage params so only random contract can call. Keeping open for now
            let _caller = get_caller_address();

            // party 1 state
            let mut party_1: PlayerParty = get!(world, (p1, party_id1), PlayerParty);
            // party 2 state
            let mut party_2: PlayerParty = get!(world, (p2, party_id2), PlayerParty);

            assert(party_1.is_active, 'caller party not active');
            assert(party_2.is_active, 'opponent party not active');

            let mut player1: Player = get!(world, party_1.player, Player);
            let mut player2: Player = get!(world, party_2.player, Player);

            let randomness: u256 = raw_randomness.into();
            let stage_element_id: felt252 = (randomness % 4).try_into().unwrap();

            // Current Stage Element
            let mut stage_element: Element = stage_element_id.into();

            let mut p1_c1: Card = get!(world, (p1, party_1.card1), Card);
            let mut p1_c2: Card = get!(world, (p1, party_1.card2), Card);
            let mut p1_c3: Card = get!(world, (p1, party_1.card3), Card);
            let mut p1_c4: Card = get!(world, (p1, party_1.card4), Card);

            let mut p2_c1: Card = get!(world, (p2, party_2.card1), Card);
            let mut p2_c2: Card = get!(world, (p2, party_2.card2), Card);
            let mut p2_c3: Card = get!(world, (p2, party_2.card3), Card);
            let mut p2_c4: Card = get!(world, (p2, party_2.card4), Card);

            let mut current_p1: Card = p1_c1;
            let mut p1_idx: u8 = 0;
            let mut current_p2: Card = p2_c1;
            let mut p2_idx: u8 = 0;

            while p1_idx < 4
                && p2_idx < 4 {
                    // Battle Cards 
                    let (winner_id, winner_health) = battle_cards(
                        current_p1, current_p2, stage_element
                    );
                    // increment card idx's
                    if (winner_id == current_p1.cardId) {
                        p2_idx += 1;
                        if (p2_idx == 0) {
                            current_p2 = p2_c1;
                        }
                        if (p2_idx == 1) {
                            current_p2 = p2_c2;
                        }
                        if (p2_idx == 2) {
                            current_p2 = p2_c3;
                        }
                        if (p2_idx == 3) {
                            current_p2 = p2_c4;
                        }
                        current_p1.health = winner_health;
                    }
                    if (winner_id == current_p2.cardId) {
                        p1_idx += 1;
                        if (p1_idx == 0) {
                            current_p1 = p1_c1;
                        }
                        if (p1_idx == 1) {
                            current_p1 = p1_c2;
                        }
                        if (p1_idx == 2) {
                            current_p1 = p1_c3;
                        }
                        if (p1_idx == 3) {
                            current_p1 = p1_c4;
                        }
                        current_p2.health = winner_health;
                    }
                };

            // Update card stats

            p1_c1.battles += 1;
            p1_c1.experience += 1;
            p1_c2.battles += 1;
            p1_c2.experience += 1;
            p1_c3.battles += 1;
            p1_c3.experience += 1;
            p1_c4.battles += 1;
            p1_c4.experience += 1;

            p2_c1.battles += 1;
            p2_c1.experience += 1;
            p2_c2.battles += 1;
            p2_c2.experience += 1;
            p2_c3.battles += 1;
            p2_c3.experience += 1;
            p2_c4.battles += 1;
            p2_c4.experience += 1;
            // Update player stats
            player1.battles += 1;
            player2.battles += 1;

            let mut winner_player = party_1.player;
            let mut loser_player = party_1.player;

            if p1_idx > 3 {
                player2.wins += 1;
                player1.loses += 1;
                winner_player = party_2.player;
            } else {
                player1.wins += 1;
                player2.loses += 1;
                loser_player = party_2.player;
            }
            // Stage related processing 

            let mut global_stage_settings = get!(world, STAGE_SETTINGS_ID, StageSettings);
            let stage_id = global_stage_settings.stage_count;

            let stage: Stage = Stage {
                p1: party_1.player,
                p2: party_2.player,
                stageId: stage_id,
                p1_party: party_1.partyId,
                p2_party: party_2.partyId,
                is_finished: true,
                randomness: raw_randomness,
                environment: stage_element,
            };

            global_stage_settings.stage_count += 1;

            // update the world
            set!(
                world,
                (
                    global_stage_settings,
                    player1,
                    player2,
                    p1_c1,
                    p1_c2,
                    p1_c3,
                    p1_c4,
                    p2_c1,
                    p2_c2,
                    p2_c3,
                    p2_c4,
                    stage
                )
            );

            // Emit Battle Result
            emit!(
                world,
                (BattleResult {
                    winner: winner_player,
                    loser: loser_player,
                    party_id1: party_1.partyId,
                    party_id2: party_2.partyId,
                })
            );
        }
    }
}

fn process_skill(skill: Skill) -> (bool, bool, bool, u32, bool, u32) {
    let mut local_skill = skill;

    let mut is_elemental_control_present = false;
    let mut is_stealth_present = false;

    // Regen Vars
    let mut is_regeneration_present = false;
    let mut total_regen = 0;

    // Aura Vars
    let mut is_aura_manipulation_present = false;
    let mut total_aura = 0;
    match local_skill {
        Skill::ElementalControl(p) => { if p == true {
            is_elemental_control_present = true;
        } },
        Skill::Stealth(p) => { if p == true {
            is_stealth_present = true;
        } },
        Skill::Regeneration(p) => { if p > 0 {
            is_regeneration_present = true;
            total_regen += p;
        } },
        Skill::AuraManipulation(p) => {
            if p > 0 {
                is_aura_manipulation_present = true;
                total_aura += p;
            }
        },
        Skill::None => {}
    }
    (
        is_elemental_control_present,
        is_stealth_present,
        is_regeneration_present,
        total_regen,
        is_aura_manipulation_present,
        total_aura
    )
}

fn process_attack(ref health: u32, attack: u32) {
    if attack > health {
        health = 0;
    } else {
        health -= attack;
    }
}

fn battle_cards(card1: Card, card2: Card, stage_terrain: Element) -> (u128, u32) {
    let mut card1_power = card1.power;
    let mut card1_health = card1.health;
    let card1_factor = card1.factor;
    let card1_skill = card1.skill;
    let card1_element: u8 = card1.element.into();

    let mut card2_power = card2.power;
    let mut card2_health = card2.health;
    let card2_factor = card2.factor;
    let card2_skill = card2.skill;
    let card2_element: u8 = card2.element.into();

    let mut local_stage_terrain: u8 = stage_terrain.into();

    let (c1_e, c1_s, c1_r, c1_rv, c1_a, c1_av) = process_skill(card1_skill);
    let (c2_e, c2_s, c2_r, c2_rv, c2_a, c2_av) = process_skill(card2_skill);

    // Is card 1 or card 2 any one of them has elemental control, change stage element. Else keep it same
    if c1_e != c2_e {
        if c1_e {
            local_stage_terrain = card1_element;
        } else if c2_e {
            local_stage_terrain = card2_element;
        }
    }

    if card1_element == local_stage_terrain {
        card1_power = card1_power * card1_factor.into();
        card1_health = card1_health * card1_factor.into();
    }
    if card2_element == local_stage_terrain {
        card2_power = card2_power * card2_factor.into();
        card2_health = card2_health * card2_factor.into();
    }

    // Aura manipulation adjustments
    if (c2_a) {
        card1_power -= c2_av;
    }
    if (c1_a) {
        card2_power -= c1_av;
    }

    let mut iter = 0;

    while card1_health != 0
        && card2_health != 0 {
            // Attack
            if iter == 0 {
                // Stealth Checks
                if !c1_s {
                    process_attack(ref card1_health, card2_power);
                }
                if !c2_s {
                    process_attack(ref card2_health, card1_power);
                }
            } else {
                process_attack(ref card1_health, card2_power);
                process_attack(ref card2_health, card1_power);
            }

            // Regeneration
            if (card1_health > 0 && c1_r) {
                card1_health += c1_rv;
            }

            if (card2_health > 0 && c2_r) {
                card2_health += c2_rv;
            }

            iter += 1;
        };

    let mut winner_card = if card1_health > 0 {
        card1.cardId
    } else {
        card2.cardId
    };
    let mut winner_health = if card1_health > 0 {
        card1_health
    } else {
        card2_health
    };

    return (winner_card, winner_health);
}
