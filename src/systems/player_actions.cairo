use kageki_duels::models::player::{Player, PlayerParty};
use kageki_duels::models::card::{Card, CardCount, Skill, Element};
use kageki_duels::models::environment::Randomness;

use starknet::ContractAddress;

// define the interface
#[dojo::interface]
trait IActions {
    fn spawn_player(ref world: IWorldDispatcher);
    fn make_party(ref world: IWorldDispatcher, id1: u128, id2: u128, id3: u128, id4: u128);
    fn create_character(ref world: IWorldDispatcher, player: ContractAddress, randomness: felt252);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use super::{Card, Player, PlayerParty, Randomness, CardCount, create_card_from_randomness};

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct PartyCreated {
        #[key]
        player: ContractAddress,
        party: PlayerParty
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::model]
    #[dojo::event]
    struct PlayerCardCreated {
        #[key]
        player: ContractAddress,
        cardId: u128
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn_player(ref world: IWorldDispatcher) {
            // Get the address of the current caller, possibly the player's address.
            let caller = get_caller_address();
            // Retrieve the player's current state in the world.
            let _player = get!(world, caller, Player);
        // Ideally we will call here the randomness source, and that will call this contract selector in turn
        }

        fn create_character(
            ref world: IWorldDispatcher, player: ContractAddress, randomness: felt252
        ) {
            let mut cards_count = get!(world, player, (CardCount));
            let last_id = cards_count.total;
            // ID assignment. Create and then Increment
            let card: Card = create_card_from_randomness(player, last_id, randomness);

            let new_player: Player = Player {
                player: player, battles: 0, wins: 0, loses: 0, party_count: 0
            };

            cards_count.total += 1;

            set!(world, (new_player, card, cards_count));
            // Emit event of player card created
            emit!(world, (PlayerCardCreated { player: player, cardId: last_id }));
        }


        // Implementation of the move function for the ContractState struct.
        fn make_party(ref world: IWorldDispatcher, id1: u128, id2: u128, id3: u128, id4: u128) {
            // Get the address of the current caller, possibly the player's address.
            let caller = get_caller_address();

            // Retrieve the player's current state and create the world.
            let mut player: Player = get!(world, caller, Player);

            // Retrieve the last card count. Ids can't be greater than or equal to the last id
            let mut cards_count: CardCount = get!(world, caller, CardCount);

            let last_id: u128 = cards_count.total.into();

            assert(id1 < last_id, 'id1 cant greater than last_id');
            assert(id2 < last_id, 'id2 cant greater than last_id');
            assert(id3 < last_id, 'id3 cant greater than last_id');
            assert(id3 < last_id, 'id4 cant greater than last_id');

            //  Create a new party
            let party: PlayerParty = PlayerParty {
                player: caller,
                partyId: player.party_count,
                is_active: false,
                card1: id1,
                card2: id2,
                card3: id3,
                card4: id4,
            };

            // Update player party count
            player.party_count += 1;

            // Update the world state with the new player data and party.
            set!(world, (party, player));
            // Emit an event to the world to notify about the player's party creation.
            emit!(world, (PartyCreated { player: caller, party }));
        }
    }
}

fn is_valid_party_size(len: usize) -> bool {
    return len <= 4;
}

fn create_card_from_randomness(
    player: ContractAddress, cardId: u128, raw_randomness: felt252
) -> Card {
    let randomness: u256 = raw_randomness.into();
    let new_health: u32 = ((randomness % 150) + 50).try_into().unwrap();
    let new_power: u32 = ((randomness % 100) + 50).try_into().unwrap();
    let new_factor: u8 = (randomness % 10).try_into().unwrap();

    let mut skill: u8 = (randomness % 4).try_into().unwrap();
    let mut new_skill = Skill::None;

    match skill {
        0 => { new_skill = Skill::Stealth(true); },
        1 => {
            let aura_manipulation: u32 = (randomness % 29).try_into().unwrap();
            new_skill = Skill::AuraManipulation(aura_manipulation);
        },
        2 => {
            let renegeration: u32 = (randomness % 19).try_into().unwrap();
            new_skill = Skill::Regeneration(renegeration);
        },
        3 => { new_skill = Skill::ElementalControl(true); },
        _ => {}
    }

    let element_id: felt252 = (randomness % 4).try_into().unwrap();
    let element: Element = element_id.into();

    return Card {
        owner: player,
        cardId: cardId,
        power: new_power,
        health: new_health,
        factor: new_factor,
        experience: 0,
        battles: 0,
        skill: new_skill,
        element: element,
    };
}
