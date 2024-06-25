use starknet::ContractAddress;

#[starknet::interface]
pub trait IPragmaVRF<TContractState> {
    fn get_last_random_number(self: @TContractState) -> felt252;
    fn request_randomness_from_pragma(
        ref self: TContractState,
        seed: u64,
        callback_address: ContractAddress,
        callback_fee_limit: u128,
        publish_delay: u64,
        num_words: u64,
        calldata: Array<felt252>
    );
    fn receive_random_words(
        ref self: TContractState,
        requester_address: ContractAddress,
        request_id: u64,
        random_words: Span<felt252>,
        calldata: Array<felt252>
    );
    fn withdraw_extra_fee_fund(ref self: TContractState, receiver: ContractAddress);
}

#[starknet::interface]
pub trait IRandomStorage<TContractState> {
    fn get_randomness_request_id(self: @TContractState, requester: ContractAddress) -> u64;
    fn get_randomness(
        self: @TContractState, requester: ContractAddress, request_id: u64
    ) -> felt252;
}

#[starknet::contract]
mod KagekiRandomness {
    use starknet::{
        ContractAddress, contract_address_const, get_block_number, get_caller_address,
        get_contract_address
    };
    use pragma_lib::abi::{IRandomnessDispatcher, IRandomnessDispatcherTrait};
    use openzeppelin::token::erc20::interface::{ERC20ABIDispatcher, ERC20ABIDispatcherTrait};
    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        user_requests: LegacyMap<ContractAddress, u64>,
        user_randomnesses: LegacyMap<(ContractAddress, u64), felt252>,
        fee_token_address: ContractAddress,
        pragma_vrf_contract_address: ContractAddress,
        min_block_number_storage: u64,
        last_random_number: felt252,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RandomnessUpdated: RandomnessProcessed,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    struct RandomnessProcessed {
        requester: ContractAddress,
        request_id: u64,
        random: felt252
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        pragma_vrf_contract_address: ContractAddress,
        fee_token_address: ContractAddress,
        owner: ContractAddress
    ) {
        self.ownable.initializer(owner);
        self.pragma_vrf_contract_address.write(pragma_vrf_contract_address);
        self.fee_token_address.write(fee_token_address);
    }

    #[abi(embed_v0)]
    impl RandomStorage of super::IRandomStorage<ContractState> {
        fn get_randomness_request_id(self: @ContractState, requester: ContractAddress) -> u64 {
            self.user_requests.read(requester)
        }

        fn get_randomness(
            self: @ContractState, requester: ContractAddress, request_id: u64
        ) -> felt252 {
            self.user_randomnesses.read((requester, request_id))
        }
    }

    #[abi(embed_v0)]
    impl PragmaVRFOracle of super::IPragmaVRF<ContractState> {
        fn get_last_random_number(self: @ContractState) -> felt252 {
            let last_random = self.last_random_number.read();
            last_random
        }

        fn request_randomness_from_pragma(
            ref self: ContractState,
            seed: u64,
            callback_address: ContractAddress,
            callback_fee_limit: u128,
            publish_delay: u64,
            num_words: u64,
            calldata: Array<felt252>
        ) {
            self.ownable.assert_only_owner();

            let randomness_contract_address = self.pragma_vrf_contract_address.read();
            let randomness_dispatcher = IRandomnessDispatcher {
                contract_address: randomness_contract_address
            };

            // Approve the randomness contract to transfer the callback fee
            // You would need to send some ETH to this contract first to cover the fees
            let token_address = self.fee_token_address.read();
            let eth_dispatcher = ERC20ABIDispatcher { contract_address: token_address };
            eth_dispatcher
                .approve(
                    randomness_contract_address,
                    (callback_fee_limit + callback_fee_limit / 5).into()
                );

            // Request the randomness
            randomness_dispatcher
                .request_random(
                    seed, callback_address, callback_fee_limit, publish_delay, num_words, calldata
                );

            let current_block_number = get_block_number();
            self.min_block_number_storage.write(current_block_number + publish_delay);
        }

        fn receive_random_words(
            ref self: ContractState,
            requester_address: ContractAddress,
            request_id: u64,
            random_words: Span<felt252>,
            calldata: Array<felt252>
        ) {
            // Have to make sure that the caller is the Pragma Randomness Oracle contract
            let caller_address = get_caller_address();
            assert(
                caller_address == self.pragma_vrf_contract_address.read(),
                'caller not randomness contract'
            );
            // and that the current block is within publish_delay of the request block
            let current_block_number = get_block_number();
            let min_block_number = self.min_block_number_storage.read();
            assert(min_block_number <= current_block_number, 'block number issue');

            let random_word: felt252 = *random_words.at(0);
            self.last_random_number.write(random_word);

            let span_elem_1 = *calldata.at(0);
            let requester: ContractAddress = span_elem_1.try_into().unwrap();
            let span_elem_2 = *calldata.at(1);
            let request_id: u64 = span_elem_2.try_into().unwrap();

            let last_request_id: u64 = self.user_requests.read(requester);
            self.user_requests.write(requester, last_request_id + 1);

            self.user_randomnesses.write((requester, request_id), random_word);

            self
                .emit(
                    RandomnessProcessed {
                        requester: requester, request_id: request_id, random: random_word
                    }
                );
        }

        fn withdraw_extra_fee_fund(ref self: ContractState, receiver: ContractAddress) {
            self.ownable.assert_only_owner();

            let token_address = self.fee_token_address.read();
            let eth_dispatcher = ERC20ABIDispatcher { contract_address: token_address };
            let balance = eth_dispatcher.balance_of(get_contract_address());
            eth_dispatcher.transfer(receiver, balance);
        }
    }
}
