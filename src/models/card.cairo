use starknet::ContractAddress;

#[derive(Drop, Serde, Copy, Introspect)]
#[dojo::model]
struct CardCount {
    #[key]
    owner: ContractAddress,
    total: u128,
}

#[derive(Drop, Serde, Copy, Introspect)]
#[dojo::model]
struct Card {
    #[key]
    owner: ContractAddress,
    #[key]
    cardId: u128,
    power: u32,
    health: u32,
    factor: u8,
    experience: u64,
    battles: u64,
    skill: Skill,
    element: Element,
}

#[derive(Drop, Serde, Copy, Introspect)]
enum Skill {
    Stealth: bool,
    AuraManipulation: u32,
    Regeneration: u32,
    ElementalControl: bool,
    None
}


#[derive(Drop, Serde, Copy, Introspect)]
enum Element {
    Earth,
    Wind,
    Water,
    Fire
}

impl ElementIntoFelt252 of Into<Element, felt252> {
    fn into(self: Element) -> felt252 {
        match self {
            Element::Earth => 0,
            Element::Wind => 1,
            Element::Water => 2,
            Element::Fire => 3,
        }
    }
}

impl ElementIntou8 of Into<Element, u8> {
    fn into(self: Element) -> u8 {
        match self {
            Element::Earth => 0,
            Element::Wind => 1,
            Element::Water => 2,
            Element::Fire => 3,
        }
    }
}


impl Felt252IntoElement of Into<felt252, Element> {
    fn into(self: felt252) -> Element {
        match self {
            0 => Element::Earth,
            1 => Element::Wind,
            2 => Element::Water,
            3 => Element::Fire,
            _ => Element::Earth
        }
    }
}
